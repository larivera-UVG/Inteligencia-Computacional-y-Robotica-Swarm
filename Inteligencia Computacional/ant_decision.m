% Algoritmo 17.1 Artificial Ant Decision Process
% Computational Intelligence an Introduction
% Parámetros:
% tau del nodo en forma de vector columna:
% [x y]
% [x y]
% vecinos del nodo en forma de vector columna:
% [x y]
% [x y]
% Output:
% [x y] que denota el siguiente nodo del trayecto
% Hacer coincidir los id de tau con los feasable nodesb
function next_node = ant_decision(vecinos,tau,alpha,nodos,id)
    next_node = [];
    id_vecinos = nodeid(vecinos,nodos);
    new_tau = zeros(size(id_vecinos));
    for f = 1:size(id_vecinos,1)
        new_tau(f) = tau(id, id_vecinos(f));
    end
    r = rand(1);
    s = size(vecinos,1);
    probabilidad = zeros(s,1); % preallocation
    for v = 1:s
        % calcular probabilidad como en ecuación 17.2
        probabilidad(v,1) = new_tau(v,1)^alpha/sum(new_tau.^alpha);
        if(r <= probabilidad(v,1))
            next_node = vecinos(v,:);
            break;
        end
    end
    if(isempty(next_node))
       [~,I] = max(probabilidad);
       next_node = vecinos(I,:);
    end
end


