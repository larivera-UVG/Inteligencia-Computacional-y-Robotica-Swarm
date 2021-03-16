cantI = 100;
EI = zeros(1,cantI);
success = 0;

for I = 1:cantI
    gridsize = 20; % tamaño del mundo
    initsize = 20;
    N = 10; % número de agentes
    dt = 0.01; % período de muestreo
    T = 20; % tiempo final de simulación

    % Inicialización de posición de agentes
    X = initsize*rand(2,N) - initsize/2;
    X(:,1) = [0,0]; % posición del lider
    Xi = X;

    % Inicialización de velocidad de agentes
    % V = rand(2, N)-0.5; % aleatorio
    V = zeros(2, N); % ceros

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

   
    d2 = [0 1 1 0 1 0 0 0 0 0;
          1 0 0 0 1 1 0 0 0 0;
          1 0 0 1 1 0 0 0 0 0;
          0 0 1 0 1 0 1 1 0 0;
          1 1 1 1 0 1 0 1 0 0;
          0 1 0 0 1 0 0 1 0 1;
          0 0 0 1 0 0 0 1 1 0;
          0 0 0 1 1 1 1 0 1 1;
          0 0 0 0 0 0 1 1 0 1;
          0 0 1 0 0 1 0 1 1 0];

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
    d2m2 = [0 1 1 0 1 0 0 2 0 0;
           1 0 0 2 1 1 0 0 0 2;
           1 0 0 1 1 2 2 0 0 0;
           0 2 1 0 1 0 1 1 0 2;
           1 1 1 1 0 1 0 1 2 0;
           0 1 2 0 1 0 2 1 0 1;
           0 0 2 1 0 2 0 1 1 0;
           2 0 0 1 1 1 1 0 1 1;
           0 0 0 0 2 0 1 1 0 1;
           0 2 0 2 0 1 0 1 1 0];

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
      
    d2m3 = [0 1 1 0 1 0 0 2 3 0;
           1 0 0 2 1 1 0 0 0 2;
           1 0 0 1 1 2 2 0 0 0;
           0 2 1 0 1 0 1 1 0 2;
           1 1 1 1 0 1 0 1 2 0;
           0 1 2 0 1 0 2 1 0 1;
           0 0 2 1 0 2 0 1 1 0;
           2 0 0 1 1 1 1 0 1 1;
           3 0 0 0 2 0 1 1 0 1;
           0 2 0 2 0 1 0 1 1 0];

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

    t = 0; % inicialización de tiempo
    ciclos = 1; % cuenta de la cantidad de ciclos 

    while(t < T)
        for i = 1:N
            E = 0;
            for j = 1:N
                dist = X(:,i)- X(:,j);
                mdist = norm(dist);
                dij = 2*d2r(i,j);
                if(mdist == 0 || dij == 0)
                    w = 0;
                else
                    w = (mdist - dij)/mdist;
                end
                E = E + w.*dist;
            end
            % actualización de velocidad (aquí se coloca el modelo)
            V(:,i) = -0.52*E;% - 0.5*(2*randn(2,1)-1);
    %         V(:,1) = V(:,1)+0.1;
        end
        X = X + V*dt; % actualización de la posición de los agentes

        % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
        % tiempo
        pause(dt);
        t = t + dt;
        ciclos = ciclos + 1;
    end

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
    scatter(X(1,:),X(2,:),[], c, 'filled');
    
    %Cálculo del error final
    mDistF = 0.5*DistEntreAgentes(X);
    errorF = ErrorForm(mDistF,d2r);

    EI(I) = errorF
    
    if(errorF < 0.001)
        success = success + 1;
    end
end

save Error2G2_simFor1_d2r.mat EI
