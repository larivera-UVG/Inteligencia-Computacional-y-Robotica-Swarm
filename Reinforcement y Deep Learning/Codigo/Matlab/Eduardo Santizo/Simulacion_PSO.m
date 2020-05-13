%% PSO: Colisiones y Control Diferencial
% 
% 
% _IE3038 - Dise�o e Innovacion de Ingenier�a_
% 
% _Autor: Eduardo Andr�s Santizo Olivet (16089)_
% 
% _Descripcion: Uso del algoritmo de PSO implementando colisiones y control 
% diferencial_
%% Setup / Par�metros PSO

clear;                                                      % Se limpian las variables del workspace
clear ComputeInertia;                                       % Se limpian las variables persistentes presentes dentro de "ComputeInertia.m"
opengl hardware;

NoParticulas = 10;                                          % No. de part�culas
PartPosDims = 2;                                            % No. de variables a optimizar / No. de dimensiones sobre las que se pueden desplazar las part�culas.

CostFunc = "Dropwave";                             % Funci�n de costo a optimizar. Escribir "help CostFunction" para m�s informaci�n
Multiples_Min = 0;                                          % La funci�n de costo tiene m�ltiples m�nimos? Consultar "help CostFunction" para ver n�mero de m�nimos por funci�n.

DimsMesa = 12;                                              % Dimensiones de mesa de simulaci�n (Metros)
PosMax = DimsMesa / 2;                                      % Posici�n m�x: Valor m�x. para las coordenadas X y Y de las part�culas (Asumiendo un plano de b�squeda cuadrado)
PosMin = -PosMax;                                           % Posici�n m�n: Negativo de la posici�n m�xima

InitTime = 0;                                               % Tiempo de inicio del algoritmo (0s)
EndTime = 30;                                               % Duraci�n de algoritmo en segundos 
dt = 0.01;                                                  % Tiempo de muestreo, diferencial de tiempo o "time step"
IteracionesMax = ceil((EndTime - InitTime) / dt);           % Iteraciones m�ximas que podr� llegar a durar la simulaci�n.

RadioLlantasPuck = 0.2;                                     % Radio de las ruedas del E-Puck
RadioCuerpoPuck = 0.35;                                     % Radio del Cuerpo del E-Puck en metros
RadioDisomorfismo = RadioCuerpoPuck;                        % Distancia entre centro y punto de disomorfismo
PuckVelMax = 6;
%rng(666);                                                  % Se fija la seed a utilizar para la generaci�n aleatoria de n�meros. Hace que los resultados sean replicables.
%% 
%% Inicializaci�n de Criterios de Convergencia

Criterios_Activados = [];                                   % El vector de criterios activados es nulo
Criterios = zeros(1,4);                                     % Se inicializan todos los criterios como "No alcanzados" (Iguales a cero)
%% 
%% B�squeda Num�rica del M�nimo de la "Cost Function"

% Imaginar que se tiene un plano coordenado que va tanto en X y Y desde PosMin a PosMax 
% con un step de 0.01. MeshX consiste de todas las coordenadas X de ese plano y MeshY 
% consiste de todas las coordenadas Y de ese plano. 
Resolucion = 0.01;
[MeshX, MeshY] = meshgrid(PosMin:Resolucion:PosMax, PosMin:Resolucion:PosMax);

% Se redimensionan MeshX y MeshY como vectores columna y luego se concatenan. El resultado 
% es una matriz de dos columnas (Coordenadas X y Y) donde las filas consisten de todas las 
% posibles combinaciones de coordenadas que pueden existir en el plano de b�squeda. 
Mesh2D = [reshape(MeshX, [], 1) reshape(MeshY, [], 1)];

