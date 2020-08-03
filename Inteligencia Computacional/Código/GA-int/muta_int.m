% ///////////////////////////////////////////////////////////////////////
% Archivo: muta.m
% Descripci�n: Implementaci�n del operador de mutaci�n
function nuevo_gen = muta_int(nuevo_gen, Pm)
[Nind, Lind] = size(nuevo_gen);
valores = rand(Nind, 1);
muta = valores <= Pm;
if (~isempty(muta))
    corte = randperm(Lind); % De aqu� sacamos dos posiciones random
    corte = corte(1:2);
    corte = sort(corte);
    nuevo_gen(muta, corte) = fliplr(nuevo_gen(muta, corte));
end

end