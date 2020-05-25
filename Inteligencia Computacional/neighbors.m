% Esta función retorna los vecinos norte, sur, este y oeste
% del nodo deseado. Estos valores los retorna en forma de lista donde
% tenemos vecinos = [x y; x2 y2; xn yn] donde n es el número de vecinos. En
% los papers y libros esto corresponde a la N chistosa sub i super k.
% Parámetros:
% nodo: vector fila [x y] del nodo en cuestión
% x_lim: límite de 1 a x_lim del grid
% y_lim: límite de 1 a y_lim del grid
function vecinos = neighbors(nodo, x_lim, y_lim)
    movimiento = [1 0;0 1;-1 0;0 -1;-1 1;1 1;-1 -1; 1 -1];
    dir = 0;
    for direccion = 1:size(movimiento,1)
        move_x = nodo(1,1)+movimiento(direccion,1);
        move_y = nodo(1,2)+movimiento(direccion,2);
        if (move_x<= x_lim && move_x>= 1 && move_y<= y_lim && move_y>= 1)
            dir = dir + 1;
            vecinos(dir, :) = [move_x move_y];
        end
    end
end