% NOTA: El programa deber�a ser capaz de identificar num�ricamente los m�nimos de la funci�n 
% evaluando los puntos del mesh en la cost function. En caso no se detecten bien. Disminuir 
% el valor de resoluci�n o revisar si la opci�n de "Multiples_Min" est� habilitada (En caso
% se est� utilizando una funci�n de m�ltiples m�nimos.
Altura = reshape(CostFunction(Mesh2D,CostFunc), size(MeshX, 1), size(MeshX, 2));        % Evaluaci�n de todas las coords. del plano en la "Cost Function". El "output vector" (Nx1) se redimensiona a la forma de MeshX
MaxAltura = max(max(Altura));                                                           % Se obtiene el costo m�ximo de todo el plano.
MinAltura = min(min(Altura));                                                           % Se obtiene el costo m�nimo de todo el plano.

if Multiples_Min                                                                        % Utilizar un threshold de detecci�n m�s bajo para funciones con m�ltiples m�nimos globales.
    Threshold_Cercania = 10^-2;                                                         % Modificar en caso no se detecten bien todos los m�nimos globales de una funci�n con m�ltiples m�nimos absolutos.
else             
    Threshold_Cercania = 10^-5;     
end

IndexMin = find(abs(reshape(Altura,[],1) - MinAltura) < Threshold_Cercania);            % Distancia del m�nimo del plano al resto de puntos. Se retornan las coordenadas de los puntos a una distancia < "Threshold_Cercania"
Coords_Min = Mesh2D(IndexMin,:);                                                        % Coordenadas (Fila de Mesh2D) donde se encuentra el/los costo(s) m�nimo(s) global(es)

% Se limpian los m�nimos encontrados en caso se hayan detectado r�plicas de
% la misma coordenada. �til debido a la forma num�rica y algo "brute forced"
% de la soluci�n utilizada para encontrar m�nimos.
i = 1;
while i < size(Coords_Min,1)
    DistMins = sqrt(sum((Coords_Min - Coords_Min(i,:)).^2, 2));                         % Se calcula la distancia euclideada del m�nimo "i" al resto.
    Coords_Min((DistMins < 0.1) & (DistMins ~= 0),:) = [];                              % Se eliminan las filas de "Coords_Min" cuya distancia euclideada sea menor a 0.1 y distinta de 0.
    i = i+1;
end
%% 
%% Coeficientes de Constricci�n / Coeficiente de Inercia
% De acuerdo con Poli, Kennedy y Blackwell (2007) en su art�culo: "Particle 
% Swarm Optimization - Swarm Intelligence", el algoritmo de PSO original ten�a 
% la siguiente forma
% 
% $$v\left(t+1\right)=v\left(t\right)+\vec{U} \left(0,\phi_1 \right)\otimes 
% \left(\vec{p_{\mathrm{local}} } -\vec{x_i } \right)+\vec{U} \left(0,\phi_2 \right)\otimes 
% \left(\vec{p_{\mathrm{global}} } -\vec{x_i } \right)$$
% 
% $$x\left(t+1\right)=x\left(t\right)+v\left(t+1\right)$$
% 
% Donde:
% 
% * $\overrightarrow{U} \left(0,\phi_1 \right)$: Consiste de un n�mero uniformemente 
% distribuido entre 0 y $\phi_1 \;$
% * $\otimes$: Consiste del "element-wise product".
% 
% Este presentaba ciertos problemas de inestabilidad, en particular porque 
% el t�rmino de la velocidad actual ($v\left(t\right)$) tend�a a crecer desmesuradamente. 
% Para limitarlo, la primera soluci�n propuesta por Kennedy y Eberhart (1995) 
% fue truncar los posibles valores que pod�a llegar a tener la velocidad de una 
% part�cula a un valor entre (-Vmax, Vmax). Esto produc�a mejores resultados, 
% pero la selecci�n de Vmax requer�a de una gran cantidad de pruebas para poder 
% obtener un valor �ptimo para la aplicaci�n dada. Poco despu�s Shi y Eberhart 
% (1998) propusieron una modificaci�n a la regla de actualizaci�n de la velocidad 
% de las part�culas: La adici�n de un coeficiente $\omega$ multiplicando a la 
% velocidad actual.
% 
% $$v\left(t+1\right)=\omega \;v\left(t\right)+\overrightarrow{U} \left(0,\phi_1 
% \right)\otimes \left(\overrightarrow{p_{\textrm{local}} } -\overrightarrow{x_i 
% } \right)+\overrightarrow{U} \left(0,\phi_2 \right)\otimes \left(\overrightarrow{p_{\textrm{global}} 
% } -\overrightarrow{x_i } \right)$$
% 
% A este t�rmino se le denomin� coeficiente de inercia, ya que si se hace 
% un an�logo entre la regla de actualizaci�n y un sistema de fuerzas, el coeficiente 
% representa la aparente "fluidez" del medio en el que las part�culas se mueven. 
% La idea de esta modificaci�n era iniciar el algoritmo con una fluidez alta ($\omega 
% =0\ldotp 9$) para favorecer la exploraci�n y reducir su valor hasta alcanzar 
% una fluidez baja  ($\omega =0\ldotp 4$) que favorezca la agrupaci�n y convergencia. 
% Existen m�ltiples m�todos para seleccionar y actualizar $\omega$. Finalmente, 
% el m�todo m�s reciente para limitar la velocidad consiste de aquel propuesto 
% por Clerc y Kennedy (2001). En este, se model� al algoritmo como un sistema 
% din�mico y se obtuvieron sus eigenvalores. Se pudo llegar a concluir que, mientras 
% dichos eigenvalores cumplieran con ciertas relaciones, el sistema de part�culas 
% siempre converger�a. Una de las relaciones m�s f�ciles y computacionalmente 
% eficientes de implementar consiste de la siguiente modificaci�n al PSO:
% 
% $$v\left(t+1\right)=\chi \;\left(\;v\left(t\right)+\overrightarrow{U} \left(0,\phi_1 
% \right)\otimes \left(\overrightarrow{p_{\textrm{local}} } -\overrightarrow{x_i 
% } \right)+\overrightarrow{U} \left(0,\phi_2 \right)\otimes \left(\overrightarrow{p_{\textrm{global}} 
% } -\overrightarrow{x_i } \right)\right)$$
% 
% $$\chi =\frac{2}{\phi -2+\sqrt{\;\phi {\;}^2 -4\phi \;}}$$
% 
% $$\phi =\phi_1 +\phi_2 >4$$
% 
% Al implementar esta constricci�n (Generalmente utilizando $\phi_1 =\phi_2 
% =2\ldotp 05$), se asegura la convergencia en el sistema, por lo que te�ricamente 
% ya no es necesario truncar la velocidad. Un aspecto importante a mencionar es 
% que com�nmente se tiende a distribuir la constante $\chi$ en toda la expresi�n 
% de la siguiente manera:
% 
% $$v\left(t+1\right)=\chi \;\;v\left(t\right)+\chi \overrightarrow{U} \left(0,\phi_1 
% \right)\otimes \left(\overrightarrow{p_{\textrm{local}} } -\overrightarrow{x_i 
% } \right)+\chi \overrightarrow{U} \left(0,\phi_2 \right)\otimes \left(\overrightarrow{p_{\textrm{global}} 
% } -\overrightarrow{x_i } \right)$$
% 
% $$\left.v\left(t+1\right)=\chi \;\;v\left(t\right)+C_1 \otimes \left(\overrightarrow{p_{\textrm{local}} 
% } -\overrightarrow{x_i } \right)+C_2 \otimes \left(\overrightarrow{p_{\textrm{global}} 
% } -\overrightarrow{x_i } \right)\right)$$
% 
% Aqu� se puede llegar a ver m�s claramente como $\chi$ consiste del nuevo 
% valor para el coeficiente de inercia, por lo que la adici�n de una constante 
% $\omega$ ser�a redundante o incluso detrimental para el algoritmo (Ya que introduce 
% efectos imprevistos en la estabilidad del sistema). De cualquier manera se puede 
% experimentar incluyendo ambas constantes y observando los efectos que su adici�n 
% simult�nea tiene en el sistema.


