%% IE3038 - Diseño e Innovacion de Ingeniería
% Titulo: simulacionRotacion.m
% Autor: Aldo Stefano Aguilar Nadalini 15170
% Fecha: 12 de marzo de 2019
% Descripcion: Simulacion de particulas para observar el comportamiento
% dependiendo el calculo de parametros PSO. (Con cinematica)

%% Inicializacion de Mundo

% Tamaño de Mundo [-50, 50]
gridsize = 10;

% Limite de random start positions de agentes (0-100)
initsize = 10;

% Cantidad de agentes en la simulacion
N = 20;         % 20 agentes ideal para simulacion con colisiones

% Periodo de muestreo en simulacion
%dt = 0.1;       % Simulacion normal
dt = 0.075;     % Simulacion acelerada (Se observo que reduce colisiones)

% Tiempo limite de simulacion (12s)
T = 12;

% Inicialización de posición de agentes: random de posiciones (X, Y) en un
% rango de 0-100. Para que se dispersen en la cuadrícula [-50, 50] se le
% debe restar 50. (X-50,Y-50)
X = initsize * rand(2,N) - initsize/2;

% Creacion de array de orientaciones iniciales de agentes
Theta = 2 * pi * rand(1,N);

% Creacion de array de bumpers delanterons de robots
X_front = [X(1,:) + (0.2.*cos(Theta));X(2,:) + (0.2.*sin(Theta))];
X_mid1 = [X(1,:) + (0.15.*cos(Theta));X(2,:) + (0.15.*sin(Theta))];
X_mid2 = [X(1,:) + (0.1.*cos(Theta));X(2,:) + (0.1.*sin(Theta))];
X_mid3 = [X(1,:) + (0.05.*cos(Theta));X(2,:) + (0.05.*sin(Theta))];

% Inicialización de velocidad de agentes
V = rand(2, N) - 0.5; % Aleatorio de 0-1 [-0.5, 0.5]

% Inicializacion de global best
p_g = rand(2,1);

% Inicializacion de local bests
p_l = X;

% Inicializacion de radio de repulsion de particulas
repulsion_radius = 0.5; % Robots reales tienen 5cm de diametro

%% Graficacion de Benchmark functions

% Elegir funcion a utilizar (0->4)
type = 2;

h0 = figure;
set(gcf,'units','points','position',[110,40,935,505]);
set(h0,'color','w')
if (type == 0)
    % Rosenbrock contour plot
    f = @(x,y) (1-x).^2 + 100*(y-x.^2).^2;
    fcontour(f,'LevelStep',200);
    title('Rosenbrock Benchmark Function');
    hold on;
elseif (type == 1)
    % Several local minima
    f = @(x,y) exp(x-2*x.^2-y.^2).*sin(6*(x+y+x.*y.^2));
    fcontour(f,'LevelStep',0.01);
    title('Minima Benchmark Function');
    hold on;
elseif (type == 2)
    % Sphere
    f = @(x,y) x^2 + y^2;
    fcontour(f,'LevelStep',2);
    title('Sphere Benchmark Function');
    hold on;
elseif (type == 3)
    %Booth
    f = @(x,y) (x + 2*y - 7)^2 + (2*x + y - 5)^2;
    fcontour(f,'LevelStep',10);
    title('Booth Benchmark Function');
    hold on;
elseif (type == 4)
    %Himmelblau
    f = @(x,y) (x^2 + y - 11)^2 + (x + y^2 - 7)^2;
    fcontour(f,'LevelStep',20);
    title('Himmelblau Benchmark Function');
    hold on;
end

% Se grafica la posición inicial de los agentes
agents = scatter(X(1,:),X(2,:), 'k', 'filled');
agents_perimeter = scatter(X(1,:),X(2,:),200, 'r');
agents_front = scatter(X_front(1,:),X_front(2,:), 'b', 'filled');
agents_mid1 = scatter(X_mid1(1,:),X_mid1(2,:), 'b', 'filled');
agents_mid2 = scatter(X_mid2(1,:),X_mid2(2,:), 'b', 'filled');
agents_mid3 = scatter(X_mid3(1,:),X_mid3(2,:), 'b', 'filled');

