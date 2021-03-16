gridsize = 20; % tama�o del mundo
initsize = 20;
N = 10; % n�mero de agentes
dt = 0.01; % per�odo de muestreo
T = 5; % tiempo final de simulaci�n

% Inicializaci�n de posici�n de agentes
X = initsize*rand(2,N) - initsize/2;
X(:,1) = [0,0]; % posici�n del lider
Xi = X;

% Inicializaci�n de velocidad de agentes
% V = rand(2, N)-0.5; % aleatorio
V = zeros(2, N); % ceros

% Se grafica la posici�n inicial de los agentes
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

d = Fmatrix(1,8) %matriz de formaci�n
r = 1; %radio agentes
R = 10; %rango sensor

t = 0; % inicializaci�n de tiempo
ciclos = 1; % cuenta de la cantidad de ciclos 
historico = zeros(100*T,N); % hist�rico de velocidades
hX = zeros(100*T,N);
hY = zeros(100*T,N);

while(t < T)
    for i = 1:N
        E = 0;
        for j = 1:N
            dist = X(:,i)- X(:,j);
            mdist = norm(dist);
%             dij = 2*d(i,j);
            if(mdist == 0)
                w = [0; 0];
            else
                w = 396*((2*mdist - R - r)/(mdist*(r - R)^2));
            end
            E = E + w.*dist;
        end
        % actualizaci�n de velocidad (aqu� se coloca el modelo)
        V(:,i) = -0.1*E; % - 0.5*(2*randn(2,1)-1);
%         V(:,1) = V(:,1)+0.5;
%         V(:,1) = 0;
    end
    X = X + V*dt; % actualizaci�n de la posici�n de los agentes
    for a = 1:N
        hX(ciclos,a)= X(1,a);
        hY(ciclos,a)= X(2,a);
    end
    historico(ciclos,:) = sum(V,1);
    % Se actualiza la gr�fica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    pause(dt);
    t = t + dt;
    ciclos = ciclos + 1;
end

figure(1);
plot(0:dt:T,historico);
figure(2);
hold on;
plot(hX,hY,'--');
scatter(Xi(1,:),Xi(2,:),[], 'k');
scatter(X(1,:),X(2,:),[], 'k', 'filled');
hold off;