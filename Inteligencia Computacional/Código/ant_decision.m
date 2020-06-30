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
function next_node = ant_decision(vecinos,alpha,eta,beta,G,id)%
    new_tau = zeros(size(vecinos));
    new_eta = zeros(size(vecinos));
    for f = 1:size(vecinos,1)
        new_tau(f) = G.Edges.Weight(findedge(G,id,vecinos(f)));
        new_eta(f) = G.Edges.Eta(findedge(G,id,vecinos(f))); %eta(str2double(id), str2double(vecinos(f))); % 
    end

    s = size(vecinos,1);
    probabilidad = zeros(s,1); % preallocation
    for v = 1:s
        % calcular probabilidad como en ecuación 17.6
        probabilidad(v,1) = ((new_tau(v,1)^alpha)*(new_eta(v,1)^beta))/(sum((new_tau.^alpha).*(new_eta.^beta)));
    end
    I = rouletteWheel(probabilidad);
    next_node = vecinos(I); % ID del vecino electo
end


