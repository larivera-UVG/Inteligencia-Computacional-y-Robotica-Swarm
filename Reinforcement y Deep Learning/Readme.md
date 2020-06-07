# PSO: Colisiones y Control Diferencial
  


*IE3038 - Diseño e Innovacion de Ingeniería*




*Autor: Eduardo Andrés Santizo Olivet (16089)*




*Descripcion: Uso del algoritmo de PSO implementando colisiones y control diferencial*


## Setup / Parámetros PSO

```matlab:Code
clear;                                                      % Se limpian las variables del workspace
clear ComputeInertia;                                       % Se limpian las variables persistentes presentes dentro de "ComputeInertia.m"

NoParticulas = 10;                                          % No. de partículas
PartPosDims = 2;                                            % No. de variables a optimizar / No. de dimensiones sobre las que se pueden desplazar las partículas.

CostFunc = "APF";                             % Función de costo a optimizar. Escribir "help CostFunction" para más información
Multiples_Min = 0;                                          % La función de costo tiene múltiples mínimos? Consultar "help CostFunction" para ver número de mínimos por función.

DimsMesa = 12;                                              % Dimensiones de mesa de simulación (Metros)
PosMax = DimsMesa / 2;                                      % Posición máx: Valor máx. para las coordenadas X y Y de las partículas (Asumiendo un plano de búsqueda cuadrado)
PosMin = -PosMax;                                           % Posición mín: Negativo de la posición máxima
Margen = 0.4;                                               % Ancho de margen alrededor de los bordes

InitTime = 0;                                               % Tiempo de inicio del algoritmo (0s)
EndTime = 10;                                               % Duración de algoritmo en segundos 
dt = 0.07;                                                  % Tiempo de muestreo, diferencial de tiempo o "time step"
IteracionesMax = ceil((EndTime - InitTime) / dt);           % Iteraciones máximas que podrá llegar a durar la simulación.

EnablePucks = 0;
RadioLlantasPuck = 0.2;                                     % Radio de las ruedas del E-Puck
RadioCuerpoPuck = 0.35;                                     % Radio del Cuerpo del E-Puck en metros
RadioDisomorfismo = RadioCuerpoPuck;                        % Distancia entre centro y punto de disomorfismo
PuckVelMax = 6;

ModoVisualizacion = "2D";                                   % Modo de visualización: 2D, 3D o None.
%rng(20185);                                                % Se fija la seed a utilizar para la generación aleatoria de números. Hace que los resultados sean replicables.
```

  
## Inicialización de Criterios de Convergencia

```matlab:Code
Criterios_Activados = [];                                   % El vector de criterios activados es nulo
Criterios = zeros(1,4);                                     % Se inicializan todos los criterios como "No alcanzados" (Iguales a cero)
```

  
## Búsqueda Numérica del Mínimo de la "Cost Function"

```matlab:Code
% Imaginar que se tiene un plano coordenado que va tanto en X y Y desde PosMin a PosMax 
% con un step de 0.01. MeshX consiste de todas las coordenadas X de ese plano y MeshY 
% consiste de todas las coordenadas Y de ese plano. 
Resolucion = 0.1;
[MeshX, MeshY] = meshgrid(PosMin-Margen:Resolucion:PosMax+Margen, PosMin-Margen:Resolucion:PosMax+Margen);

% Se redimensionan MeshX y MeshY como vectores columna y luego se concatenan. El resultado 
% es una matriz de dos columnas (Coordenadas X y Y) donde las filas consisten de todas las 
% posibles combinaciones de coordenadas que pueden existir en el plano de búsqueda. 
Mesh2D = [MeshX(:) MeshY(:)];

Meta = [-3 -3];
[XObs,YObs,ZObs] = DrawObstacles("Cilindro",1, 0, 2);
%[XObs,YObs,ZObs] = DrawObstacles("Poligono",1, 0, PosMin, PosMax);
CostoPart = CostFunction(Mesh2D, CostFunc, "Choset", "Aditivo",XObs(:,1), YObs(:,1), PosMin, PosMax, Meta);

% NOTA: El programa debería ser capaz de identificar numéricamente los mínimos de la función 
% evaluando los puntos del mesh en la cost function. En caso no se detecten bien. Disminuir 
% el valor de resolución o revisar si la opción de "Multiples_Min" está habilitada (En caso
% se esté utilizando una función de múltiples mínimos.
Altura = reshape(CostoPart, size(MeshX, 1), size(MeshX, 2));                            % Evaluación de todas las coords. del plano en la "Cost Function". El "output vector" (Nx1) se redimensiona a la forma de MeshX  
MaxAltura = max(max(Altura));                                                           % Se obtiene el costo máximo de todo el plano.
MinAltura = min(min(Altura));                                                           % Se obtiene el costo mínimo de todo el plano.
SpanAltura = MaxAltura - MinAltura;                                                     % Diferencia entre ambas alturas

if Multiples_Min                                                                        % Utilizar un threshold de detección más bajo para funciones con múltiples mínimos globales.
    Threshold_Cercania = 10^-2;                                                         % Modificar en caso no se detecten bien todos los mínimos globales de una función con múltiples mínimos absolutos.
else             
    Threshold_Cercania = 10^-5;     
end

%PlotSupCosto = contour(MeshX, MeshY, Altura, 'HandleVisibility','off'); 
IndexMin = find(abs(Altura(:) - MinAltura) < Threshold_Cercania);                       % Distancia del mínimo del plano al resto de puntos. Se retornan las coordenadas de los puntos a una distancia < "Threshold_Cercania"
Coords_Min = Mesh2D(IndexMin,:);                                                        % Coordenadas (Fila de Mesh2D) donde se encuentra el/los costo(s) mínimo(s) global(es)

% Se limpian los mínimos encontrados en caso se hayan detectado réplicas de
% la misma coordenada. Útil debido a la forma numérica y algo "brute forced"
% de la solución utilizada para encontrar mínimos.
i = 1;
while i < size(Coords_Min,1)
    DistMins = sqrt(sum((Coords_Min - Coords_Min(i,:)).^2, 2));                         % Se calcula la distancia euclideada del mínimo "i" al resto.
    Coords_Min((DistMins < 0.1) & (DistMins ~= 0),:) = [];                              % Se eliminan las filas de "Coords_Min" cuya distancia euclideada sea menor a 0.1 y distinta de 0.
    i = i+1;
end
```

  
## Coeficientes de Constricción / Coeficiente de Inercia