% -------------------------------------------------------------------------
% A continuaci�n se presentan tres opciones para restringir la velocidad: 
%   - Utilizar el coeficiente de constricci�n (Chi) limitando Vmax a Xmax
%   - Utilizar un coeficiente de inercia limitando Vmax a un valor elegido 
%     por el usuario
%   - Mezclar ambos m�todos. M�todo utilizado por Aldo Nadalini en su t�sis.
% -------------------------------------------------------------------------

Restriccion = "Mixto";                                                   % Modo de restricci�n: Inercia / Constriccion / Mixto

switch Restriccion
    
    % Coeficiente de Inercia ====
    % Para el coeficiente de inercia, se debe seleccionar el m�todo que se desea utilizar. 
    % En total se implementaron 5 m�todos distintos. Escribir "help ComputeInertia" para 
    % m�s informaci�n.
    
    case "Inercia"
        TipoInercia = "Chaotic";                                                    % Consultar tipos de inercia utilizando "help ComputeInertia"
        Wmax = 0.9; Wmin = 0.4;
        W = ComputeInertia(TipoInercia, 1, Wmax, Wmin, IteracionesMax);             % C�lculo de la primera constante de inercia.
        
        VelMax = 0.2*(PosMax - PosMin);                                             % Velocidad m�x: Largo max. del vector de velocidad = 20% del ancho/alto del plano 
        VelMin = -VelMax;                                                           % Velocidad m�n: Negativo de la velocidad m�xima
        Chi = 1;                                                                    % Igualado a 1 para que el efecto del coeficiente de constricci�n sea nulo
        Phi1 = 2; Phi2 = 2;
        
    % Coeficiente de Constricci�n ====
    % Basado en la constricci�n tipo 1'' propuesta en el paper por Clerc y Kennedy (2001) 
    % titulado "The Particle Swarm - Explosion, Stability and Convergence". Esta constricci�n 
    % asegura la convergencia siempre y cuando Kappa = 1 y Phi = Phi1 + Phi2 > 4.

    case "Constriccion"
        Kappa = 1;                                                                  % Modificable. Valor recomendado = 1
        Phi1 = 2.05;                                                                % Modificable. Coeficiente de aceleraci�n local. Valor recomendado = 2.05.
        Phi2 = 2.05;                                                                % Modificable. Coeficiente de aceleraci�n global. Valor recomendado = 2.05
        Phi = Phi1 + Phi2;
        Chi = 2*Kappa / abs(2 - Phi - sqrt(Phi^2 - 4*Phi));
        
        W = 1;
        VelMax = PosMax;                                                            % Velocidad m�x: Igual a PosMax
        VelMin = PosMin;                                                            % Velocidad m�n: Igual a PosMin
    
    % Ambos Coeficientes (Mixto) ====
    % Utilizado por Aldo Nadalini en su t�sis "Algoritmo Modificado de Optimizaci�n de 
    % Enjambre de Part�culas (MPSO) (2019). Chi se calcula de la misma manera, pero se
    % utiliza un Phi1 = 2, Phi2 = 10 y el coeficiente de inercia exponencial decreciente.
    
    case "Mixto"
        Kappa = 1;                                                                  % Valor recomendado = 1
        Phi1 = 2;                                                                   % Valor recomendado = 2
        Phi2 = 10;                                                                  % Valor recomendado = 10
        Phi = Phi1 + Phi2;
        Chi = 2*Kappa / abs(2 - Phi - sqrt(Phi^2 - 4*Phi));
        
        TipoInercia = "Exponent1";                                                  % Tipo de inercia recomendada = "Exponent1"
        Wmax = 1.4; Wmin = 0.5;
        W = ComputeInertia(TipoInercia, 1, IteracionesMax);                         % C�lculo de la primera constante de inercia utilizando valores default (1.4 y 0.5).
        
        VelMax = inf;                                                               % Velocidad m�x: Sin restricci�n
        VelMin = -inf;                                                              % Velocidad m�n: Sin restricci�n
    
    % Mixed Discrete PSO (MDPSO) ====
    % Propuesto por Chowdhury, et al. en el paper "A Mixed-Discrete PSO Algorithm with
    % Explicit Diversity-Preservation" y luego utilizado por Juan Pablo Cuahueque en su 
    % tesis (2019). Este evita la aglomeraci�n temprana de las part�culas utilizando una
    % t�cnica denominada "Diversity preservation".
    case "MDPSO"
        Alpha = 400;                                                                % Par�metro cognitivo
        Beta = 50;                                                                  % Par�metro social
        Gamma = 40;                                                                 % Coeficiente de preservaci�n de diversidad
