% loop_remover.m
% 26/04/2020 - 27/06/2020
% Gabriela Iriarte
% Este programa le quita los loops a los paths dados.
% Parámetros:
% path_w_loops = array tipo columna con los índices de los nodos que
% conforman el path:
% [ '1' ]
% [ '2' ]
% [ ... ]
% [ 'n' ]

function corregido = loop_remover(path_w_loops)

reversed_path = zeros(size(path_w_loops));
node = 1;

% flip(1:5) produce 5 4 3 2 1
% Entonces empezamos en el nodo final
for r = flip(1:size(path_w_loops, 1))
    if (node == 1)
        reversed_path(node, :) = path_w_loops(r, :);
        node = node + 1;
    end
    % ¿Pertenece x al path with loops?
    [LIA, indxtemp] = ismember(path_w_loops(r, :), reversed_path, 'rows');
    if (LIA ~= 0)
        reversed_path(indxtemp:size(reversed_path, 1), :) = [];
        node = size(reversed_path, 1) + 1;
    end
    reversed_path(node, :) = path_w_loops(r, :);
    node = node + 1;
end

corregido = flip(reversed_path);


end