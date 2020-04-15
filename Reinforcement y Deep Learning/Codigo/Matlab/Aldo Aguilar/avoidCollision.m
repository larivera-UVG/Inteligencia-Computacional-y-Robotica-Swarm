function [output] = avoidCollision(X,V,i,N,dt,repulsion_radius)
    
    output = 0;

    % Restar vector posicion nueva Xi a resto de posiciones X 
    % anteriores para determinr distancia entre ellas
    distancias = X - repmat(X(:,i) + V(:,i)*dt,1,N);

    % Distancia euclidiana de cada vector columna de distancia X de
    % particulas
    % (Se crea un vector binario que indica que particula 1-1000 es
    % colision de una particula i si la distancia es menor al radio).
    colision = sqrt(sum(distancias.^2)) <= repulsion_radius;

    % Se duplica vector binario de vecinos a matriz 2x1 para que esto
    % se utilice como mask para seleccionar (X, Y) de particulas que
    % estan en colision.
    mask2 = repmat(colision,2,1);

    % Suma total de Xs y Ys para determinar si hay una o mas colisiones
    posiciones_colision = sum(distancias .* mask2,2);
    cantidad_colisiones = sum(mask2,2);

    % Cantidad de colisiones debe ser mayor a 1 para ignorar la
    % posicion propia de la particula
    if (cantidad_colisiones(1) > 1)
        % Se corrige la nueva posicion para que particula se ubique en 
        % el centroide entre vecinos que ocupan el area en donde se 
        % debe posicionar dicha particula al moverse
        x_centro = posiciones_colision(1)/cantidad_colisiones(1);
        y_centro = posiciones_colision(2)/cantidad_colisiones(2);
        V(1,i) = -0.03*(1/dt)*(x_centro - X(1,i));
        V(2,i) = -0.03y*(1/dt)*(y_centro - X(2,i));
    end 
end

