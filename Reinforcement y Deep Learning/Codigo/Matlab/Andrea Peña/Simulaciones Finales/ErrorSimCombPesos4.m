% =========================================================================
% MEDICI�N DE M�TRICAS EN LA SIMULACI�N DE COMBINACI�N DE CONTROL DE 
% FORMACI�N Y EVASI�N DE OBST�CULOS
% =========================================================================
% Autor: Andrea Maybell Pe�a Echeverr�a
% �ltima modificaci�n: 18/07/2019
% (M�tricas MODELO 3)
% =========================================================================
% El siguiente script implementa la simulaci�n de la modificaci�n de la 
% ecuaci�n de consenso al combinar en una sola funci�n racional el control
% de formaci�n y evasi�n de obst�culos cierto n�mero de veces para 
% determinar las m�tricas de error y c�lculos de energ�a.
% =========================================================================

cantI = 100;                    % cantidad de simulaciones a realizar
EIndividual = zeros(cantI,10);  % energ�a individual por agente en cada simulaci�n
ETotal = zeros(1,cantI);        % energ�a total en cada simulaci�n
EI = zeros(1,cantI);            % error individual en cada simulaci�n
ExitoTotalF = 0;                % cantidad de formaciones 100% exitosas
Exito9F = 0;                    % cantidad de formaciones 90% exitosas
Exito8F = 0;                    % cantidad de formaciones 80% exitosas
Exito7F = 0;                    % cantidad de formaciones 70% exitosas
Fail = 0;                       % cantidad de formaciones fallidas

for I = 1:cantI
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

    %% Selecci�n matriz y par�metros del sistema
    Form = 2;               % grafo seleccionado
    Rig = 8;                % rigidez formaci�n
    d = Fmatrix(Form,Rig);  % matriz de formaci�n
    r = 1;                  % radio agentes
    R = 10;                 % rango sensor
    
    %% Inicializaci�n simulaci�n
    t = 0;                      % inicializaci�n de tiempo
    ciclos = 1;                 % cuenta de la cantidad de ciclos 
    historico = zeros(100*T,N); % hist�rico de velocidades

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
                    w = (4*(mdist - dij)*(mdist - r) - 2*(mdist - dij)^2)/(mdist^3); % collision avoidance & formation control
    %                 w = (4*(mdist - dij)*(mdist - r) - 2*(mdist - dij)^2)/(mdist*(mdist - r)^2); % collision avoidance & formation control
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

        % Almacenamiento de variables
        historico(ciclos,:) = (sum(V.^2,1)).^0.5;
        
        % Actualizaci�n de tiempo
        t = t + dt;
        ciclos = ciclos + 1;
    end

    
    %% C�lculo del error final
    mDistF = 0.5*DistEntreAgentes(X);
    errorF = ErrorForm(mDistF,d2r);     % error de formaci�n simulaci�n I
    energiaI = sum(historico.*dt,1);    % energ�a individual simulaci�n I
    energiaT = sum(energiaI,2);         % energ�a total simulaci�n I
    
    EIndividual(I,:) = energiaI;
    ETotal(I) = energiaT;
    EI(I) = errorF;
    
    %% Porcentaje �xito formaci�n
    % Una formaci�n se considera exitosa con un error cuadr�tico medio 
    % menor a 0.05
    if(errorF > 0.05)   
        % Si la formaci�n no fue exitosa se evalua el �xito individual de 
        % de cada agente. Un agente lleg� a la posici�n deseada si tiene un
        % porcentaje de error menor al 15%.
        [errorR,cantAS] = ErrorIndividual(mDistF, Fmatrix(Form,8), 15);
    else
        % El que la formaci�n haya sido exitosa implica que todos los
        % agentes llegaron a la posici�n deseada
        errorR = errorF;    % error de formaci�n relativo
        cantAS = N;         % cantidad de agentes que llegan a la posici�n deseada
    end
    
    %% Porcentaje de agentes en posici�n deseada
    % Si el error de formaci�n sin tomar en cuenta a los agentes que se
    % alejaron considerablemente, es menor a 0.05 implica que hubo un
    % porcentaje de la formaci�n que s� se logr�. 
    if(errorR < 0.05)
        if(cantAS == N)                     % formaci�n 100% exitosa
            ExitoTotalF = ExitoTotalF + 1;
        elseif (cantAS == round(N*0.9))     % formaci�n 90% exitosa
            Exito9F = Exito9F + 1;
        elseif (cantAS == round(N*0.8))     % formaci�n 80% exitosa     
            Exito8F = Exito8F + 1;
        elseif (cantAS == round(N*0.7))     % formacion 70% exitosa
            Exito7F = Exito7F + 1;
        else                                % formaci�n fallida
            Fail = Fail +1;
        end
    else
        Fail = Fail + 1;
    end
        
    VResults = [ExitoTotalF, Exito9F, Exito8F, Exito7F, Fail];
end

% Guardar resultados como resulte m�s conveniente