end
%% 
%% Inicializaci�n de Posiciones, Velocidades y Costos

% Posici�n y Velocidad de Part�culas
PartPosicion_Actual = unifrnd(PosMin, PosMax, [NoParticulas PartPosDims]);      % Posici�n (Random) de todas las part�culas. Distribuci�n uniforme.     Dims: NoParticulas X VarDims
PartPosicion_Previa = PartPosicion_Actual;                                      % Memoria con la posici�n previa de todas las part�culas.               Dims: NoParticulas X VarDims
PartPosicion_LocalBest = PartPosicion_Actual;                                   % Las posiciones que generaron los mejores costos en las part�culas     Dims: NoParticulas X VarDims
PartVelocidad = zeros([NoParticulas PartPosDims]);                              % Velocidad de todas las part�culas. Inicialmente 0.                    Dims: NoParticulas X VarDims

% Posici�n y Velocidad de Pucks
PuckPosicion_Actual = PartPosicion_Actual;                                      % Posici�n de los Pucks. Inicialmente igual a la de las part�culas.     Dims: NoParticulas X VarDims
PuckPosicion_Previa = PartPosicion_Previa;                                      % Memoria con la posici�n previa de todos los pucks.                    Dims: NoParticulas X VarDims
PuckVelLineal = zeros([NoParticulas PartPosDims]);                              % Velocidad lineal de todos los pucks. Inicialmente 0.                         Dims: NoParticulas X VarDims
PuckVelAngular = PuckVelLineal;

