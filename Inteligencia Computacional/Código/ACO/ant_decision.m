% Algoritmo 17.1 Artificial Ant Decision Process
% Computational Intelligence an Introduction
% Parámetros:
% alpha y beta son constantes definidas en el main
% G es el grafo
% id es el id del current node, tipo string. ejemplo:
% "1"
% vecinos del nodo tipo string array. ejemplo:
% ["2"]
% ["11"]
% ["12"]
% Output:
% String con el id del siguiente nodo del trayecto. ejemplo:
% "3"
function next_node = ant_decision(vecinos, alpha, beta, G, id)
index_edges = findedge(G, repmat(convertCharsToStrings(id), size(vecinos)), vecinos);
tau = G.Edges.Weight(index_edges);
eta = G.Edges.Eta(index_edges);
w = tau.^alpha.*eta.^beta;
probabilidad = w/sum(w);
I = rouletteWheel(probabilidad);
next_node = vecinos(I); % ID del vecino electo
end


