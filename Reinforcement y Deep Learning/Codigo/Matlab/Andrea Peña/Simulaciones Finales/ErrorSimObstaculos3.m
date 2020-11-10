% =========================================================================
% MEDICIÓN DE MÉTRICAS EN LA SIMULACIÓN MODELO DINÁMICO CON CONTROL DE 
% FORMACIÓN, USANDO COSENO HIPERBÓLICO, Y EVASIÓN DE COLISIONES CON EVASIÓN
% DE OBSTÁCULOS, INCLUYENDO LÍMITES DE VELOCIDAD Y CAMBIO DE FORMACIÓN 
% (MODIFICACIÓN DE GRÁFICOS Y DETECCIÓN DE PUNTOS DE CAMBIO)
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 28/08/2019
% (MODELO 6 con obstáculos)
% =========================================================================
% El siguiente script implementa la simulación del modelo dinámico de
% modificación a la ecuación de consenso utilizando evasión de obstáculos y
% luego una combinación de control de formación con una función de coseno 
% hiperbólico para grafos mínimamente rígidos y evasión de colisiones.
% Ahora, con evasión de obstáculos y cambio de formación, detección de
% puntos de cambio y gráficos modificados. 
% =========================================================================


cantI = 50;                     % cantidad de simulaciones a realizar
EI = zeros(1,cantI);            % error inicial de la formación en cada simulación
EIF = zeros(1,cantI);           % error final de la formación en cada simulación
ER = zeros(1,cantI);            % error relativo de la formación en cada simulación
ExitoTotalF = 0;                % cantidad de formaciones 100% exitosas   
cantMeta = 0;                   % llegadas a la meta exitosa
fallos = 0;                     % cantidad de simulaciones fallidas
cambiosForm = zeros(1,cantI);   % cambios de formación por simulación