De acuerdo con Poli, Kennedy y Blackwell (2007) en su artículo: "Particle Swarm Optimization - Swarm Intelligence", el algoritmo de PSO original tenía la siguiente forma



<img src="https://latex.codecogs.com/gif.latex?v\left(t+1\right)=v\left(t\right)+\overrightarrow{U}&space;\left(0,\phi_1&space;\right)\otimes&space;\left(\overrightarrow{p_{\textrm{local}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)+\overrightarrow{U}&space;\left(0,\phi_2&space;\right)\otimes&space;\left(\overrightarrow{p_{\textrm{global}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)"/>


<img src="https://latex.codecogs.com/gif.latex?x\left(t+1\right)=x\left(t\right)+v\left(t+1\right)"/>



Donde:



   \item{ <img src="https://latex.codecogs.com/gif.latex?\inline&space;\overrightarrow{U}&space;\left(0,\phi_1&space;\right)"/>: Consiste de un número uniformemente distribuido entre 0 y <img src="https://latex.codecogs.com/gif.latex?\inline&space;\phi_1&space;\;"/> }
   -  <img src="https://latex.codecogs.com/gif.latex?\inline&space;\otimes"/>: Consiste del "element-wise product". 



Este presentaba ciertos problemas de inestabilidad, en particular porque el término de la velocidad actual (<img src="https://latex.codecogs.com/gif.latex?\inline&space;v\left(t\right)"/>) tendía a crecer desmesuradamente. Para limitarlo, la primera solución propuesta por Kennedy y Eberhart (1995) fue truncar los posibles valores que podía llegar a tener la velocidad de una partícula a un valor entre (-Vmax, Vmax). Esto producía mejores resultados, pero la selección de Vmax requería de una gran cantidad de pruebas para poder obtener un valor óptimo para la aplicación dada. Poco después Shi y Eberhart (1998) propusieron una modificación a la regla de actualización de la velocidad de las partículas: La adición de un coeficiente <img src="https://latex.codecogs.com/gif.latex?\inline&space;\omega"/> multiplicando a la velocidad actual.



<img src="https://latex.codecogs.com/gif.latex?v\left(t+1\right)=\omega&space;\;v\left(t\right)+\overrightarrow{U}&space;\left(0,\phi_1&space;\right)\otimes&space;\left(\overrightarrow{p_{\textrm{local}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)+\overrightarrow{U}&space;\left(0,\phi_2&space;\right)\otimes&space;\left(\overrightarrow{p_{\textrm{global}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)"/>



A este término se le denominó coeficiente de inercia, ya que si se hace un análogo entre la regla de actualización y un sistema de fuerzas, el coeficiente representa la aparente "fluidez" del medio en el que las partículas se mueven. La idea de esta modificación era iniciar el algoritmo con una fluidez alta (<img src="https://latex.codecogs.com/gif.latex?\inline&space;\omega&space;=0\ldotp&space;9"/>) para favorecer la exploración y reducir su valor hasta alcanzar una fluidez baja  (<img src="https://latex.codecogs.com/gif.latex?\inline&space;\omega&space;=0\ldotp&space;4"/>) que favorezca la agrupación y convergencia. Existen múltiples métodos para seleccionar y actualizar <img src="https://latex.codecogs.com/gif.latex?\inline&space;\omega"/>. Finalmente, el método más reciente para limitar la velocidad consiste de aquel propuesto por Clerc y Kennedy (2001). En este, se modeló al algoritmo como un sistema dinámico y se obtuvieron sus eigenvalores. Se pudo llegar a concluir que, mientras dichos eigenvalores cumplieran con ciertas relaciones, el sistema de partículas siempre convergería. Una de las relaciones más fáciles y computacionalmente eficientes de implementar consiste de la siguiente modificación al PSO:



<img src="https://latex.codecogs.com/gif.latex?v\left(t+1\right)=\chi&space;\;\left(\;v\left(t\right)+\overrightarrow{U}&space;\left(0,\phi_1&space;\right)\otimes&space;\left(\overrightarrow{p_{\textrm{local}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)+\overrightarrow{U}&space;\left(0,\phi_2&space;\right)\otimes&space;\left(\overrightarrow{p_{\textrm{global}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)\right)"/>


<img src="https://latex.codecogs.com/gif.latex?\chi&space;=\frac{2}{\phi&space;-2+\sqrt{\;\phi&space;{\;}^2&space;-4\phi&space;\;}}"/>


<img src="https://latex.codecogs.com/gif.latex?\phi&space;=\phi_1&space;+\phi_2&space;>4"/>



