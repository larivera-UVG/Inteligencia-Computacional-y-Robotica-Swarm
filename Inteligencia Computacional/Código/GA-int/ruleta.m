% ///////////////////////////////////////////////////////////////////////
% Archivo: ruleta.m
% Descripción: Función que implementa el operador de selección de la
% ruleta.

function nuevo_gen = ruleta(genotipo, fenotipo, aptitud)
[Nind, aux] = size(aptitud);
total = sum(aptitud);
probabilidad = aptitud/total;
acumulada = cumsum(probabilidad);
for i = 1:Nind
    selecciona = rand;
    aux = find(acumulada >= selecciona);
    idx(i, 1) = aux(1);
end
nuevo_gen = genotipo(idx, :);
end