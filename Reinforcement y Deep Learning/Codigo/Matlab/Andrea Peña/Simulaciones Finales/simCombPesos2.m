% =========================================================================
% SIMULACIÓN COMBINACIÓN DE CONTROL DE FORMACIÓN, EVASIÓN DE OBSTÁCULOS Y
% MANTENIMIENTO DE LA CONECTIVIDAD
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 18/04/2019
% (MODELO 2)
% =========================================================================
% El siguiente script implementa la simulación de la modificación de la 
% ecuación de consenso al combinar en una sola función racional el control
% de formación, evasión de obstáculos y mantenimiento de la conectividad.
% =========================================================================

%% Inicialización del mundo
gridsize = 20;      % tamaño del mundo
initsize = 20;
N = 10;             % número de agentes
dt = 0.01;          % período de muestreo
T = 20;             % tiempo final de simulación

% Inicialización de posición de agentes
X = initsize*rand(2,N) - initsize/2;
X(:,1) = [0,0];     % posición del lider
Xi = X;

% Inicialización de velocidad de agentes
% V = rand(2, N)-0.5; % aleatorio
V = zeros(2, N); % ceros

%% Se grafica la posición inicial de los agentes
%  Se utiliza distinción de color por grupos de agentes
%    Rojo:    líder
%    Verde:   agente 1 y agente 2
%    Azul:    agente 3, agente 4 y agente 5
%    Negro:   agente 6, agente 7, agente 8 y agente 9
c = [255 0 0;
     0 255 0;
     0 255 0;
     0 0 255;
     0 0 255;
     0 0 255;
     0 0 0;
     0 0 0;
     0 0 0;
     0 0 0];
agents = scatter(X(1,:),X(2,:),[], c, 'filled');
grid minor;
xlim([-gridsize/2, gridsize/2]);
ylim([-gridsize/2, gridsize/2]);

%% Selección matriz y parámetros del sistema
d = Fmatrix(2,8);    % matriz de formación
r = 1;              % radio agentes
R = 10;             % rango sensor

%% Inicialización simulación
t = 0;                      % inicialización de tiempo
ciclos = 1;                 % cuenta de la cantidad de ciclos 
historico = zeros(100*T,N); % histórico de velocidades
hX = zeros(100*T,N);        % histórico posiciones en X
hY = zeros(100*T,N);        % histórico posiciones en Y


while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j); % vector xi - xj
            mdist = norm(dist);    % norma euclidiana vector xi - xj
            dij = 2*d(i,j);        % distancia deseada entre agentes i y j
            
            % Peso añadido a la ecuación de consenso
            if(mdist == 0)
                w = [0; 0];
            else
                w = -((2*(mdist-dij)*(mdist-r)*(mdist-R))-((2*mdist - r - R)*(mdist-dij)^2))/(mdist*((mdist-r)^2)*((mdist-R)^2));
            end
            % Tensión de aristas entre agentes 
            E = E + w.*dist;
        end
        % Actualización de velocidad
        V(:,i) = -0.5*E;
%         V(:,1) = V(:,1)+0.5; % movimiento del líder
%         V(:,1) = 0;          % líder inmóvil
    end
    % Actualización de la posición de los agentes
    X = X + V*dt;
    
    % Almacenamiento de variables para graficar
    for a = 1:N
        hX(ciclos,a)= X(1,a);
        hY(ciclos,a)= X(2,a);
    end
    historico(ciclos,:) = (sum(V.^2,1)).^0.5;
    
    % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    pause(dt);
    t = t + dt;
    ciclos = ciclos + 1;
end

%% Gráficos

% velocidad - tiempo
figure(1);
plot(0:dt:T,historico);
xlabel('Tiempo (segundos)');
ylabel('Velocidad (unidades/segundo)');
ylim([-1,inf])

% trayectorias
figure(2);
hold on;
plot(hX,hY,'--');
xlabel('Posición en eje X (unidades)');
ylabel('Posición en eje Y (unidades)');
scatter(Xi(1,:),Xi(2,:),[], 'k');
scatter(X(1,:),X(2,:),[], 'k', 'filled');
hold off;