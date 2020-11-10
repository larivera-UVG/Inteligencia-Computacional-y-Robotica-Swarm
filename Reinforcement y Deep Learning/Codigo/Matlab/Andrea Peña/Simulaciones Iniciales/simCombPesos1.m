gridsize = 20; % tamaño del mundo
initsize = 20;
N = 10; % número de agentes
dt = 0.01; % período de muestreo
T = 1; % tiempo final de simulación

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
   
d2m3 = [0 1 1 1 0 0 2 0 0 3;
        1 0 1 1 1 1 1 0 0 2;
        1 1 0 0 1 2 0 0 2 0;
        1 1 0 0 2 1 0 2 0 0;
        0 1 1 2 0 0 1 2 1 0;
        0 1 2 1 0 0 1 1 2 0;
        2 1 0 0 1 1 0 1 1 1;
        0 0 0 2 2 1 1 0 0 1;
        0 0 2 0 1 2 1 0 0 1;
        3 2 0 0 0 0 1 1 1 0];

d0 = 2*sqrt(0.75);
 
dr1 = [0 1 1 2 d0 2 3 0 0 3;
       1 0 1 d0 1 1 0 2 d0 2;
       1 1 0 1 1 d0 2 d0 2 0;
       2 d0 1 0 1 2 1 1 d0 0;
       d0 1 1 1 0 1 d0 1 1 d0;
       2 1 d0 2 1 0 0 d0 1 1;
       3 0 2 1 d0 0 0 1 2 3;
       0 2 d0 1 1 d0 1 0 1 2;
       0 d0 2 d0 1 1 2 1 0 1;
       3 2 0 0 d0 1 3 2 1 0];

b0 = sqrt((1.5*d0)^2 + 0.25);
   
dr2 = [0 1 1 2 d0 2 3 b0 b0 3;
       1 0 1 d0 1 1 0 2 d0 2;
       1 1 0 1 1 d0 2 d0 2 0;
       2 d0 1 0 1 2 1 1 d0 0;
       d0 1 1 1 0 1 d0 1 1 d0;
       2 1 d0 2 1 0 0 d0 1 1;
       3 0 2 1 d0 0 0 1 2 3;
       b0 2 d0 1 1 d0 1 0 1 2;
       b0 d0 2 d0 1 1 2 1 0 1;
       3 2 0 0 d0 1 3 2 1 0];

b1 = sqrt(d0^2 + 4);
   
dr3 = [0 1 1 2 d0 2 3 b0 b0 3;
       1 0 1 d0 1 1 b1 2 d0 2;
       1 1 0 1 1 d0 2 d0 2 b1;
       2 d0 1 0 1 2 1 1 d0 0;
       d0 1 1 1 0 1 d0 1 1 d0;
       2 1 d0 2 1 0 0 d0 1 1;
       3 b1 2 1 d0 0 0 1 2 3;
       b0 2 d0 1 1 d0 1 0 1 2;
       b0 d0 2 d0 1 1 2 1 0 1;
       3 2 b1 0 d0 1 3 2 1 0];

b2 = sqrt((0.5*d0)^2 + 2.5^2);

% Matriz completamente rígida
dr4 = [0 1 1 2 d0 2 3 b0 b0 3;
       1 0 1 d0 1 1 b1 2 d0 2;
       1 1 0 1 1 d0 2 d0 2 b1;
       2 d0 1 0 1 2 1 1 d0 b2;
       d0 1 1 1 0 1 d0 1 1 d0;
       2 1 d0 2 1 0 b2 d0 1 1;
       3 b1 2 1 d0 b2 0 1 2 3;
       b0 2 d0 1 1 d0 1 0 1 2;
       b0 d0 2 d0 1 1 2 1 0 1;
       3 2 b1 b2 d0 1 3 2 1 0];
   
d2r = [0 1 1 1 d0 d0 2 b2 b2 3;
       1 0 1 1 1 1 1 d0 d0 2;
       1 1 0 d0 1 2 d0 b1 2 b2;
       1 1 d0 0 2 1 d0 2 b1 b2;
       d0 1 1 2 0 d0 1 2 1 d0;
       d0 1 2 1 d0 0 1 1 2 d0;
       2 1 d0 d0 1 1 0 1 1 1;
       b2 d0 b1 2 2 1 1 0 d0 1;
       b2 d0 2 b1 1 2 1 d0 0 1;
       3 2 b2 b2 d0 d0 1 1 1 0];

delta1 = 5;
delta2 = 1;

t = 0; % inicialización de tiempo
ciclos = 1; % cuenta de la cantidad de ciclos 
historico = zeros(100*T,N); % histórico de velocidades

while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j);
            mdist = norm(dist);
%             mdist = sqrt((X(1,i) - X(1,j))^2 + (X(2,i) - X(2,j))^2)
            dij = 2*d2r(i,j);
            if(mdist == 0 || dij == 0)
                w = [0; 0];
            else
                w = (mdist - dij).*(dist/mdist);
            end
            w1 = ((2*delta1 - mdist)*dist)/(delta1 - mdist)^2;
            w2 = ((-2*delta2 + mdist)*dist)/(delta2 - mdist)^2;
            E = E + 5*w + 0.1*w2; %+ 0.0005*w1
        end
        % actualización de velocidad (aquí se coloca el modelo)
        V(:,i) = -0.5*E; % - 0.5*(2*randn(2,1)-1);
%         V(:,1) = V(:,1)+0.5;
%         V(:,1) = 0;
    end
    X = X + V*dt; % actualización de la posición de los agentes
    historico(ciclos,:) = sum(V,1);
    % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    pause(dt);
    t = t + dt;
    ciclos = ciclos + 1;
end

plot(historico)