Al implementar esta constricción (Generalmente utilizando <img src="https://latex.codecogs.com/gif.latex?\inline&space;\phi_1&space;=\phi_2&space;=2\ldotp&space;05"/>), se asegura la convergencia en el sistema, por lo que teóricamente ya no es necesario truncar la velocidad. Un aspecto importante a mencionar es que comúnmente se tiende a distribuir la constante <img src="https://latex.codecogs.com/gif.latex?\inline&space;\chi"/> en toda la expresión de la siguiente manera:



<img src="https://latex.codecogs.com/gif.latex?v\left(t+1\right)=\chi&space;\;\;v\left(t\right)+\chi&space;\overrightarrow{U}&space;\left(0,\phi_1&space;\right)\otimes&space;\left(\overrightarrow{p_{\textrm{local}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)+\chi&space;\overrightarrow{U}&space;\left(0,\phi_2&space;\right)\otimes&space;\left(\overrightarrow{p_{\textrm{global}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)"/>


<img src="https://latex.codecogs.com/gif.latex?\left.v\left(t+1\right)=\chi&space;\;\;v\left(t\right)+C_1&space;\otimes&space;\left(\overrightarrow{p_{\textrm{local}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)+C_2&space;\otimes&space;\left(\overrightarrow{p_{\textrm{global}}&space;}&space;-\overrightarrow{x_i&space;}&space;\right)\right)"/>



Aquí se puede llegar a ver más claramente como <img src="https://latex.codecogs.com/gif.latex?\inline&space;\chi"/> consiste del nuevo valor para el coeficiente de inercia, por lo que la adición de una constante <img src="https://latex.codecogs.com/gif.latex?\inline&space;\omega"/> sería redundante o incluso detrimental para el algoritmo (Ya que introduce efectos imprevistos en la estabilidad del sistema). De cualquier manera se puede experimentar incluyendo ambas constantes y observando los efectos que su adición simultánea tiene en el sistema.



```matlab:Code
% -------------------------------------------------------------------------
% A continuación se presentan tres opciones para restringir la velocidad: 
%   - Utilizar el coeficiente de constricción (Chi) limitando Vmax a Xmax
%   - Utilizar un coeficiente de inercia limitando Vmax a un valor elegido 
%     por el usuario
%   - Mezclar ambos métodos. Método utilizado por Aldo Nadalini en su tésis.
% -------------------------------------------------------------------------

Restriccion = "Mixto";                                                   % Modo de restricción: Inercia / Constriccion / Mixto

switch Restriccion
    
    % Coeficiente de Inercia ====
    % Para el coeficiente de inercia, se debe seleccionar el método que se desea utilizar. 
    % En total se implementaron 5 métodos distintos. Escribir "help ComputeInertia" para 
    % más información.
    
    case "Inercia"
        TipoInercia = "Chaotic";                                                    % Consultar tipos de inercia utilizando "help ComputeInertia"
        Wmax = 0.9; Wmin = 0.4;
        W = ComputeInertia(TipoInercia, 1, Wmax, Wmin, IteracionesMax);             % Cálculo de la primera constante de inercia.
        
        VelMax = 0.2*(PosMax - PosMin);                                             % Velocidad máx: Largo max. del vector de velocidad = 20% del ancho/alto del plano 
        VelMin = -VelMax;                                                           % Velocidad mín: Negativo de la velocidad máxima
        Chi = 1;                                                                    % Igualado a 1 para que el efecto del coeficiente de constricción sea nulo
        Phi1 = 2; Phi2 = 2;
        
    % Coeficiente de Constricción ====
    % Basado en la constricción tipo 1'' propuesta en el paper por Clerc y Kennedy (2001) 
    % titulado "The Particle Swarm - Explosion, Stability and Convergence". Esta constricción 
    % asegura la convergencia siempre y cuando Kappa = 1 y Phi = Phi1 + Phi2 > 4.

    case "Constriccion"
        Kappa = 1;                                                                  % Modificable. Valor recomendado = 1
        Phi1 = 2.05;                                                                % Modificable. Coeficiente de aceleración local. Valor recomendado = 2.05.
        Phi2 = 2.05;                                                                % Modificable. Coeficiente de aceleración global. Valor recomendado = 2.05
        Phi = Phi1 + Phi2;
        Chi = 2*Kappa / abs(2 - Phi - sqrt(Phi^2 - 4*Phi));
        
        W = 1;
        VelMax = PosMax;                                                            % Velocidad máx: Igual a PosMax
        VelMin = PosMin;                                                            % Velocidad mín: Igual a PosMin
    
    % Ambos Coeficientes (Mixto) ====
    % Utilizado por Aldo Nadalini en su tésis "Algoritmo Modificado de Optimización de 
    % Enjambre de Partículas (MPSO) (2019). Chi se calcula de la misma manera, pero se
    % utiliza un Phi1 = 2, Phi2 = 10 y el coeficiente de inercia exponencial decreciente.
    
    case "Mixto"
        Kappa = 1;                                                                  % Valor recomendado = 1
        Phi1 = 2;                                                                   % Valor recomendado = 2
        Phi2 = 10;                                                                  % Valor recomendado = 10
        Phi = Phi1 + Phi2;
        Chi = 2*Kappa / abs(2 - Phi - sqrt(Phi^2 - 4*Phi));
        
        TipoInercia = "Exponent1";                                                  % Tipo de inercia recomendada = "Exponent1"
        Wmax = 1.4; Wmin = 0.5;
        W = ComputeInertia(TipoInercia, 1, IteracionesMax);                         % Cálculo de la primera constante de inercia utilizando valores default (1.4 y 0.5).
        
        VelMax = inf;                                                               % Velocidad máx: Sin restricción
        VelMin = -inf;                                                              % Velocidad mín: Sin restricción
    
    % Mixed Discrete PSO (MDPSO) ====
    % Propuesto por Chowdhury, et al. en el paper "A Mixed-Discrete PSO Algorithm with
    % Explicit Diversity-Preservation" y luego utilizado por Juan Pablo Cuahueque en su 
    % tesis (2019). Este evita la aglomeración temprana de las partículas utilizando una
    % técnica denominada "Diversity preservation".
    case "MDPSO"
        Alpha = 400;                                                                % Parámetro cognitivo
        Beta = 50;                                                                  % Parámetro social
        Gamma = 40;                                                                 % Coeficiente de preservación de diversidad
end
```

  
## Inicialización de Posiciones, Velocidades y Costos

