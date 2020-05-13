%% IE3038 - Diseño e Innovacion de Ingeniería
% Titulo: simulacionParticulas.m
% Autor: Aldo Stefano Aguilar Nadalini 15170
% Fecha: 03 de marzo de 2019
% Descripcion: Simulacion de particulas para observar el comportamiento
% dependiendo el calculo de parametros PSO.

%% Inicializacion de Mundo

clear;                                      % Borrar variables de workspace
clc;                                        % Borrar Command Window
close all;                                  % Cerrar ventanas de ejecuciones anteriores
rng(4);                                     % Fijar random number generator para reproducibilidad
PART = 1;                                   % Numero de particula a analizar 1-13

% Tamaño de Mundo [-5, 5]
gridsize = 10;

% Limite de random start positions de agentes (0-100)
initsize = 10;

% Cantidad de particulas en la simulacion
N = 200;

% Periodo de muestreo en simulacion
dt = 0.1;       % Simulacion normal
%dt = 0.01;     % Simulacion acelerada

% Tiempo limite de simulacion (12s)
T = 12;

% Inicialización de posición de agentes: random de posiciones (X, Y) en un
% rango de 0-100. Para que se dispersen en la cuadrícula [-50, 50] se le
% debe restar 50. (X-50,Y-50)
X = initsize * rand(2,N) - initsize/2;

% Inicialización de velocidad de agentes
V = rand(2, N) - 0.5; % Aleatorio de 0-1 [-0.5, 0.5]

% Vector de media aritmetica en X y Y
mean_vect = [mean(X(1,:));mean(X(2,:))];

% Vector de desviaciones estandar en X y Y
sigma_vect = [std(X(1,:));std(X(2,:))];

% Inicializacion de global best
p_g = rand(2,1);

% Inicializacion de local bests
p_l = X;

%% Graficacion de Benchmark functions

% Elegir funcion a utilizar (0->4)
type = 2;

if (type == 0)
    % Rosenbrock contour plot
    f = @(x,y) (1-x).^2 + 100*(y-x.^2).^2;
    h0 = figure;
    fcontour(f,'LevelStep',200);
    title('Rosenbrock Benchmark Function');
    hold on;
elseif (type == 1)
    % Several local minima
    f = @(x,y) exp(x-2*x.^2-y.^2).*sin(6*(x+y+x.*y.^2));
    h0 = figure;
    fcontour(f,'LevelStep',0.01);
    title('Minima Benchmark Function');
    hold on;
elseif (type == 2)
    % Sphere
    f = @(x,y) x^2 + y^2;
    h0 = figure;
    fcontour(f,'LevelStep',2);
    title('Sphere Benchmark Function');
    hold on;
elseif (type == 3)
    %Booth
    f = @(x,y) (x + 2*y - 7)^2 + (2*x + y - 5)^2;
    h0 = figure;
    fcontour(f,'LevelStep',10);
    title('Booth Benchmark Function');
    hold on;
elseif (type == 4)
    %Himmelblau
    f = @(x,y) (x^2 + y - 11)^2 + (x + y^2 - 7)^2;
    h0 = figure;
    fcontour(f,'LevelStep',20);
    title('Himmelblau Benchmark Function');
    hold on;
elseif (type == 5)
    %Schaffer F6
    f = @(x,y) 0.5 + (sin(sqrt(x^2 + y^2))^2 - 0.5)/(1 + 0.001*(x^2 + y^2))^2;
    h0 = figure;
    fc = fcontour(f);
    fc.LineWidth = 1;
    fc.LevelList = [-1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0];
    title('Schaffer F6 Benchmark Function');
    hold on;
end
set(h0,'color','w');

% Se grafica la posición inicial de los agentes
agents = scatter(X(1,:),X(2,:), 'k', 'filled');
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
type_w = 4;
        
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
%epsilon = 2/abs(2 - C - sqrt(C^2  - 4*C)); % Convergencia uniforme normal, dispersion regular
%epsilon = 0.5;   % Convergencia rapida, dispersion minima
epsilon = 1;     % Convergencia normal, dispersion nula
%epsilon = 1.1;   % Convergencia lenta, dispersion alta
%epsilon = 1.3;   % Diverge

% Desplegar parametros elegidos en grafica --------------------------------

% TextBox Dimension de despliegue de datos en grafica
dim = [.41 .0 .3 .3];

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

DATA_LOGGER = X(:,PART);

