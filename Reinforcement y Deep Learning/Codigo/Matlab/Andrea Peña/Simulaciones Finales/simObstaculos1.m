% =========================================================================
% SIMULACI�N MODELO DIN�MICO CON CONTROL DE FORMACI�N, USANDO COSENO
% HIPERB�LICO, Y EVASI�N DE COLISIONES CON EVASI�N DE OBST�CULOS
% =========================================================================
% Autor: Andrea Maybell Pe�a Echeverr�a
% �ltima modificaci�n: 01/04/2019
% (MODELO 5 con obst�culos)
% =========================================================================
% El siguiente script implementa la simulaci�n del modelo din�mico de
% modificaci�n a la ecuaci�n de consenso utilizando evasi�n de obst�culos y
% luego una combinaci�n de control de formaci�n con una funci�n de coseno 
% hiperb�lico para grafos m�nimamente r�gidos y evasi�n de obst�culos.
% =========================================================================

%% Inicializaci�n del mundo
gridsize = 20;      % tama�o del mundo
initsize = 20;
N = 10;             % n�mero de agentes
dt = 0.01;          % per�odo de muestreo
T = 30;             % tiempo final de simulaci�n

% Inicializaci�n de posici�n de agentes
X = initsize*rand(2,N) - initsize/2;
X(:,1) = [-2,-2]; % posici�n del lider
Xi = X;

% Obst�culos
cO = 2;             % cantidad de obst�culos
O = [-8 -5; -10 2]; % posiciones de los obst�culos
sO = 1;             % tama�o de los obst�culos

cW1 = 2;            % contador de agentes sobre agentes
cW2 = 2;            % contador de agentes sobre obst�culos
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
                    X(:,i+j) = X(:,i+j)+[1,1]'; % cambio de posici�n
                    contR = contR+1;            % hay intersecci�n
                end
            end
        end
        cW1 = cW1+1;
    end

    % Asegurar que los agentes no empiecen sobre los obst�culos
    contRO = 1;     % contador de intersecciones con obst�culos
    while(contRO > 0)
        contRO = 0;
        for i = 1:N
            for j = 1:cO
                resta = norm(X(:,i)-O(:,j));    % distancia agente obst�culo
                if(abs(resta) < 3.5)
                    X(:,i) = X(:,i)+[1.8,1.8]'; % cambio de posici�n
                    contRO = contRO+1;          % hay intersecci�n
                end
            end
        end
        cW2 = cW2+1;
    end
end
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
hold on;

obstacles = scatter(O(1,:), O(2,:),sO*2000,'filled');
agents = scatter(X(1,:),X(2,:),[], c, 'filled');
grid minor;
hold off;
xlim([-gridsize/2, gridsize/2]);
ylim([-gridsize/2, gridsize/2]);

%% Selecci�n matriz y par�metros del sistema
d = Fmatrix(2,1);    % matriz de formaci�n
r = 1;               % radio agentes
R = 10;              % rango sensor

%% Inicializaci�n simulaci�n
t = 0;                      % inicializaci�n de tiempo
ciclos = 1;                 % cuenta de la cantidad de ciclos 
historico = zeros(100*T,N); % hist�rico de velocidades
hX = zeros(100*T,N);        % hist�rico posiciones en X
hY = zeros(100*T,N);        % hist�rico posiciones en Y
cambio = 0;                 % variable para el cambio de control

while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j); % vector xi - xj
            mdist = norm(dist);    % norma euclidiana vector xi - xj
            dij = 2*d(i,j);        % distancia deseada entre agentes i y j
            
            % Peso a�adido a la ecuaci�n de consenso
            if(mdist == 0 || mdist >= R)
                w = 0;
            else
                switch cambio
                    case 0              % inicio: acercar a los agentes sin chocar
                        w = (mdist - (2*(r + 0.5)))/(mdist - (r + 0.5))^2;
                    case {1,2}
                        if (dij == 0)   % si no hay arista, se usa funci�n "plana" como collision avoidance
                            w = 0.018*sinh(1.8*mdist-8.4)/mdist; 
                        else            % collision avoidance & formation control
                            w = (4*(mdist - dij)*(mdist - r) - 2*(mdist - dij)^2)/(mdist*(mdist - r)^2); 
                        end
                end
            end
            % Tensi�n de aristas entre agentes 
            E = E + w.*dist;
        end
        
        %% Collision avoidance con los obst�culos
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
        
        % Actualizaci�n de velocidad
        V(:,i) = -1*E; 
        
        % Movimiento del l�der
        if (cambio == 2)
            V(:,1) = V(:,1) + 0.1*([3,3]'-X(:,1));
        end
    end
    
    % Al llegar muy cerca de la posici�n deseada realizar cambio de control
    if(norm(V) < 0.2)
        cambio = cambio + 1;
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
    obstacles;
    pause(dt);
    t = t + dt;
    ciclos = ciclos + 1;
end

%% Gr�ficos

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