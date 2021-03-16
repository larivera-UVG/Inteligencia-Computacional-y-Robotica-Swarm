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

% matrices de adyacencia grafo mínimamente rígido
d1 = [0 1 1 0 0 0 0 0 0 0;
      1 0 1 0 1 1 0 0 0 0;
      1 1 0 1 1 0 0 0 0 0;
      0 0 1 0 1 0 1 1 0 0;
      0 1 1 1 0 1 0 1 1 0;
      0 1 0 0 1 0 0 0 1 1;
      0 0 0 1 0 0 0 1 0 0;
      0 0 0 1 1 0 1 0 0 0;
      0 0 0 0 1 1 0 0 0 1;
      0 0 0 0 0 1 0 0 1 0];

d2 = [0 1 1 1 0 0 0 0 0 0;
      1 0 1 1 1 1 1 0 0 0;
      1 1 0 0 1 0 0 0 0 0;
      1 1 0 0 0 1 0 0 0 0;
      0 1 1 0 0 0 1 0 1 0;
      0 1 0 1 0 0 0 1 0 0;
      0 1 0 0 1 0 0 1 1 1;
      0 0 0 0 0 1 1 0 0 0;
      0 0 0 0 1 0 1 0 0 1;
      0 0 0 0 0 0 1 0 1 0];
  
d3 = [0 1 1 0 0 0 0 0 0 0;
      1 0 1 1 0 0 0 0 0 0;
      1 1 0 1 1 0 0 0 0 0;
      0 1 1 0 1 1 0 0 0 0;
      0 0 1 1 0 1 1 0 0 0;
      0 0 0 1 1 0 1 1 0 0;
      0 0 0 0 1 1 0 1 1 0;
      0 0 0 0 0 1 1 0 1 1;
      0 0 0 0 0 0 1 1 0 1;
      0 0 0 0 0 0 0 1 1 0];
  
% matrices de adyacencia todos los nodos conectados
d2m1 = [0 1 1 1 0 0 0 0 0 0;
        1 0 1 1 1 1 1 0 0 0;
        1 1 0 0 1 0 0 0 0 0;
        1 1 0 0 0 1 0 0 0 0;
        0 1 1 0 0 0 1 0 1 0;
        0 1 0 1 0 0 1 1 0 0;
        0 1 0 0 1 1 0 1 1 1;
        0 0 0 0 0 1 1 0 0 1;
        0 0 0 0 1 0 1 0 0 1;
        0 0 0 0 0 0 1 1 1 0];
    
% matrices considerando "segundo grado de adyacencia"
d2m2 = [0 1 1 1 0 0 2 0 0 0;
        1 0 1 1 1 1 1 0 0 2;
        1 1 0 0 1 2 0 0 2 0;
        1 1 0 0 2 1 0 2 0 0;
        0 1 1 2 0 0 1 0 1 0;
        0 1 2 1 0 0 1 1 2 0;
        2 1 0 0 1 1 0 1 1 1;
        0 0 0 2 2 1 1 0 0 1;
        0 0 2 0 1 2 1 0 0 1;
        0 2 0 0 0 0 1 1 1 0];
    
d3m1 = [0 1 1 0 2 0 0 0 0 0;
        1 0 1 1 0 2 0 0 0 0;
        1 1 0 1 1 0 2 0 0 0;
        0 1 1 0 1 1 0 2 0 0;
        2 0 1 1 0 1 1 0 2 0;
        0 2 0 1 1 0 1 1 0 2;
        0 0 2 0 1 1 0 1 1 0;
        0 0 0 2 0 1 1 0 1 1;
        0 0 0 0 2 0 1 1 0 1;
        0 0 0 0 0 2 0 1 1 0];
  
dm1 = [0 1 1 2 0 2 0 0 0 0;
      1 0 1 0 1 1 0 2 0 2;
      1 1 0 1 1 0 2 0 2 0;
      2 0 1 0 1 2 1 1 0 0;
      0 1 1 1 0 1 0 1 1 0;
      2 1 0 2 1 0 0 0 1 1;
      0 0 2 1 0 0 0 1 0 0;
      0 2 0 1 1 0 1 0 0 0;
      0 0 2 0 1 1 0 0 0 1;
      0 2 0 0 0 1 0 0 1 0];

dm2 = [0 1 1 2 0 2 0 0 0 0;
      1 0 1 0 1 1 0 2 0 2;
      1 1 0 1 1 0 2 0 2 0;
      2 0 1 0 1 2 1 1 0 0;
      0 1 1 1 0 1 0 1 1 0;
      2 1 0 2 1 0 0 0 1 1;
      0 0 2 1 0 0 0 1 0 0;
      0 2 0 1 1 0 1 0 1 0;
      0 0 2 0 1 1 0 1 0 1;
      0 2 0 0 0 1 0 0 1 0];
  
% matrices considerando "tercer grado de adyacencia"  
dm3 = [0 1 1 2 0 2 3 0 0 3;
      1 0 1 0 1 1 0 2 0 2;
      1 1 0 1 1 0 2 0 2 0;
      2 0 1 0 1 2 1 1 0 0;
      0 1 1 1 0 1 0 1 1 0;
      2 1 0 2 1 0 0 0 1 1;
      3 0 2 1 0 0 0 1 2 3;
      0 2 0 1 1 0 1 0 1 2;
      0 0 2 0 1 1 2 1 0 1;
      3 2 0 0 0 1 3 2 1 0];

t = 0; % inicialización de tiempo
while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j);
            mdist = norm(dist);
            dij = 2*dm3(i,j);
            if(mdist == 0 || dij == 0)
                w = [0; 0];
            else
                w = (mdist - dij).*(dist/mdist);
            end
            E = E + w;
        end
        % actualización de velocidad (aquí se coloca el modelo)
        V(:,i) = -5*E;% - 0.5*(2*randn(2,1)-1);
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