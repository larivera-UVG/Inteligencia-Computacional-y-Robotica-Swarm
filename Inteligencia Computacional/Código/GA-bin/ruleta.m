% ///////////////////////////////////////////////////////////////////////
% Archivo: ruleta.m
% Descripci�n: Funci�n que implementa el operador de selecci�n de la
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