% Orientaci�n de Pucks
% La indicaci�n de la orientaci�n es una l�nea que apunta hacia el frente
% del Puck. Los componentes (X,Y) de esta linea indicadora se almacenan en 
% la matriz "CompLineaOrientacion"
PuckOrientacion_Actual = unifrnd(0, 2*pi, [NoParticulas 1]);                    % Orientaciones aleatorias para los pucks. Valores entre 0 y 2pi        Dims: NoParticulas X 1 (Vector Columna)
CompLineaOrientacion = RadioCuerpoPuck * [cos(PuckOrientacion_Actual) sin(PuckOrientacion_Actual)];                                             %       Dims: NoParticulas X 2 (Columna por componente: X, Y)

% Costo de part�culas
PartCosto_Local = CostFunction(PartPosicion_Actual, CostFunc);                  % Evaluaci�n del costo en la posici�n actual de la part�cula.           Dims: NoPart�culas X 1 (Vector Columna)
PartCosto_LocalBest = PartCosto_Local;

[PartCosto_GlobalBest, Fila] = min(PartCosto_LocalBest);                        % "Global best": El costo m�s peque�o del vector "CostoLocal"           Dims: Escalar
PartPosicion_GlobalBest = PartPosicion_Actual(Fila, :);                         % "Global best": Posici�n que genera el costo m�s peque�o               Dims: 1 X VarDims

% Costo de E-Pucks
PuckCosto_Local = PartCosto_Local;                                              % Inicialmente todos los costos son iguales a los de las part�culas
PuckCosto_LocalBest = PartCosto_LocalBest;
PuckCosto_GlobalBest = PartCosto_GlobalBest;

% Historia de todos los global best
Costo_History = zeros([IteracionesMax 2]);                                      % Historial de todos los "Costo_Global" o global best de cada iteraci�n
Costo_History(1,:) = [PartCosto_GlobalBest PuckCosto_GlobalBest];               % La primera fila del vector es el primer "Global Best" de las part�culas y los pucks
%% 
%% Settings de Gr�ficaci�n / Setup Gr�ficos

ModoVisualizacion = "2D";                                                       % Modo de visualizaci�n: 2D, 3D o None.
SaveFrames = 0;                                                                 % Guardar frames de animaci�n: 1 = Si / 0 = No.
FrameSkip = 3;                                                                  % Cada cuantas frames se toma un screenshot. Valor recomendado = 3