```matlab:Code
% Posición y Velocidad de Partículas
PartPosicion_Actual = unifrnd(PosMin, PosMax, [NoParticulas PartPosDims]);      % Posición (Random) de todas las partículas. Distribución uniforme.     Dims: NoParticulas X VarDims

% Se chequean las posiciones y se verifica si están dentro de un obstáculo
InObs = 1;
while sum(InObs) ~= 0
    InObs = inpolygon(PartPosicion_Actual(:,1),PartPosicion_Actual(:,2),XObs(:,1),YObs(:,1));
    PartPosicion_Correccion = unifrnd(PosMin, PosMax, [NoParticulas PartPosDims]);
    PartPosicion_Actual = PartPosicion_Actual + PartPosicion_Correccion .* InObs;
end

PartPosicion_Previa = PartPosicion_Actual;                                      % Memoria con la posición previa de todas las partículas.               Dims: NoParticulas X VarDims
PartPosicion_LocalBest = PartPosicion_Actual;                                   % Las posiciones que generaron los mejores costos en las partículas     Dims: NoParticulas X VarDims
PartVelocidad = zeros([NoParticulas PartPosDims]);                              % Velocidad de todas las partículas. Inicialmente 0.                    Dims: NoParticulas X VarDims

% Historial de Posiciones de Particulas
PartPosicionX_History = zeros(NoParticulas, IteracionesMax);
PartPosicionY_History = zeros(NoParticulas, IteracionesMax);
PartPosicionX_History(:,1) = PartPosicion_Actual(:,1);
PartPosicionY_History(:,1) = PartPosicion_Actual(:,2);

% Posición y Velocidad de Pucks
PuckPosicion_Actual = PartPosicion_Actual;                                      % Posición de los Pucks. Inicialmente igual a la de las partículas.     Dims: NoParticulas X VarDims
PuckPosicion_Previa = PartPosicion_Previa;                                      % Memoria con la posición previa de todos los pucks.                    Dims: NoParticulas X VarDims
PuckVelLineal = zeros([NoParticulas PartPosDims]);                              % Velocidad lineal de todos los pucks. Inicialmente 0.                         Dims: NoParticulas X VarDims
PuckVelAngular = PuckVelLineal;

% Historial de Posiciones de Pucks
PuckPosicionX_History = zeros(NoParticulas, IteracionesMax);
PuckPosicionY_History = zeros(NoParticulas, IteracionesMax);
PuckPosicionX_History(:,1) = PuckPosicion_Actual(:,1);
PuckPosicionY_History(:,1) = PuckPosicion_Actual(:,2);

% Orientación de Pucks
% La indicación de la orientación es una línea que apunta hacia el frente
% del Puck. Los componentes (X,Y) de esta linea indicadora se almacenan en 
% la matriz "CompLineaOrientacion"
PuckOrientacion_Actual = unifrnd(0, 2*pi, [NoParticulas 1]);                    % Orientaciones aleatorias para los pucks. Valores entre 0 y 2pi        Dims: NoParticulas X 1 (Vector Columna)
CompLineaOrientacion = RadioCuerpoPuck * ...                                    %                                                                       Dims: NoParticulas X 2 (Columna por componente: X, Y)
                       [cos(PuckOrientacion_Actual) sin(PuckOrientacion_Actual)];                                             

% Costo de partículas
CostoPart = CostFunction(PartPosicion_Actual,CostFunc,"Choset","Multiplicativo",XObs(:,1),YObs(:,2),PosMin,PosMax,Meta);

PartCosto_Local = CostoPart;                                                  % Evaluación del costo en la posición actual de la partícula.           Dims: NoPartículas X 1 (Vector Columna)
PartCosto_LocalBest = PartCosto_Local;

[PartCosto_GlobalBest, Fila] = min(PartCosto_LocalBest);                        % "Global best": El costo más pequeño del vector "CostoLocal"           Dims: Escalar
PartPosicion_GlobalBest = PartPosicion_Actual(Fila, :);                         % "Global best": Posición que genera el costo más pequeño               Dims: 1 X VarDims

% Costo de E-Pucks
PuckCosto_Local = PartCosto_Local;                                              % Inicialmente todos los costos son iguales a los de las partículas
PuckCosto_LocalBest = PartCosto_LocalBest;
PuckCosto_GlobalBest = PartCosto_GlobalBest;

% Historia de todos los global best
Costo_History = zeros([IteracionesMax 2]);                                      % Historial de todos los "Costo_Global" o global best de cada iteración
Costo_History(1,:) = [PartCosto_GlobalBest PuckCosto_GlobalBest];               % La primera fila del vector es el primer "Global Best" de las partículas y los pucks
```

  
## Colores / Paleta

