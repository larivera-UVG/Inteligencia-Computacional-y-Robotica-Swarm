% ///////////////////////////////////////////////////////////////////////
% Archivo: muta.m
% Descripci�n: Implementaci�n del operador de mutaci�n
function nuevo_gen = muta(nuevo_gen, Pm)
[Nind, Lind] = size(nuevo_gen);
valores = rand(Nind, Lind);
muta = valores <= Pm;
nuevo_gen = xor(nuevo_gen, muta);
end