function nodos = nodes(grid_x,grid_y)
    nodos = zeros(grid_x*grid_y,2); % preallocation
    filas = 1;
    for y = 1:grid_y
        for x = 1:grid_x
            nodos(filas,:) = [x y]; 
            filas = filas + 1;
        end
    end
end