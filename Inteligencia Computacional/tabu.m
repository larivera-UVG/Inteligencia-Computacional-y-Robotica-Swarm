% tabu.m
% La necesidad de esta función radica en que las hormigas no pueden
% regresar a los nodos a los que ya fueron (tabu), pero puede llegar a
% pasar que la lista de nodos que sí pueden ser utilizados sea cero,
% entonces necesitamos que esta función agregue al último nodo visitado a
% la lista de vecinos posibles para el nodo.
% Parámetros:
% blocked_nodes (ya recorridos tabu_k) del nodo en forma:
% [x y]
% [x y]
% vecinos originales del nodo en forma:
% [x y]
% [x y]
% last node o último nodo en que se estuvo en forma:
% [x y]
% Output:
% Vecinos updated
% [x y] 
% [x y]
% blocked nodes
% [x y] 
% [x y]

function [vecinos_updated,blocked_nodes,flag] = tabu(vecinos, blocked_nodes, last_node)
    vecinos = setdiff(vecinos,blocked_nodes, 'rows','stable');
    if (isempty(vecinos))
        flag = 0;
        vecinos_updated = last_node;
        id = nodeid(last_node,blocked_nodes);
        blocked_nodes(id,:) = [];
    else
        vecinos_updated = vecinos;
        flag = 1;
    end
end
