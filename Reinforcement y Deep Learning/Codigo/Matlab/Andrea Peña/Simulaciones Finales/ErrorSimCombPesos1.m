% =========================================================================
% MEDICIÓN DE MÉTRICAS EN LA SIMULACIÓN DE COMBINACIÓN ADITIVA DEL CONTROL 
% DE FORMACIÓN Y EVASIÓN DE OBSTÁCULOS
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 15/07/2019
% (Métricas MODELO 1)
% =========================================================================
% El siguiente script implementa la simulación de la modificación de la 
% ecuación de consenso al combinar de manera aditiva las modificaciones
% para el control de formación y la evasión de obstáculos cierto número de
% veces para determinar las métricas de error y cálculos de energía.
% =========================================================================

cantI = 100;                    % cantidad de simulaciones a realizar
EIndividual = zeros(cantI,10);  % energía individual por agente en cada simulación
ETotal = zeros(1,cantI);        % energía total en cada simulación
EI = zeros(1,cantI);            % error individual en cada simulación
ExitoTotalF = 0;                % cantidad de formaciones 100% exitosas
Exito9F = 0;                    % cantidad de formaciones 90% exitosas
Exito8F = 0;                    % cantidad de formaciones 80% exitosas
Exito7F = 0;                    % cantidad de formaciones 70% exitosas
Fail = 0;                       % cantidad de formaciones fallidas

for I = 1:cantI
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

    %% MATRICES DE ADYACENCIA
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

    % matriz totalmente rígida triángulo  
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


    
    %% Inicialización simulación
    t = 0;                      % inicialización de tiempo
    ciclos = 1;                 % cuenta de la cantidad de ciclos 
    historico = zeros(100*T,N); % histórico de velocidades

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

                % Peso añadido a la ecuación de consenso
                if(mdist == 0 || dij == 0)
                    w = [0; 0];
                else
                    w = (mdist - dij).*(dist/mdist);
                end
                w1 = ((2*R - mdist)*dist)/(R - mdist)^2;    % connectivity mantenance
                w2 = ((-2*r + mdist)*dist)/(r - mdist)^2;   % collision avoidance
                % Tensión de aristas entre agentes 
                E = E + 5*w + 0.1*w2; 
            end
            % Actualización de velocidad
            V(:,i) = -0.1*E;
    %         V(:,1) = V(:,1)+0.5; % movimiento del líder
    %         V(:,1) = 0;          % líder inmóvil
        end
        % Actualización de la posición de los agentes
        X = X + V*dt;

        % Almacenamiento de variables a evaluar
        historico(ciclos,:) = (sum(V.^2,1)).^0.5;

        % Actualización de tiempo
        t = t + dt;
        ciclos = ciclos + 1;
    end
    
    %% Cálculo del error final
    mDistF = 0.5*DistEntreAgentes(X);
    errorF = ErrorForm(mDistF,d2r);     % error de formación simulación I
    energiaI = sum(historico.*dt,1);    % energía individual simulación I
    energiaT = sum(energiaI,2);         % energía total simulación I
    
    EIndividual(I,:) = energiaI;
    ETotal(I) = energiaT;
    EI(I) = errorF;
    
    %% Porcentaje éxito formación
    % Una formación se considera exitosa con un error cuadrático medio 
    % menor a 0.05
    if(errorF > 0.05)   
        % Si la formación no fue exitosa se evalua el éxito individual de 
        % de cada agente. Un agente llegó a la posición deseada si tiene un
        % porcentaje de error menor al 15%.
        [errorR,cantAS] = ErrorIndividual(mDistF, d2r, 15);
    else
        % El que la formación haya sido exitosa implica que todos los
        % agentes llegaron a la posición deseada
        errorR = errorF;    % error de formación relativo
        cantAS = N;         % cantidad de agentes que llegan a la posición deseada
    end
    
    %% Porcentaje de agentes en posición deseada
    % Si el error de formación sin tomar en cuenta a los agentes que se
    % alejaron considerablemente, es menor a 0.05 implica que hubo un
    % porcentaje de la formación que sí se logró. 
    if(errorR < 0.05)
        if(cantAS == N)                     % formación 100% exitosa
            ExitoTotalF = ExitoTotalF + 1;
        elseif (cantAS == round(N*0.9))     % formación 90% exitosa
            Exito9F = Exito9F + 1;
        elseif (cantAS == round(N*0.8))     % formación 80% exitosa     
            Exito8F = Exito8F + 1;
        elseif (cantAS == round(N*0.7))     % formacion 70% exitosa
            Exito7F = Exito7F + 1;
        else                                % formación fallida
            Fail = Fail +1;
        end
    else
        Fail = Fail + 1;
    end
        
    VResults = [ExitoTotalF, Exito9F, Exito8F, Exito7F, Fail];
    
end

% Guardar resultados como resulte más conveniente