% Mientras tiempo actual sea menor a tiempo limite
while(t < T)
    
    % Para cada particula
    for i = 1:N
        
        % Chequear si posicion Xi es nuevo global best
        p_g = global_best(X(:,i),p_g,type);
        
        % Chequear si posicion Xi es nuevo local best
        p_l(:,i) = local_best(X(:,i),p_l(:,i),type);
        
        % Calculo para Factor de Vecindad ---------------------------------
        
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
        mask = repmat(vecinos,2,1);
        
        % Suma total de Xs y Ys de vecinos y multiplicar por 0.5
        %V(:,i) = 0.5 * sum(distancias .* mask,2);
        
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
        
    end
    
    % Actualizacion de posicion de agentes
    X = X + V*dt;
    DATA_LOGGER(:,end + 1) = X(:,PART);
    
    % Calculo de media aritmetica de posiciones
    mean_vect(:,end + 1) = [mean(X(1,:));mean(X(2,:))];
    
    % Calculo de desviaciones estandar de posiciones
    sigma_vect(:,end + 1) = [std(X(1,:));std(X(2,:))];
    
    % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    
    % Pausa en paso de tiempo digitalizado e incremento de tiempo
    pause(dt);
    t = t + dt;
    
    % Conteo de iteraciones
    iter = iter + 1;
end

% Impresion de minimo encontrado de la funcion
title(sprintf('Global Best: [%f, %f]', p_g(1), p_g(2)));

str = '';
if (type == 0)
    str = '(Rosenbrock)';
elseif (type == 1)
    str = '(Minima)';
elseif (type == 2)
    str = '(Sphere)';
elseif (type == 3)
    str = '(Booth)';
elseif (type == 4)
    str = '(Himmelblau)';
end

%% Graficacion de posicion (X,Y) de particula especifica vs. tiempo
% h0 = figure; clf;
% set(h0,'units','points','position',[60,95,520,420]);
% set(h0,'color','w');
% plot(DATA_LOGGER(1,:),'b','LineWidth',3);
% hold on;
% plot(DATA_LOGGER(2,:),'r','LineWidth',3);
% grid on; grid minor;
% xlabel('Tiempo (s)','FontSize',14); ylabel('Posición (m)','FontSize',14);
% xticks([0 10 20 30 40 50 60 70 80 90 100 110 120]);
% xticklabels({'0','1','2','3','4','5','6','7','8','9','10','11','12'});
% xlim([0 120]); ylim([-5 5]);
% legend('Posición X de partícula','Posición Y de partícula')

%% Graficacion de Desviacion Estandar vs. Tiempo
% h1 = figure; clf;
% set(h1,'units','points','position',[60,95,520,420]);
% set(h1,'color','w');
% plot(sigma_vect(1,:),'b','LineWidth',3);
% hold on;
% plot(sigma_vect(2,:),'r','LineWidth',3);
% grid on; grid minor;
% xlabel('Tiempo (s)','FontSize',14); ylabel('Desviación Estándar','FontSize',14);
% xticks([0 10 20 30 40 50 60 70 80 90 100 110 120]);
% xticklabels({'0','1','2','3','4','5','6','7','8','9','10','11','12'});
% xlim([0 120]); %ylim([-5 5]);
% legend('Dispersión de particulas en eje X','Dispersión de particulas en eje Y','Location','northeast');

%% Graficacion de Evolucion de centro y dispersion de enjambre 

% Inicializacion de figura con dimensiones y render EPS adecuado
h2 = figure; clf;
set(h2,'units','points','position',[60,95,1020,420]);
set(h2,'color','w');
set(h2,'renderer','Painters');

subplot(1,2,1);
% Creacion de barras de error por cada medicion de desviacion estandar en X
xx = linspace(0,length(mean_vect(1,:))-1,length(mean_vect(1,:)));
f1 = fill([xx;flipud(xx)],[mean_vect(1,:)-sigma_vect(1,:);flipud(mean_vect(1,:)+sigma_vect(1,:))],'b');
set(f1,'EdgeColor','b');
set(f1,'EdgeAlpha',.5);
hold on;
% Extra para lograr cambiar el color de la leyenda de dispersion en X
a1 = area([0.0001 0.0002],[0.0001 0.0002],'FaceColor','b','FaceAlpha',.3,'EdgeAlpha',.3,'ShowBaseLine','off');
hold on;
% Graficacion de movimiento de centro de enjambre respecto al tiempo
p1 = plot(mean_vect(1,:),'b','LineWidth',3);
hold on;
grid on; grid minor;
xlabel('Tiempo (s)','FontSize',14); ylabel('Posición de enjambre en X (m)','FontSize',14);
xticks([0 10 20 30 40 50 60 70 80 90 100 110 120]);
xticklabels({'0','1','2','3','4','5','6','7','8','9','10','11','12'});
xlim([0 120]);
legend([p1(1),a1(1)],'Media de coordenada X de todas las partículas','Dispersión de particulas sobre eje X');

