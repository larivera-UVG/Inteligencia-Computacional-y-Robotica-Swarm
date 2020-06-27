% nodes.m
% Esta función crea los nodos según un tamaño de grid dado
% Devuelve un vector de grid_x*grid_y filas y 2 columnas

function nodos = nodes(grid_x,grid_y)
    [X, Y] = meshgrid(1:grid_x, 1:grid_y);
    nodos = [reshape(Y, [grid_x*grid_y, 1]), reshape(X, [grid_x*grid_y, 1])];
end