if ~strcmp(ModoVisualizacion, "None")
    figure(1); clf;                                                             % Se limpia la figura 1
    figure('visible','on');                                                     % Opcional. Utilizado para mostrar animaciones en un ".mlx". Si se utiliza un ".m" se puede comentar.
    axis equal;                                                                 % Ejes con escalas iguales y cuadr�cula habilitada.
    
    FigureWidth = 900;                                                          % Ancho del plot en "pts"
    FigureHeight = 400;                                                         % Alto del plot en "pts"
    ScreenSize = get(0,'ScreenSize');                                           % Se obtiene el tama�o de la pantalla. ScreenSize(3) = Ancho / ScreenSize(4) = Alto
    
    % Centra la figura en pantalla
    set(gcf, 'Position',  [ScreenSize(3)/2 - FigureWidth/2, ScreenSize(4)/2 - FigureHeight/2, FigureWidth, FigureHeight])
        
    % Subplot 2 (Fila 1, Columna 2): Graficaci�n de part�culas
    subplot(1, 2, 2);
    switch ModoVisualizacion
        case "2D"
            axis([PosMin PosMax PosMin PosMax]);                                                                                % Limites Plot: Tanto X como Y van de PosMin a PosMax 
            PlotSupCosto = contour(MeshX, MeshY, Altura);                                                                       % Contour Plot: Curvas de nivel de funci�n o superficie de costo
            hold on; axis manual;  alpha 0.5; grid on;                                                                          %   Graficar en el mismo plot / Transparencia del 50%
            
            % El radio del puck est� en metros, pero debe ser reexpresado en puntos
            % para ser utilizado en "scatter()" y "scatter3()"
            ax = gca;                                                               % Propiedades de "axis" o ejes actuales
            old_units = get(ax, 'Units');                                           % Unidades de los ejes actuales
            set(ax, 'Units', 'points');                                             % Se cambian las unidades de los ejes a puntos
            PosAxis = get(ax, 'Position');                                          % Se obtiene el [left bottom width height] de la caja que encierra a los ejes
            set(ax, 'Units', old_units);                                            % Se regresa a las unidades originales de los ejes
            DimsMesaPuntos = min(PosAxis(3:4));                                     % Se obtiene el valor m�nimo entre el "width" y el "height" de los axes en "points"
            FactorConversion = DimsMesaPuntos / DimsMesa;
            AreaPuckScatter = pi*(RadioCuerpoPuck * FactorConversion)^2;
            
            PlotParticulas = scatter(PartPosicion_Actual(:,1), PartPosicion_Actual(:,2),[],'black');                                    % Scatter Plot: Part�culas. Puntos azules.
            PlotPucks = scatter(PuckPosicion_Actual(:,1), PuckPosicion_Actual(:,2), AreaPuckScatter, 'blue', 'LineWidth', 1.5);         % Scatter Plot: Pucks. Circulos azules.
            PlotPuntoMin = scatter(Coords_Min(:,1), Coords_Min(:,2), 'red', 'x');                                                       %   M�n funci�n de costo = Cruz roja
            PlotLineasOrientacion = quiver(PuckPosicion_Actual(:,1), PuckPosicion_Actual(:,2), ...                                      % Plot: Lineas que indican orientaci�n de puck.
                                           CompLineaOrientacion(:,1), CompLineaOrientacion(:,2), ...
                                           'r','ShowArrowHead','off','AutoScale','off','LineWidth',1.5);
           
        case "3D"
            axis([PosMin PosMax PosMin PosMax], 'vis3d');                                                                       % Limites Plot: X y Y de (PosMin, PosMax). Z de (MinAltura, MaxAltura) 
            PlotSupCosto = surf(MeshX, MeshY, Altura);                                                                          % Surface Plot: Superficie o funci�n de costo 
            hold on; shading interp; alpha 0.5; grid on                                                                         %   Graficar en el mismo plot / Paleta de color "interp" / Transparencia del 50% 
            PlotParticulas = scatter3(PartPosicion_Actual(:,1), PartPosicion_Actual(:,2), PartCosto_Local, [], 'blue', 'filled');           % Scatter Plot: Part�culas. Puntos azules
            h = rotate3d;
            h.Enable = 'on';                                                                                                    % Se permite que el usuario rote la gr�fica    
    end
    
    title({"Funci�n Costo: " + CostFunc});
    xlabel('X_1');
    ylabel('X_2');
    zlabel('Costo'); 
    
    % Subplot 1 (Fila 1, Columna 1): Minimizaci�n de Funci�n de Costo
    SubplotCosto = subplot(1, 2, 1);
    hold on;
    PlotCostoPart = plot(1, Costo_History(1,1), 'LineWidth', 2);                                             % Regular Plot: Historia de los mejores costos obtenidos por el PSO.
    PlotCostoPuck = plot(1, Costo_History(1,2), 'LineWidth', 2);                                             % Regular Plot: Historia de los mejores costos obtenidos por los pucks.
    title({"Costo Global Best" ; "Tiempo de Ejecuci�n: 0 s"});
    legend("Part�culas", "E-Pucks");
    xlabel('Iteraci�n');
    ylabel('Costo');
    grid on;
    
    hold off;
    
    fig = uifigure;
    dd = uidropdown(fig,'Items',{'Red','Yellow','Blue','Green'},...
                     'Value','Blue');
    
end
%% 
%% Main Loop

Iteraciones = 0;
Frame = 0;

