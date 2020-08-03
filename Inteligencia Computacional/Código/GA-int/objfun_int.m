% ///////////////////////////////////////////////////////////////////////
% Archivo: objfun.m
% Descripción: Función que evalúa a los individuos de la población
% Aquí definimos el problema a resolver

function objv = objfun_int(fenotipo, G)
[Nind, ~] = size(fenotipo);
objv = zeros(Nind, 1);

for k = 1:Nind
    edge_index = findedge(G, [1, fenotipo(k, 1:end-1)], fenotipo(k, 1:end));
    objv(k, 1) = sum(G.Edges.Weight(edge_index));
end

end