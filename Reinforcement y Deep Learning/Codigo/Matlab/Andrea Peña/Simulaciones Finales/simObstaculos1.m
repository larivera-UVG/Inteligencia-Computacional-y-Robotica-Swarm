% =========================================================================
% SIMULACIÓN MODELO DINÁMICO CON CONTROL DE FORMACIÓN, USANDO COSENO
% HIPERBÓLICO, Y EVASIÓN DE COLISIONES CON EVASIÓN DE OBSTÁCULOS
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 01/04/2019
% (MODELO 5 con obstáculos)
% =========================================================================
% El siguiente script implementa la simulación del modelo dinámico de
% modificación a la ecuación de consenso utilizando evasión de obstáculos y
% luego una combinación de control de formación con una función de coseno 
% hiperbólico para grafos mínimamente rígidos y evasión de obstáculos.
% =========================================================================

%% Inicialización del mundo
gridsize = 20;      % tamaño del mundo
initsize = 20;
N = 10;             % número de agentes
dt = 0.01;          % período de muestreo
T = 30;             % tiempo final de simulación

% Inicialización de posición de agentes
X = initsize*rand(2,N) - initsize/2;
X(:,1) = [-2,-2]; % posición del lider
Xi = X;

% Obstáculos
cO = 2;             % cantidad de obstáculos
O = [-8 -5; -10 2]; % posiciones de los obstáculos
sO = 1;             % tamaño de los obstáculos

cW1 = 2;            % contador de agentes sobre agentes
cW2 = 2;            % contador de agentes sobre obstáculos
while(cW1 > 1 || cW2 > 1)
    cW1 = 0;
    cW2 = 0;
    % Asegurar que los agentes no empiecen uno sobre otro
    contR = 1;      % contador de intersecciones
    while(contR > 0)
        contR = 0;
        for i = 1:N
            for j = 1:(N-i)
                resta = norm(X(:,i)-X(:,i+j));  % diferencia entre las posiciones
                if(abs(resta) < 1)
                    X(:,i+j) = X(:,i+j)+[1,1]'; % cambio de posición
                    contR = contR+1;            % hay intersección
                end
            end
        end
        cW1 = cW1+1;
    end

    % Asegurar que los agentes no empiecen sobre los obstáculos
    contRO = 1;     % contador de intersecciones con obstáculos
    while(contRO > 0)
        contRO = 0;
        for i = 1:N
            for j = 1:cO
                resta = norm(X(:,i)-O(:,j));    % distancia agente obstáculo
                if(abs(resta) < 3.5)
                    X(:,i) = X(:,i)+[1.8,1.8]'; % cambio de posición
                    contRO = contRO+1;          % hay intersección
                end
            end
        end
        cW2 = cW2+1;
    end
end
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
hold on;

obstacles = scatter(O(1,:), O(2,:),sO*2000,'filled');
agents = scatter(X(1,:),X(2,:),[], c, 'filled');
grid minor;
hold off;
xlim([-gridsize/2, gridsize/2]);
ylim([-gridsize/2, gridsize/2]);

%% Selección matriz y parámetros del sistema
d = Fmatrix(2,1);    % matriz de formación
r = 1;               % radio agentes
R = 10;              % rango sensor

%% Inicialización simulación
t = 0;                      % inicialización de tiempo
ciclos = 1;                 % cuenta de la cantidad de ciclos 
historico = zeros(100*T,N); % histórico de velocidades
hX = zeros(100*T,N);        % histórico posiciones en X
hY = zeros(100*T,N);        % histórico posiciones en Y
cambio = 0;                 % variable para el cambio de control

while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j); % vector xi - xj
            mdist = norm(dist);    % norma euclidiana vector xi - xj
            dij = 2*d(i,j);        % distancia deseada entre agentes i y j
            
            % Peso añadido a la ecuación de consenso
            if(mdist == 0 || mdist >= R)
                w = 0;
            else
                switch cambio
                    case 0              % inicio: acercar a los agentes sin chocar
                        w = (mdist - (2*(r + 0.5)))/(mdist - (r + 0.5))^2;
                    case {1,2}
                        if (dij == 0)   % si no hay arista, se usa función "plana" como collision avoidance
                            w = 0.018*sinh(1.8*mdist-8.4)/mdist; 
                        else            % collision avoidance & formation control
                            w = (4*(mdist - dij)*(mdist - r) - 2*(mdist - dij)^2)/(mdist*(mdist - r)^2); 
                        end
                end
            end
            % Tensión de aristas entre agentes 
            E = E + w.*dist;
        end
        
        %% Collision avoidance con los obstáculos
        for j = 1:cO
            distO = X(:,i)- O(:,j);
            mdistO = norm(distO)-3.5;
            if(abs(mdistO) < 0.0001)
                mdistO = 0.0001;
            end
%             w = ((-mdistO*exp(-mdistO+4))-exp(-mdistO+4))/(mdistO^2); 
            w = -1/(mdistO^2 - 2*mdistO + 1);
            E = E + 0.01*w.*distO;
        end
        
        % Actualización de velocidad
        V(:,i) = -1*E; 
        
        % Movimiento del líder
        if (cambio == 2)
            V(:,1) = V(:,1) + 0.1*([3,3]'-X(:,1));
        end
    end
    
    % Al llegar muy cerca de la posición deseada realizar cambio de control
    if(norm(V) < 0.2)
        cambio = cambio + 1;
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
    obstacles;
    pause(dt);
    t = t + dt;
    ciclos = ciclos + 1;
end

%% Gráficos

% velocidad - tiempo
figure(1);
plot(0:dt:T-0.01,historico);
xlabel('Tiempo (segundos)');
ylabel('Velocidad (unidades/segundo)');
ylim([-1,inf]);

% trayectorias
figure(2);
hold on;
plot(hX,hY,'--');
scatter(Xi(1,:),Xi(2,:),[], 'k');
scatter(X(1,:),X(2,:),[], 'k', 'filled');
scatter(O(1,:), O(2,:),sO*2000,'filled');
hold off;