```matlab:Code
Naranja = [0.9290 0.6940 0.1250];
```

  
## Settings de Gráficación / Setup Gráficos

```matlab:Code
SaveFrames = 0;                                                                 % Guardar frames de animación: 1 = Si / 0 = No.
SaveVideo = 0;
FrameSkip = 3;                                                                  % Cada cuantas frames se toma un screenshot. Valor recomendado = 3

if ~strcmp(ModoVisualizacion, "None")
    
    if SaveVideo
        NombreVideo = "Output" + ModoVisualizacion + ".mp4";
        Video = VideoWriter(NombreVideo,'MPEG-4');
        Video.FrameRate = 30;
        open(Video);
    end
    
    close all;
    figure('Name',"Simulación PSO"); clf;                                       % Se limpia la figura 1
    figure('visible','on');                                                     % Opcional. Utilizado para mostrar animaciones en un ".mlx". Si se utiliza un ".m" se puede comentar.
    axis equal;                                                                 % Ejes con escalas iguales y cuadrícula habilitada.
    
    FigureWidth = 600;                                                          % Ancho del plot en "pts"
    FigureHeight = 500;                                                         % Alto del plot en "pts"
    ScreenSize = get(0,'ScreenSize');                                           % Se obtiene el tamaño de la pantalla. ScreenSize(3) = Ancho / ScreenSize(4) = Alto
    
    % Centra la figura en pantalla
    set(gcf, 'Position',  [ScreenSize(3)/2 - FigureWidth/2, ScreenSize(4)/2 - FigureHeight/2, FigureWidth, FigureHeight])
    
    % El radio del puck está en metros, pero debe ser reexpresado en puntos
    % para ser utilizado en "scatter()" y "scatter3()"
    ax = gca;                                                                   % Propiedades de "axis" o ejes actuales
    old_units = get(ax, 'Units');                                               % Unidades de los ejes actuales
    set(ax, 'Units', 'points');                                                 % Se cambian las unidades de los ejes a puntos
    PosAxis = get(ax, 'Position');                                              % Se obtiene el [left bottom width height] de la caja que encierra a los ejes
    set(ax, 'Units', old_units);                                                % Se regresa a las unidades originales de los ejes
    DimsMesaPuntos = min(PosAxis(3:4));                                         % Se obtiene el valor mínimo entre el "width" y el "height" de los axes en "points"
    FactorConversion = DimsMesaPuntos / DimsMesa;
    AreaPuckScatter = pi*(RadioCuerpoPuck * FactorConversion)^2;
    
    % Subplot 2 (Fila 1, Columna 2): Graficación de partículas
    switch ModoVisualizacion
        case "2D"
            axis([PosMin PosMax PosMin PosMax]);                                                                                        % Limites Plot: Tanto X como Y van de PosMin a PosMax 
            PlotSupCosto = contour(MeshX, MeshY, Altura, 'HandleVisibility','off');                                                     % Contour Plot: Curvas de nivel de función o superficie de costo
            hold on; axis manual; alpha 0.5; grid on;                                                                                   %   Graficar en el mismo plot / Transparencia del 50%
            
            PlotParticulas = scatter(PartPosicion_Actual(:,1), PartPosicion_Actual(:,2),[],'black');                                    % Scatter Plot: Partículas. Puntos negros.
            PlotPuntoMin = scatter(Coords_Min(:,1), Coords_Min(:,2), 'red', 'x');                                                       %   Mín función de costo = Cruz roja
            
            if strcmp(CostFunc,"APF")
                PlotObstaculos = plot(XObs(:,1),YObs(:,1),'black','LineWidth',2); 
            end
            
            if EnablePucks
                PlotPucks = scatter(PuckPosicion_Actual(:,1), PuckPosicion_Actual(:,2), AreaPuckScatter, 'blue', 'LineWidth', 1.5);     % Scatter Plot: Pucks. Circulos azules.
                PlotLineasOrientacion = quiver(PuckPosicion_Actual(:,1), PuckPosicion_Actual(:,2), ...                                  % Plot: Lineas que indican orientación de puck.
                                           CompLineaOrientacion(:,1), CompLineaOrientacion(:,2), ...
                                           'r','ShowArrowHead','off','AutoScale','off','LineWidth',1.5);
            end
                
            legend("Marcadores PSO", "E-Pucks");
           
        case "3D"
            axis([PosMin PosMax PosMin PosMax MinAltura 4*MaxAltura], 'vis3d');                                                         % Limites Plot: X y Y de (PosMin, PosMax). Z de (MinAltura, MaxAltura) 
            PlotSupCosto = surf(MeshX, MeshY, Altura);                                                                                  % Surface Plot: Superficie o función de costo 
            hold on; shading interp; alpha 0.6; grid on;                                                                                %   Graficar en el mismo plot / Paleta de color "interp" / Transparencia del 50% 
            
            % Los artificial potential fields pueden generar alturas
            % infinitas. Entonces si se utiliza el MaxAltura generado
            % arriba simplemente no se graficará nada porque Matlab no sabe
            % como graficar "Inf".
            LimitesEjeZ = zlim;
            if MaxAltura > LimitesEjeZ(2)                                                                                               % Si el "Tick" máximo del eje Z es menor a la altura máxima de la cost function
                 MaxAltura = LimitesEjeZ(2);                                                                                            % Se sustituye la altura máxima por el valor del tick más alto del eje Z
                 SpanAltura = LimitesEjeZ(2) - LimitesEjeZ(1);                                                                          % El "Span" se sutituye por TickMax - TickMin de los ticks del eje Z
            end
            
            AlturaPlanoMesa = 0.1 * SpanAltura + MaxAltura;
            ZObs = ZObs * 0.1 * SpanAltura;
            ZObs = ZObs + AlturaPlanoMesa;
            
            % Graficación del resto de elementos
            PlotParticulas = scatter3(PartPosicion_Actual(:,1), PartPosicion_Actual(:,2),PartCosto_Local,[],'black','filled'); 
            
            if EnablePucks
                
                if strcmp(CostFunc,"APF")
                    LadosObstaculos = surf(XObs,YObs,ZObs,'facecolor',Naranja,'EdgeColor','k','FaceAlpha',0.6);                         % Surface Plot: Lados de los obstáculos
                    TapaObstaculos = fill3(XObs(:,2),YObs(:,2),ZObs(:,2),Naranja);                                                      %   Fill: Tapa superior de los obstáculos
                end
                
                PlotSombras = scatter3(PuckPosicion_Actual(:,1), PuckPosicion_Actual(:,2), PuckCosto_Local, ...                         % Scatter Plot: Sombras de puck sobre superficie de plano
                                       AreaPuckScatter/4, 'blue', 'filled', 'LineWidth', 1);    
                PlotMesa = patch([PosMin PosMin PosMax PosMax], [PosMin PosMax PosMax PosMin], ...                                      % Patch Plot: Superficie de la mesa de trabajo
                          AlturaPlanoMesa*ones(1,4),Naranja,'FaceAlpha',0.6);
                PlotPucks = scatter3(PuckPosicion_Actual(:,1), PuckPosicion_Actual(:,2), AlturaPlanoMesa*ones(NoParticulas,1), ...      % Scatter Plot: Pucks. Circulos azules
                                     AreaPuckScatter, 'blue','filled', 'LineWidth', 0.5, 'MarkerEdgeColor','k','MarkerFaceAlpha', 0.6);  
            end
                                 
            PlotPuntoMin = scatter3(Coords_Min(:,1), Coords_Min(:,2), MinAltura, 'red', 'x', 'LineWidth', 1);      
            
            h = rotate3d;
            h.Enable = 'on';                                                                                                            % Se permite que el usuario rote la gráfica    
            axis manual;
    end
    
    xlabel('X_1');
    ylabel('X_2');
    zlabel('Costo'); 
    set(gcf, 'MenuBar', 'none');
    set(gcf, 'ToolBar', 'none');
    
end
```