subplot(1,2,2);
% Creacion de barras de error por cada medicion de desviacion estandar en Y
f2 = fill([xx;flipud(xx)],[mean_vect(2,:)-sigma_vect(2,:);flipud(mean_vect(2,:)+sigma_vect(2,:))],'r');
set(f2,'EdgeColor','r');
set(f2,'EdgeAlpha',.5);
hold on;
% Extra para lograr cambiar el color de la leyenda de dispersion en Y
a2 = area([0.0001 0.0002],[0.0001 0.0002],'FaceColor','r','FaceAlpha',.3,'EdgeAlpha',.3,'ShowBaseLine','off');
hold on;
% Graficacion de movimiento de centro de enjambre respecto al tiempo
p2 = plot(mean_vect(2,:),'r','LineWidth',3);
hold on;
grid on; grid minor;
xlabel('Tiempo (s)','FontSize',14); ylabel('Posición de enjambre en Y (m)','FontSize',14);
xticks([0 10 20 30 40 50 60 70 80 90 100 110 120]);
xticklabels({'0','1','2','3','4','5','6','7','8','9','10','11','12'});
xlim([0 120]);
legend([p2(1),a2(1)],'Media de coordenada Y de todas las partículas','Dispersión de particulas sobre eje Y','Location','southeast');

% Eliminacion de margenes blancos
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset; 
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];

%% Graficacion de Evolucion de centro y dispersion de enjambre (XY conjunto)
% 
% % Inicializacion de figura con dimensiones y render EPS adecuado
% h2 = figure; clf;
% set(h2,'units','points','position',[60,95,520,420]);
% set(h2,'color','w');
% set(h2,'renderer','Painters');
% 
% % Creacion de barras de error por cada medicion de desviacion estandar en X
% xx = linspace(0,length(mean_vect(1,:))-1,length(mean_vect(1,:)));
% f1 = fill([xx;flipud(xx)],[mean_vect(1,:)-sigma_vect(1,:);flipud(mean_vect(1,:)+sigma_vect(1,:))],'b');
% set(f1,'EdgeColor','b');
% set(f1,'EdgeAlpha',.5);
% hold on;
% % Extra para lograr cambiar el color de la leyenda de dispersion en X
% a1 = area([0.0001 0.0002],[0.0001 0.0002],'FaceColor','b','FaceAlpha',.3,'EdgeAlpha',.3,'ShowBaseLine','off');
% hold on;
% 
% % Creacion de barras de error por cada medicion de desviacion estandar en Y
% f2 = fill([xx;flipud(xx)],[mean_vect(2,:)-sigma_vect(2,:);flipud(mean_vect(2,:)+sigma_vect(2,:))],'r');
% set(f2,'EdgeColor','r');
% set(f2,'EdgeAlpha',.5);
% hold on;
% % Extra para lograr cambiar el color de la leyenda de dispersion en Y
% a2 = area([0.0001 0.0002],[0.0001 0.0002],'FaceColor','r','FaceAlpha',.3,'EdgeAlpha',.3,'ShowBaseLine','off');
% hold on;
% 
% % Graficacion de movimiento de centro de enjambre en Xrespecto al tiempo
% p1 = plot(mean_vect(1,:),'b','LineWidth',3);
% hold on;
% grid on; grid minor;
% 
% % Graficacion de movimiento de centro de enjambre en Y respecto al tiempo
% p2 = plot(mean_vect(2,:),'r','LineWidth',3);
% hold on;
% grid on; grid minor;
% 
% title("Sphere Benchmark Function convergence in (0,0)");
% xlabel('Time (s)','FontSize',14); ylabel('Swarm Location (m)','FontSize',14);
% xticks([0 10 20 30 40 50 60 70 80 90 100 110 120]);
% xticklabels({'0','1','2','3','4','5','6','7','8','9','10','11','12'});
% xlim([0 120]); ylim([-5 5]);
% lgd = legend([p1(1),p2(1),a1(1),a2(1)],'Average X coordinate of all particles','Average Y coordinate of all particles','Particle dispersion over X axis','Particle dispersion over Y axis','Location','southeast');
% lgd.FontSize = 12;