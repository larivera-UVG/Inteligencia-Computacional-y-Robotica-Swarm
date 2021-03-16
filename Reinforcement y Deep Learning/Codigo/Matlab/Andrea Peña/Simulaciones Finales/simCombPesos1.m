% =========================================================================
% SIMULACI�N COMBINACI�N ADITIVA DEL CONTROL DE FORMACI�N Y EVASI�N DE
% OBST�CULOS
% =========================================================================
% Autor: Andrea Maybell Pe�a Echeverr�a
% �ltima modificaci�n: 01/04/2019
% (MODELO 1)
% =========================================================================
% El siguiente script implementa la simulaci�n de la modificaci�n de la 
% ecuaci�n de consenso al combinar de manera aditiva las modificaciones
% para el control de formaci�n y la evasi�n de obst�culos.
% =========================================================================

%% Inicializaci�n del mundo
gridsize = 20;      % tama�o del mundo
initsize = 20;
N = 10;             % n�mero de agentes
dt = 0.01;          % per�odo de muestreo
T = 20;             % tiempo final de simulaci�n

% Inicializaci�n de posici�n de agentes
X = initsize*rand(2,N) - initsize/2;
X(:,1) = [0,0];     % posici�n del lider
Xi = X;

% Inicializaci�n de velocidad de agentes
% V = rand(2, N)-0.5; % aleatorio
V = zeros(2, N); % ceros

%% Se grafica la posici�n inicial de los agentes
%  Se utiliza distinci�n de color por grupos de agentes
%    Rojo:    l�der
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

%% MATRICES DE ADYACENCIA
% matrices de adyacencia grafo m�nimamente r�gido
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

% matriz totalmente r�gida tri�ngulo  
d0 = 2*sqrt(0.75);
b0 = sqrt((1.5*d0)^2 + 0.25);
b1 = sqrt(d0^2 + 4);
b2 = sqrt((0.5*d0)^2 + 2.5^2);

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
   
d2r = [0 1 1 d0 1 d0 b2 2 3 b2;
       1 0 d0 2 1 1 b1 d0 b2 2;
       1 d0 0 1 1 2 2 d0 b2 b1;
       d0 2 1 0 1 d0 1 1 d0 2;
       1 1 1 1 0 1 d0 1 2 d0;
       d0 1 2 d0 1 0 2 1 d0 1;
       b2 b1 2 1 d0 2 0 1 1 d0;
       2 d0 d0 1 1 1 1 0 1 1;
       3 b2 b2 d0 2 d0 1 1 0 1;
       b2 2 b1 2 d0 1 d0 1 1 0];

%% Inicializaci�n simulaci�n
t = 0;                      % inicializaci�n de tiempo
ciclos = 1;                 % cuenta de la cantidad de ciclos 
historico = zeros(100*T,N); % hist�rico de velocidades
hX = zeros(100*T,N);        % hist�rico posiciones en X
hY = zeros(100*T,N);        % hist�rico posiciones en Y

% Propiedades agentes
R = 10; % Rango del radar
r = 1;  % Radio de los agentes

while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j); % vector xi - xj
            mdist = norm(dist);    % norma euclidiana vector xi - xj
            dij = 2*d2r(i,j);      % distancia deseada entre agentes i y j
            
            % Peso a�adido a la ecuaci�n de consenso
            if(mdist == 0 || dij == 0)
                w = [0; 0];
            else
                w = (mdist - dij).*(dist/mdist);
            end
            w1 = ((2*R - mdist)*dist)/(R - mdist)^2;    % connectivity mantenance
            w2 = ((-2*r + mdist)*dist)/(r - mdist)^2;   % collision avoidance
            % Tensi�n de aristas entre agentes 
            E = E + 5*w + 0.1*w2; 
        end
        % Actualizaci�n de velocidad
        V(:,i) = -0.1*E;
%         V(:,1) = V(:,1)+0.5; % movimiento del l�der
%         V(:,1) = 0;          % l�der inm�vil
    end
    % Actualizaci�n de la posici�n de los agentes
    X = X + V*dt; 
    
    % Almacenamiento de variables para graficar
    for a = 1:N
        hX(ciclos,a)= X(1,a);
        hY(ciclos,a)= X(2,a);
    end
    historico(ciclos,:) = (sum(V.^2,1)).^0.5;
    
    % Se actualiza la gr�fica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    pause(dt);
    t = t + dt;
    ciclos = ciclos + 1;
end

% C�lculo de energ�a
EIndividual = sum(historico.*dt,1)
ETotal = sum(EIndividual,2)

%% Gr�ficos

% velocidad - tiempo
figure(1);
plot(0:dt:T-dt,historico);
xlabel('Tiempo (segundos)');
ylabel('Velocidad (unidades/segundo)');
ylim([-1,inf])
figure(2);
hold on;

% trayectorias
plot(hX,hY,'--');
xlabel('Posici�n en eje X (unidades)');
ylabel('Posici�n en eje Y (unidades)');
scatter(Xi(1,:),Xi(2,:),[], 'k');
scatter(X(1,:),X(2,:),[], 'k', 'filled');
hold off;