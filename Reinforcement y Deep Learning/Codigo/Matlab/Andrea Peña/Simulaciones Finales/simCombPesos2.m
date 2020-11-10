% =========================================================================
% SIMULACI�N COMBINACI�N DE CONTROL DE FORMACI�N, EVASI�N DE OBST�CULOS Y
% MANTENIMIENTO DE LA CONECTIVIDAD
% =========================================================================
% Autor: Andrea Maybell Pe�a Echeverr�a
% �ltima modificaci�n: 18/04/2019
% (MODELO 2)
% =========================================================================
% El siguiente script implementa la simulaci�n de la modificaci�n de la 
% ecuaci�n de consenso al combinar en una sola funci�n racional el control
% de formaci�n, evasi�n de obst�culos y mantenimiento de la conectividad.
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

%% Selecci�n matriz y par�metros del sistema
d = Fmatrix(2,8);    % matriz de formaci�n
r = 1;              % radio agentes
R = 10;             % rango sensor

%% Inicializaci�n simulaci�n
t = 0;                      % inicializaci�n de tiempo
ciclos = 1;                 % cuenta de la cantidad de ciclos 
historico = zeros(100*T,N); % hist�rico de velocidades
hX = zeros(100*T,N);        % hist�rico posiciones en X
hY = zeros(100*T,N);        % hist�rico posiciones en Y


while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j); % vector xi - xj
            mdist = norm(dist);    % norma euclidiana vector xi - xj
            dij = 2*d(i,j);        % distancia deseada entre agentes i y j
            
            % Peso a�adido a la ecuaci�n de consenso
            if(mdist == 0)
                w = [0; 0];
            else
                w = -((2*(mdist-dij)*(mdist-r)*(mdist-R))-((2*mdist - r - R)*(mdist-dij)^2))/(mdist*((mdist-r)^2)*((mdist-R)^2));
            end
            % Tensi�n de aristas entre agentes 
            E = E + w.*dist;
        end
        % Actualizaci�n de velocidad
        V(:,i) = -0.5*E;
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

%% Gr�ficos

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
xlabel('Posici�n en eje X (unidades)');
ylabel('Posici�n en eje Y (unidades)');
scatter(Xi(1,:),Xi(2,:),[], 'k');
scatter(X(1,:),X(2,:),[], 'k', 'filled');
hold off;