gridsize = 20; % tamaño del mundo
initsize = 20;
N = 10; % número de agentes
dt = 0.01; % período de muestreo
T = 20; % tiempo final de simulación

% Inicialización de posición de agentes
X = initsize*rand(2,N) - initsize/2;
X(:,1) = [0,0]; % posición del lider

% Inicialización de velocidad de agentes
% V = rand(2, N)-0.5; % aleatorio
V = zeros(2, N); % ceros

% Se grafica la posición inicial de los agentes
% c = zeros(N,3);
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

delta1 = 5;
delta2 = 1;

t = 0; % inicialización de tiempo
while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j);
            mdist = norm(dist);
            w1 = ((2*delta1 - mdist)*dist)/(delta1 - mdist)^2;
            w2 = ((-2*delta2 + mdist)*dist)/(delta2 - mdist)^2;
            E = E + w1
        end
        % actualización de velocidad (aquí se coloca el modelo)
        V(:,i) = -0.1*E;
%         V(:,1) = V(:,1)+0.1;
    end
    X = X + V*dt; % actualización de la posición de los agentes
    % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    pause(dt);
    t = t + dt;
end