## Main Loop

```matlab:Code
Iteraciones = 0;
Frame = 0;

for i = 2:IteracionesMax
    
    R1 = rand([NoParticulas PartPosDims]);                                                  % Números normalmente distribuidos entre 0 y 1
    R2 = rand([NoParticulas PartPosDims]);
    PartPosicion_Previa = PartPosicion_Actual;
    
    % Actualización de Velocidad de Partículas
    PartVelocidad = Chi * (W * PartVelocidad ...                                            % Término inercial
                  + Phi1 * R1 .* (PartPosicion_LocalBest - PartPosicion_Actual) ...         % Componente cognitivo
                  + Phi2 * R2 .* (PartPosicion_GlobalBest - PartPosicion_Actual));          % Componente social
    
    PartVelocidad = max(PartVelocidad, VelMin);                                             % Se truncan los valores de velocidad en el valor mínimo y máximo
    PartVelocidad = min(PartVelocidad, VelMax);
    
    % Actualización de Posición de Partículas
    PartPosicion_Actual = PartPosicion_Actual + PartVelocidad * dt;                         % Actualización "discreta" de la posición. El algoritmo de PSO original asume un sampling time = 1s.
    PartPosicion_Actual = max(PartPosicion_Actual, PosMin);                                 % Se truncan los valores de posición en el valor mínimo y máximo
    PartPosicion_Actual = min(PartPosicion_Actual, PosMax);
    
    % Corrección de posición de Pucks por colisiones
    PuckPosicion_Actual = SolveCollisions(PuckPosicion_Actual, RadioCuerpoPuck);            % Escribir "help SolveCollisions" para más información
    
    % Actualización de velocidad lineal y angular de Pucks usando un
    % controlador. Escribir "help getControllerOutput" para más info.
    [PuckVelLineal, PuckVelAngular] = getControllerOutput("TUC-LQI",PartPosicion_Actual,PuckPosicion_Actual,PuckOrientacion_Actual,i,RadioCuerpoPuck,PartPosicion_GlobalBest);

    % Actualización de orientación
    CompsPuckVelLineal = [PuckVelLineal.*cos(PuckOrientacion_Actual) PuckVelLineal.*sin(PuckOrientacion_Actual)];
    PuckPosicion_Actual = PuckPosicion_Actual + CompsPuckVelLineal * dt;
    PuckOrientacion_Actual = PuckOrientacion_Actual + PuckVelAngular * dt;
    CompLineaOrientacion = RadioCuerpoPuck * [cos(PuckOrientacion_Actual) sin(PuckOrientacion_Actual)];
    
    % Actualización de Local y Global Best: Partículas
    CostoPart = CostFunction(PartPosicion_Actual,CostFunc,"Choset", "Multiplicativo",XObs(:,1),YObs(:,2),PosMin,PosMax,Meta);
    
    PartCosto_Local = CostoPart;                                                            % Actualización de los valores del costo
    PartCosto_LocalBest = min(PartCosto_LocalBest, PartCosto_Local);                        % Se sustituyen los costos que son menores al "Local Best" previo
    Costo_Change = (PartCosto_Local < PartCosto_LocalBest);                                 % Vector binario que indica con un 0 cuales son las filas de "Costo_Local" que son menores que las filas de "PartCosto_LocalBest"
    PartPosicion_LocalBest = PartPosicion_LocalBest .* Costo_Change + PartPosicion_Actual;  % Se sustituyen las posiciones correspondientes a los costos a cambiar en la linea previa
    
    [Actual_GlobalBest, Fila] = min(PartCosto_Local);                                       % Actual_GlobalBest = Valor mínimo de entre los valores de "Costo_Local"
    if Actual_GlobalBest < PartCosto_GlobalBest                                             % Si el "Actual_GlobalBest" es menor al "Global Best" previo 
        PartCosto_GlobalBest = Actual_GlobalBest;                                           % Se actualiza el valor del "Global Best" (PartCosto_GlobalBest)
        PartPosicion_GlobalBest = PartPosicion_Actual(Fila, :);                             % Y la posición correspondiente al "Global Best"
    end
    
    % Actualización de Local y Global Best: E-Pucks
    [CostoPuck] = CostFunction(PuckPosicion_Actual,CostFunc,"Choset","Multiplicativo",XObs(:,1),YObs(:,2),PosMin,PosMax,Meta);
    
    PuckCosto_Local = CostoPuck;                                                            % Actualización de los valores del costo
    PuckCosto_LocalBest = min(PuckCosto_LocalBest, PuckCosto_Local);                        % Se sustituyen los costos que son menores al "Local Best" previo
    
    [Actual_GlobalBest, Fila] = min(PuckCosto_Local);                                       % Actual_GlobalBest = Valor mínimo de entre los valores de "Costo_Local"
    if Actual_GlobalBest < PuckCosto_GlobalBest                                             % Si el nuevo costo global es menor al "Global Best" entonces
        PuckCosto_GlobalBest = Actual_GlobalBest;                                           % Se actualiza el valor del "Global Best"
    end
    
    % Actualización del historial de "Global Bests"
    Costo_History(i,:) = [PartCosto_GlobalBest PuckCosto_GlobalBest];    
    
    % Actualización del historial de posiciones Pucks
    PuckPosicionX_History(:,i) = PuckPosicion_Actual(:,1);
    PuckPosicionY_History(:,i) = PuckPosicion_Actual(:,2);
    PartPosicionX_History(:,i) = PartPosicion_Actual(:,1);
    PartPosicionY_History(:,i) = PartPosicion_Actual(:,2);
    
    % Actualización del coeficiente inercial
    if strcmp(Restriccion, "Inercia") || strcmp(Restriccion, "Mixto")
        W = ComputeInertia(TipoInercia, i, Wmax, Wmin, IteracionesMax);
    end
    
    % Actualizar el número de iteraciones
    Iteraciones = Iteraciones + 1;
    
    % Actualización de los plots utilizando handlers para mejorar "performance"
    switch ModoVisualizacion
        
        case "2D"
            PlotParticulas.XData = PartPosicion_Actual(:,1);
            PlotParticulas.YData = PartPosicion_Actual(:,2);
            
            if EnablePucks
                PlotPucks.XData = PuckPosicion_Actual(:,1);
                PlotPucks.YData = PuckPosicion_Actual(:,2);
                
                PlotLineasOrientacion.XData = PuckPosicion_Actual(:,1);
                PlotLineasOrientacion.YData = PuckPosicion_Actual(:,2);
                PlotLineasOrientacion.UData = CompLineaOrientacion(:,1);
                PlotLineasOrientacion.VData = CompLineaOrientacion(:,2);
            end
            
        case "3D"
            PlotParticulas.XData = PartPosicion_Actual(:,1);
            PlotParticulas.YData = PartPosicion_Actual(:,2);
            PlotParticulas.ZData = PartCosto_Local;
            
            if EnablePucks
                PlotSombras.XData = PuckPosicion_Actual(:,1);
                PlotSombras.YData = PuckPosicion_Actual(:,2);
                PlotSombras.ZData = PuckCosto_Local;
                PlotPucks.XData = PuckPosicion_Actual(:,1);
                PlotPucks.YData = PuckPosicion_Actual(:,2);
            end
    end
    
    % Actualización del título del subplot del costo
    title({"Función de Costo: " + CostFunc ; "Tiempo de Ejecución: " + num2str(i*dt, '%4.2f') + "s"});
    
    % Evaluación de criterios. Colocar la/las condiciones que darán fin al
    % algoritmo en el siguiente "if". Escribir "help EvalCriteriosConvergencia" 
    % para más información.
    [CriteriosPart, NomCriteriosPart] = EvalCriteriosConvergencia(Coords_Min, PartPosicion_Actual, i, NoParticulas, PosMax, PosMin, IteracionesMax, PartPosicion_Previa);       
    [CriteriosPuck, NomCriteriosPuck] = EvalCriteriosConvergencia(Coords_Min, PuckPosicion_Actual, i, NoParticulas, PosMax, PosMin, IteracionesMax, PuckPosicion_Previa);       
    
    if CriteriosPart(4)
    %if CriteriosPart(3) || CriteriosPuck(3)                              
        
        % Se detectan los criterios que fueron "activados". Se muestra en el título del gráfico 
        % cual fue la razón de mayor prioridad por la que se detuvo el algoritmo y luego se detiene 
        % el PSO.
        if strcmp(ModoVisualizacion, "None") == 0                                      
            Criterios_Activados = find(CriteriosPart > 0);                                 
            title({"Tiempo de Convergencia: " + num2str(i * dt) + " s"; "Razón: " + NomCriteriosPart(max(Criterios_Activados))});
            break
        end
        
    end
    
    % Guardado de Frames Numeradas. La función "mod" se utiliza para
    % guardar frames luego de la cantidad especificada por "FrameSkip"
    % La secuencia de imágenes generadas se guarda en el directorio con
    % la siguiente forma:
    %  - Forma:   "Animation Frames\*CostFunction + ModoVisualizacion*\*frame number*.png
    %  - Ejemplo: "Animation Frames\Himmelblau2D\01.png 
    if SaveFrames && mod(i,FrameSkip) == 0
        saveas(gcf, strcat('.\Animation Frames\',CostFunc, ModoVisualizacion,'\',num2str(Frame),'.png'));
        Frame = Frame + 1;
    end
    
    % Actualización gradual de gráficos para mostrar animación
    %drawnow limitrate;                                                  % Se mira "stuttery" pero corre en tiempo real
    drawnow;                                                           % Se mira suave pero corre lento         
    
    % Escritura de la figura actual a video
    if SaveVideo
        Frame = getframe(gcf);
        writeVideo(Video,Frame);
    end

end

switch ModoVisualizacion
    case "2D"
        if EnablePucks
            % Gráfica de trayectorias seguidas por los E-Pucks
            for i = 1:NoParticulas
                Trayectoria = plot(PuckPosicionX_History(i,:), PuckPosicionY_History(i,:), 'Color', [0.8, 0.2, 0.14], 'HandleVisibility', 'off' ,'LineWidth', 2);
                Trayectoria.Color(4) = 0.4;
            end
        
            % Gráfica de puntos iniciales
            scatter(PuckPosicionX_History(:,1), PuckPosicionY_History(:,1), 'b', 'HandleVisibility', 'off' ,'LineWidth', 1.5);
        else
            % Gráfica de trayectorias seguidas por los marcadores PSO
            for i = 1:NoParticulas
                Trayectoria = plot(PartPosicionX_History(i,:), PartPosicionY_History(i,:), 'Color', [0.8, 0.2, 0.14], 'HandleVisibility', 'off' ,'LineWidth', 2);
                Trayectoria.Color(4) = 0.4;
            end
        
            % Gráfica de puntos iniciales
            %scatter(PartPosicionX_History(:,1), PartPosicionY_History(:,1), 'b', 'HandleVisibility', 'off' ,'LineWidth', 1.5);
        end

    case "3D"
        % Gráfica de trayectorias seguidas por los E-Pucks
        for i = 1:NoParticulas
            Trayectoria = plot3(PuckPosicionX_History(i,:), PuckPosicionY_History(i,:), AlturaPlanoMesa*ones(size(PuckPosicionX_History(i,:))), 'Color', [0.8, 0.2, 0.14], 'HandleVisibility', 'off' ,'LineWidth', 2);
        end
        
        % Gráfica de puntos iniciales
        scatter3(PuckPosicionX_History(:,1), PuckPosicionY_History(:,1), AlturaPlanoMesa*ones(size(PuckPosicionX_History(:,1))), 'b', 'HandleVisibility', 'off' ,'LineWidth', 1.5);

end
```


