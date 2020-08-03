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
function next_node = ant_decision(vecinos, alpha, beta, G, id)
index_edges = findedge(G, repmat(convertCharsToStrings(id), size(vecinos)), vecinos);
tau = G.Edges.Weight(index_edges);
eta = G.Edges.Eta(index_edges);
w = tau.^alpha.*eta.^beta;
probabilidad = w/sum(w);
I = rouletteWheel(probabilidad);
next_node = vecinos(I); % ID del vecino electo
end