% Dibujar dimensiones de frontera de agentes con dimensiones de ejes
s = 0.3;
currentunits = get(gca,'Units');
set(gca, 'Units', 'Points');
axpos = get(gca,'Position');
set(gca, 'Units', currentunits);
markerWidth = s/diff(xlim)*axpos(3);
set(agents_perimeter, 'SizeData', markerWidth^2);

grid minor;
xlim([-gridsize/2, gridsize/2]);
ylim([-gridsize/2, gridsize/2]);

%% Parametros de Algoritmo PSO

% Calculo de Parametro de Inercia -----------------------------------------

% Seleccion de tipo de calculo de inercia a utilizar
% - 0: Inercia constante w = 0.8
%      TIEMPO APROX.: 10.71 segundos
%      DISPERSION NULA
% - 1: Inercia lineal decreciente en el tiempo w(t) = mt + b
%      TIEMPO APROX.: 10.88s segundos
%      DISPERSION NULA
% - 2: Inercia caotica w(t) = (wmax-wmin)*(MAXiter-iter)/MAXiter*wmax*z
%      TIEMPO APROX.: 3.03s segundos
%      DISPERSION NULA
% - 3: Inercia random w(t) = 0.5 + rand()/2
%      TIEMPO APROX.: 9.93s segundos
%      DISPERSION NULA
% - 4: Inercia exponencial w(t) = wmin+(wmax-w_min)*exp((-1*iter)/(MAXiter/10)
%      TIEMPO APROX.: 12 segundos
%      DISPERSION BAJA
type_w = 2;
        
% Parametro de Inercia constante (10.71s) dispersion nula 
w = 0.8;

% Demas calculos estan dentro de simulacion (Lineal decreciente, caotico,
% random, natural exponencial)

% Calculo de Parametros de Escalamiento -----------------------------------

% Parametro de Escalamiento para Factor Cognitivo (Valor optimo: 2)
c1 = 2;         % Dispersion nula
%c1 = 1;         % Dispersion minima
%c1 = 2;         % Dispersion regular alta
%c1 = 5;         % Dispersion alta

% Parametro de Escalamiento para Factor Social (Valor optimo: 10)
c2 = 10;         % Convergencia acelerada
%c2 = 5;          % Convergencia rapida
%c2 = 2;          % Convergencia regular baja
%c2 = 1;          % Convergencia lenta

% Calculo de Parametro de Constriccion ------------------------------------
C = c1 + c2;
epsilon = 0.3;   % Convergencia rapida, dispersion minima (ideal para simulacion con colisiones, evitar pasos largos)
%epsilon = 1;     % Convergencia normal, dispersion nula
%epsilon = 1.1;   % Convergencia lenta, dispersion alta
%epsilon = 1.2;   % Diverge
%epsilon = 2/abs(2 - C - sqrt(C^2  - 4*C)); % Convergencia uniforme normal, dispersion regular

% Desplegar parametros elegidos en grafica --------------------------------

% TextBox Dimension de despliegue de datos en grafica
dim = [.676 .62 .3 .3];

% Despliegue de cantidad de agentes
str1 = ['No. of Agents: ', num2str(N)];

% Despliegue de tipo de inercia
str_w = '';
if (type_w == 0)
    str_w = 'Constant';
elseif (type_w == 1)
    str_w = 'Linear';
elseif (type_w == 2)
    str_w = 'Chaotic';
elseif (type_w == 3)
    str_w = 'Random';
elseif (type_w == 4)
    str_w = 'N. Exp';
end 

str2 = [' - Inertia Type: ', str_w];
str3 = ['Cognitive Weight: ', num2str(c1),' - Social Weight: ', num2str(c2)];
str4 = ['Constriction Factor: ', num2str(epsilon),' - Time Step: ', num2str(dt)];
str_T = {[str1,str2],str3,str4};
annotation('textbox',dim,'String',str_T,'FitBoxToText','on','BackgroundColor','white','FaceAlpha',.6);

%% Simulacion de Particulas

% Inicializacion de tiempo digital
t = 0;
MAXiter = 1000;
iter = 0;

% Mientras tiempo actual sea menor a tiempo limite
while(t < T)
    
    % Para cada particula
    for i = 1:N
        
        % Chequear si posicion Xi es nuevo global best
        p_g = global_best(X(:,i),p_g,type);
        
        % Chequear si posicion Xi es nuevo local best
        p_l(:,i) = local_best(X(:,i),p_l(:,i),type);
        
        % Calculo para Factor de Vecindad y Colision ----------------------
        
        % Restar vector posicion Xi a resto de posiciones X para conseguir
        % los vectores de distancia Xi - X.
        % (Repmat replica vector Xi en una matriz 1xN para restar a todos)
        distancias = X - repmat(X(:,i),1,N);
        
        % Distancia euclidiana de cada vector columna de distancia X de
        % particulas
        % (Se crea un vector binario que indica que particula 1-1000 es
        % vecina de una particula i si la distancia es menor a 2).
        vecinos = sqrt(sum(distancias.^2)) <= 1;
        
        % Se duplica vector binario de vecinos a matriz 2x1 para que esto
        % se utilice como mask para seleccionar (X, Y) de particulas que
        % son vecinas.
        mask1 = repmat(vecinos,2,1);
        
        % Calculos de Inercia variante en el tiempo -----------------------
        if (type_w == 1)
            % Parametro de Inercia lineal decreciente
            m = (0.5 - 1)/(10 - 0);
            b = 0.5 - m*10;
            w = m*t + b;
        elseif (type_w == 2)
            % Parametro de inercia caotico
            zi = 0.2;
            zii = 4*zi*(1 - zi);
            w_min = 0.5;
            w_max = 1.0;
            w = (w_max - w_min)*((MAXiter - iter)/MAXiter)*w_max*zii;
        elseif (type_w == 3)
            % Parametro de inercia random
            w = 0.5 + rand/2;
        elseif (type_w == 4)
            % Parametro de inercia exponencial
            w_min = 0.5;
            w_max = 1.0;
            w = w_min + (w_max - w_min)*exp((-1*iter)/(MAXiter/10));
        end
        % -----------------------------------------------------------------
        
        % Velocidad PSO
        past_V = V(:,i);
        V(:,i) =  epsilon*(w*past_V + c1*rand*(p_l(:,i) - X(:,i)) + c2*rand*(p_g - X(:,i)));
        
        % Deteccion de Colision -------------------------------------------
        
        % Restar vector posicion nueva Xi a resto de posiciones X 
        % anteriores para determinr distancia entre ellas
        distancias = X - repmat(X(:,i) + V(:,i)*dt,1,N);
        
        % Distancia euclidiana de cada vector columna de distancia X de
        % particulas
        % (Se crea un vector binario que indica que particula 1-1000 es
        % colision de una particula i si la distancia es menor al radio).
        colision = sqrt(sum(distancias.^2)) <= repulsion_radius;
        
        % Se duplica vector binario de vecinos a matriz 2x1 para que esto
        % se utilice como mask para seleccionar (X, Y) de particulas que
        % estan en colision.
        mask2 = repmat(colision,2,1);
        
        % Suma total de Xs y Ys para determinar si hay una o mas colisiones
        posiciones_colision = sum(distancias .* mask2,2);
        cantidad_colisiones = sum(mask2,2);
        
        % Cantidad de colisiones debe ser mayor a 1 para ignorar la
        % posicion propia de la particula
        if (cantidad_colisiones(1) > 1)
            % Se corrige la nueva posicion para que particula se ubique en 
            % el centroide entre vecinos que ocupan el area en donde se 
            % debe posicionar dicha particula al moverse
            V(1,i) = -7*posiciones_colision(1)/cantidad_colisiones(1);
            V(2,i) = -7*posiciones_colision(2)/cantidad_colisiones(2);
        end
        
    end
    
    % Actualizacion de posicion de agentes
    X = X + V*dt;
    
    % Actualizacion de vectores de orientacion
    Theta = atan2(V(2,:),V(1,:));
    X_front = [X(1,:) + (0.2 .* cos(Theta));X(2,:) + (0.2 .* sin(Theta))];
    X_mid1 = [X(1,:) + (0.15.*cos(Theta));X(2,:) + (0.15.*sin(Theta))];
    X_mid2 = [X(1,:) + (0.1.*cos(Theta));X(2,:) + (0.1.*sin(Theta))];
    X_mid3 = [X(1,:) + (0.05.*cos(Theta));X(2,:) + (0.05.*sin(Theta))];
    
    % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    agents_perimeter.XData = X(1,:);
    agents_perimeter.YData = X(2,:);
    
    % Actualizacion de grafica de vectores de orientacion
    agents_front.XData = X_front(1,:);
    agents_front.YData = X_front(2,:);
    agents_mid1.XData = X_mid1(1,:);
    agents_mid1.YData = X_mid1(2,:);
    agents_mid2.XData = X_mid2(1,:);
    agents_mid2.YData = X_mid2(2,:);
    agents_mid3.XData = X_mid3(1,:);
    agents_mid3.YData = X_mid3(2,:);
    
    % Pausa en paso de tiempo digitalizado e incremento de tiempo
    pause(dt);
    t = t + dt;
    
    % Conteo de iteraciones
    iter = iter + 1;
end

% Impresion de minimo encontrado de la funcion
title(sprintf('Global Best: [%f, %f]', p_g(1), p_g(2)));

%% NOTAS

% 1. Se observo que reducir el periodo de muestreo dt, permite una
% actualizacion mas rapida de las posiciones de los agentes y reduce los
% picos en movimientos de estos. Asímismo, reduce la cantidad de colisiones
% por la disminucion de movimientos aleatorios

% 2. Simulacion funciona con 20 agentes para demostracion pero no hay
% problema si se utilizan 10 agentes. Solo incrementa el error de
% convergencia pero no el comportamiento general del swarm.

% 3. El radio de repulsion es de 5cm que es el radio de los robots que se
% utilizaran en el modelo fisico. Cuando los agentes detectan que su
% posicion nueva los va a llevar a colisionar, corrigen su posicion para
% colocarse en el centro de "masa" de los agentes con los que podría
% colisionar. Al ponerse equidistante a sus vecinos, el agente reduce las
% probabilidades de colision. Sin embargo, puede dar problema de que
% distancia equidistante entre un grupo de agentes sea menor a radio de
% agente.

% 4. Benchmark function Himmelblau de multiples minimos es la mas util

% 5. Se observa que inercia natural exponencial talves sea mejor al reducir
% colisiones de robot que la inercia caotica que es la que converge mas
% rapido

% 6. Factor social tiene peso de 10 y factor cognitivo tiene peso de 2.
% Esto ha permitido buena convergencia acelerada y buena exploracion del
% espacio sin segmentacion del swarm

% 7. Parametro de constriccion (epsilon) sirve para acortar pasos de
% particulas. En simulacion de particulas, alenta la convergencia. Sin
% embargo, con agentes de dimensiones fisicas, un epsilon reducido ayuda a
% evitar colisiones al truncar los pasos de los agentes. Epsilon = 0.3
% (menor a diametro de agentes)

% 8. Se agrego tecnica de repulsion entre agentes. Primeramente, se miden
% las distancias de cada i-particula con el resto de particulas y
% determinar si alguna particula vecina esta mas cerca que el diametro del
% agente (o adentro del area de colision). Luego, se toman las posiciones
% de todos los vecinos que se encuentran en area de colision y la
% i-particula cambia ligeramente su destino final para colocarse en el
% centro de "masa" entre los vecinos y asi reducir la probabilidad de
% colision. Se coloco un factor de -7 frente a las velocidades de repulsion
% porque un numero positivo causaba cohesion, y el numero 7 ayuda a
% acelerar las velocidades de repulsion de los agentes a. toparse entre
% ellos.