for I = 1:cantI
    Rig = 8;                    % rigidez de la formación
    conteoCiclos = 500;         % cantidad de ciclos previo al cambio de formación
    
    %% Inicialización del mundo
    gridsize = 40;      % tamaño del mundo
    initsize = 25;
    N = 10;             % número de agentes
    dt = 0.01;          % período de muestreo
    T = 90;             % tiempo final de simulación

    % Inicialización de posición de agentes
    X = initsize*rand(2,N) - initsize/2;
    % X(:,1) = [-2,-2]; % posición del lider

    % Obstáculos
    % O = [-8 -5 2; -10 2 -8];  % posiciones obstáculos Set 1
    % O = [-7 -5 -7; -12 0 12]; % posiciones obstáculos Set 2
    O = [-5 10 -5; -6.5 0 6.5]; % posiciones obstáculos Set 3
    cO = size(O,2);             % cantidad de obstáculos
    sO = 1;                     % tamaño de los obstáculos 

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

    %% Definición e inicialización de las formaciones posibles
    Formaciones = {Fmatrix(1,8), Fmatrix(2,8)}; % celda con posiciones posibles
    FSel = 1;                                   % formación inicial
    iniciarCont = false;                        % bandera de conteo cambio
    contF = 0;                                  % conteo de ciclos para el cambio
    cicloCambio = {};                           % celda para ciclo de cambio
    cantCambios = 0;                            % conteo de cambios de formación
    puntosCambio = {};                          % celda de puntos de cambio
    cantPuntos = 0;                             % cantidad de puntos de cambio
    
    %% Selección matriz y parámetros del sistema
    d = Fmatrix(FSel,1);    % matriz de formación
    r = 1;                  % radio agentes
    R = 15;                 % rango sensor
    VelMax = 10;            % velocidad máxima de los agentes

    %% Inicialización simulación
    t = 0;                      % inicialización de tiempo
    ciclos = 1;                 % cuenta de la cantidad de ciclos 
    Error1 = zeros(1,100*T);    % histórico del error de la formación 1
    Error2 = zeros(1,100*T);    % histórico del error de la formación 2
    cambio = 0;                 % variable para el cambio de control 
    cambio_old = 0;             % variable de cambio anterior
    meta = [-15,0]';            % posición de la meta
    errorF1 = 1;                % 
    conteoCForm = 0;            % conteo del cambio de formación

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
                        case 3              % ha llegado a la meta
                            w = 0;
                            cambio = 1;
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
                E = E + 0.005*w.*distO;
            end

            % Comparación con la velocidad máxima y ajuste
            if(norm(E) > VelMax)    
                ang = atan2(E(2),E(1));
                E(1) = VelMax*cos(ang);
                E(2) = VelMax*sin(ang);
            end
            % Actualización de velocidad
            V(:,i) = -1*E;

            % Movimiento del líder
            if (cambio == 2)
                V(:,1) = V(:,1) + 0.05*([-15,0]'-X(:,1));
            end
        end

        % Al llegar muy cerca de la posición deseada realizar cambio de control
        if(norm(V) < 0.2 && cambio < 2)
            cambio_old = cambio;
            cambio = cambio + 1;
        end
        % Actualización de la posición de los agentes
        X = X + V*dt;

        if(cambio == 2 && cambio_old == 1)
            disp("CAMBIO DE 2 A 1")
            cambio_old = 2;
            mDistF1 = 0.5*DistEntreAgentes(X);
            errorF1 = ErrorForm(mDistF1,Fmatrix(FSel,8));
        end
        
        %% Selección de formación según el error 
        mDist = 0.5*DistEntreAgentes(X);                % distancia actual entre agentes
        Error1(ciclos) = ErrorForm(mDist,Fmatrix(1,8)); % error con formación 1
        Error2(ciclos) = ErrorForm(mDist,Fmatrix(2,8)); % error con formación 2
        FSel_old = FSel;                                % registro de formación anterior
        FSel = SelectForm(Formaciones, mDist);          % selección de formación
        if(FSel ~= FSel_old)
        % cuando la mejor formación ya no es la misma que la actual
            cantPuntos = cantPuntos + 1;            % contador de puntos de cambio
            puntosCambio{cantPuntos} = ciclos;      % almacenamiento puntos de cambio
            iniciarCont = true;                     % iniciar conteo de ciclos
            contF = 0;                              % contador de ciclos
        end
        
        % Conteo de ciclos
        if(iniciarCont)
            contF = contF + 1;
        end
        
        % Hasta que el conteo supere cierta cantidad de ciclos cambiar de
        % formación
        if(contF > conteoCiclos)
            if(iniciarCont == true)
                cantCambios = cantCambios+1;
                cicloCambio{cantCambios} = ciclos*dt;
            end
            d = Fmatrix(FSel,Rig);  % cambio de matriz de formación
            iniciarCont = false;    % reiniciar conteo de ciclos
        end

        % Incremento del tiempo
        t = t + dt;
        ciclos = ciclos + 1;
    end
    
    %% Cálculo del error final
    if(norm(meta-X(:,1))< 2)
        cantMeta = cantMeta + 1;
    end
    
    mDistF2 = 0.5*DistEntreAgentes(X);
    errorF2 = ErrorForm(mDistF2,Fmatrix(FSel,8));
    
    cambiosForm(I) = cantCambios;   % total de cambios de formación
    
    if(cambio == 2)
        EI(I) = errorF1;
        EIF(I) = errorF2;
        ER(I) = errorF2/errorF1;
    else
        fallos = fallos + 1;
    end      
end

EI
EIF
ER
cambiosForm
fallos
cantMeta

% Guardar resultados como resulte más conveniente
xlswrite('ResultadosCambios.xlsx', EI, 1, 'F13')
xlswrite('ResultadosCambios.xlsx', EIF, 1, 'F34')
xlswrite('ResultadosCambios.xlsx', ER, 2, 'F13')
xlswrite('ResultadosCambios.xlsx', fallos, 3, 'E13')
xlswrite('ResultadosCambios.xlsx', cantMeta, 3, 'F13')
xlswrite('ResultadosCambios.xlsx', cambiosForm, 2, 'F34')