for i = 2:IteracionesMax
    
    R1 = rand([NoParticulas PartPosDims]);                                                  % N�meros normalmente distribuidos entre 0 y 1
    R2 = rand([NoParticulas PartPosDims]);
        PartPosicion_Previa = PartPosicion_Actual;
    
    % Actualizaci�n de Velocidad de Part�culas
    PartVelocidad = Chi * (W * PartVelocidad ...                                            % T�rmino inercial
                  + Phi1 * R1 .* (PartPosicion_LocalBest - PartPosicion_Actual) ...         % Componente cognitivo
                  + Phi2 * R2 .* (PartPosicion_GlobalBest - PartPosicion_Actual));          % Componente social
    
    PartVelocidad = max(PartVelocidad, VelMin);                                             % Se truncan los valores de velocidad en el valor m�nimo y m�ximo
    PartVelocidad = min(PartVelocidad, VelMax);
    
    % Actualizaci�n de Posici�n de Part�culas
    PartPosicion_Actual = PartPosicion_Actual + PartVelocidad * dt;                         % Actualizaci�n "discreta" de la posici�n. El algoritmo de PSO original asume un sampling time = 1s.
    PartPosicion_Actual = max(PartPosicion_Actual, PosMin);                                 % Se truncan los valores de posici�n en el valor m�nimo y m�ximo
    PartPosicion_Actual = min(PartPosicion_Actual, PosMax);
    
    % Correcci�n de posici�n de Pucks por colisiones
    PuckPosicion_Actual = SolveCollisions(PuckPosicion_Actual, RadioCuerpoPuck);            % Escribir "help SolveCollisions" para m�s informaci�n
    
    % Actualizaci�n de velocidad lineal y angular de Pucks usando un
    % controlador. Escribir "help getControllerOutput" para m�s info.
    [PuckVelLineal, PuckVelAngular] = getControllerOutput("TUC-LQI",PartPosicion_Actual,PuckPosicion_Actual,PuckOrientacion_Actual,i,RadioCuerpoPuck,PartPosicion_GlobalBest);

    % Actualizaci�n de orientaci�n
    CompsPuckVelLineal = [PuckVelLineal.*cos(PuckOrientacion_Actual) PuckVelLineal.*sin(PuckOrientacion_Actual)];
    PuckPosicion_Actual = PuckPosicion_Actual + CompsPuckVelLineal * dt;
    PuckOrientacion_Actual = PuckOrientacion_Actual + PuckVelAngular * dt;
    CompLineaOrientacion = RadioCuerpoPuck * [cos(PuckOrientacion_Actual) sin(PuckOrientacion_Actual)];
    
    % Actualizaci�n de Local y Global Best: Part�culas
    PartCosto_Local = CostFunction(PartPosicion_Actual, CostFunc);                          % Actualizaci�n de los valores del costo
    PartCosto_LocalBest = min(PartCosto_LocalBest, PartCosto_Local);                        % Se sustituyen los costos que son menores al "Local Best" previo
    Costo_Change = (PartCosto_Local < PartCosto_LocalBest);                                 % Vector binario que indica con un 0 cuales son las filas de "Costo_Local" que son menores que las filas de "PartCosto_LocalBest"
    PartPosicion_LocalBest = PartPosicion_LocalBest .* Costo_Change + PartPosicion_Actual;  % Se sustituyen las posiciones correspondientes a los costos a cambiar en la linea previa
    
    [Actual_GlobalBest, Fila] = min(PartCosto_Local);                                       % Actual_GlobalBest = Valor m�nimo de entre los valores de "Costo_Local"
    if Actual_GlobalBest < PartCosto_GlobalBest                                             % Si el "Actual_GlobalBest" es menor al "Global Best" previo 
        PartCosto_GlobalBest = Actual_GlobalBest;                                           % Se actualiza el valor del "Global Best" (PartCosto_GlobalBest)
        PartPosicion_GlobalBest = PartPosicion_Actual(Fila, :);                             % Y la posici�n correspondiente al "Global Best"
    end
    
    % Actualizaci�n de Local y Global Best: E-Pucks
    PuckCosto_Local = CostFunction(PuckPosicion_Actual, CostFunc);                          % Actualizaci�n de los valores del costo
    PuckCosto_LocalBest = min(PuckCosto_LocalBest, PuckCosto_Local);                        % Se sustituyen los costos que son menores al "Local Best" previo
    
    [Actual_GlobalBest, Fila] = min(PuckCosto_Local);                                       % Actual_GlobalBest = Valor m�nimo de entre los valores de "Costo_Local"
    if Actual_GlobalBest < PuckCosto_GlobalBest                                             % Si el nuevo costo global es menor al "Global Best" entonces
        PuckCosto_GlobalBest = Actual_GlobalBest;                                           % Se actualiza el valor del "Global Best"
    end
    
    % Actualizaci�n del historial de "Global Bests"
    Costo_History(i,:) = [PartCosto_GlobalBest PuckCosto_GlobalBest];                                            
    
    % Actualizaci�n del coeficiente inercial
    if strcmp(Restriccion, "Inercia") || strcmp(Restriccion, "Mixto")
        W = ComputeInertia(TipoInercia, i, Wmax, Wmin, IteracionesMax);
    end
    
    % Actualizar el n�mero de iteraciones
    Iteraciones = Iteraciones + 1;
    
    % Actualizaci�n de los plots utilizando handlers para mejorar "performance"
    switch ModoVisualizacion
        case "2D"
            PlotParticulas.XData = PartPosicion_Actual(:,1);
            PlotParticulas.YData = PartPosicion_Actual(:,2);
            
            PlotCostoPart.XData = (1:i)*dt;
            PlotCostoPart.YData = Costo_History(1:i,1);
            PlotCostoPuck.XData = (1:i)*dt;
            PlotCostoPuck.YData = Costo_History(1:i,2);
            
            PlotPucks.XData = PuckPosicion_Actual(:,1);
            PlotPucks.YData = PuckPosicion_Actual(:,2);
            
            PlotLineasOrientacion.XData = PuckPosicion_Actual(:,1);
            PlotLineasOrientacion.YData = PuckPosicion_Actual(:,2);
            PlotLineasOrientacion.UData = CompLineaOrientacion(:,1);
            PlotLineasOrientacion.VData = CompLineaOrientacion(:,2);
            
        case "3D"
            PlotParticulas.XData = PartPosicion_Actual(:,1);
            PlotParticulas.YData = PartPosicion_Actual(:,2);
            PlotParticulas.ZData = PartCosto_Local;
            PlotCostoPart.XData = 1:i;
            PlotCostoPart.YData = Costo_History(1:i);        
        
    end
    
    % Actualizaci�n del t�tulo del subplot del costo
    set(get(SubplotCosto,'Title'), 'String', {"Costo Global Best" ; "Tiempo de Ejecuci�n: " + num2str(i*dt, '%4.2f') + "s"});
    
    % Evaluaci�n de criterios. Colocar la/las condiciones que dar�n fin al
    % algoritmo en el siguiente "if". Escribir "help EvalCriteriosConvergencia" 
    % para m�s informaci�n.
    [Criterios, NomCriterios] = EvalCriteriosConvergencia(Coords_Min, PuckPosicion_Actual, i, NoParticulas, PosMax, PosMin, IteracionesMax, PuckPosicion_Previa);                                 
    
    if Criterios(4) == 1                              
        
        % Se detectan los criterios que fueron "activados". Se muestra en el t�tulo del gr�fico 
        % cual fue la raz�n de mayor prioridad por la que se detuvo el algoritmo y luego se detiene 
        % el PSO.
        if strcmp(ModoVisualizacion, "None") == 0                                      
            Criterios_Activados = find(Criterios > 0);                                 
            title({"Tiempo de Convergencia: " + num2str(i * dt) + " s"; "Raz�n: " + NomCriterios(max(Criterios_Activados))});
            break
        end
        
    end
    
    % Guardado de Frames Numeradas. La funci�n "mod" se utiliza para
    % guardar frames luego de la cantidad especificada por "FrameSkip"
    % La secuencia de im�genes generadas se guarda en el directorio con
    % la siguiente forma:
    %  - Forma:   "Animation Frames\*CostFunction + ModoVisualizacion*\*frame number*.png
    %  - Ejemplo: "Animation Frames\Himmelblau2D\01.png 
    if SaveFrames == 1
        if mod(i,FrameSkip) == 0
            saveas(gcf, strcat('.\Animation Frames\',CostFunc, ModoVisualizacion,'\',num2str(Frame),'.png'));
            Frame = Frame + 1;
        end
    end
    
    % Actualizaci�n gradual de gr�ficos para mostrar animaci�n
    drawnow limitrate;                                                  % Se mira "stuttery" pero corre en tiempo real
    %drawnow;                                                           % Se mira suave pero corre lento                                     

end