![](Readme_images/)


```matlab:Code

if SaveVideo
    Frame = getframe(gcf);
    writeVideo(Video,Frame);
    close(Video); 
end

```

## Reporte de Resultados

```matlab:Code
% Gráfica 1: Evolución del Global Best en el Tiempo
figure('Name',"Minimización de Función de Costo"); clf;
hold on; grid on;
PlotCostoPart = plot((1:IteracionesMax)*dt, Costo_History(:,1), 'LineWidth', 2);                                             % Plot: Historia de los mejores costos obtenidos por el PSO.
PlotCostoPuck = plot((1:IteracionesMax)*dt, Costo_History(:,2), 'LineWidth', 2);                                             % Plot: Historia de los mejores costos obtenidos por los pucks.
title("Costo Global Best");
legend("Partículas", "E-Pucks");
xlabel('Tiempo (s)'); ylabel('Costo');
```


![](Readme_images/)


```matlab:Code

% Gráfica 2: Medida de la dispersión de las partículas.
figure('Name',"Media y Desviación Estándar de Posiciones de Marcadores PSO", 'Position', [100, 100, 1024, 500]);
clf; hold on; 

PartPosMediaX = median(PartPosicionX_History);
PartDesvEstX = std(PartPosicionX_History);

% Dispersión de partículas sobre eje X
subplot(1,2,1);
MedianaX = plot((1:IteracionesMax)*dt, PartPosMediaX,'b', 'LineWidth', 3);                                    % Plot: Evolución de la mediana de todas las coords X de las partículas
DesvEstX = fill([(1:IteracionesMax)*dt; flipud(1:size(PartPosicionX_History,2))], ...
                [(1:IteracionesMax)*dt; flipud(PartPosMediaX + PartDesvEstX)], 'b');
ylabel('Posición de enjambre en X','FontSize',14);
grid on; grid minor;

% Dispersión de partículas sobre eje Y
subplot(1,2,2);
MedianaY = plot(1:size(PartPosicionY_History,2), median(PartPosicionY_History), 'LineWidth', 2);                          % Plot: Evolución de la mediana de todas las coords Y de las partículas
ylabel('Posición de enjambre en Y','FontSize',14);
grid on; grid minor;
```


![](Readme_images/)

