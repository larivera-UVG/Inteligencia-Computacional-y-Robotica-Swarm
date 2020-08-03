% ///////////////////////////////////////////////////////////////////////
% Archivo: objfun.m
% Descripci�n: Funci�n que eval�a a los individuos de la poblaci�n
% Aqu� definimos el problema a resolver

function objv = objfun_int(fenotipo, G)
[Nind, ~] = size(fenotipo);
objv = zeros(Nind, 1);

for k = 1:Nind
    edge_index = findedge(G, [1, fenotipo(k, 1:end-1)], fenotipo(k, 1:end));
    objv(k, 1) = sum(G.Edges.Weight(edge_index));
end

end