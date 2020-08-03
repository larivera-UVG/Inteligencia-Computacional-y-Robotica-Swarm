% ///////////////////////////////////////////////////////////////////////
% Archivo: muta.m
% Descripción: Implementación del operador de mutación
function nuevo_gen = muta(nuevo_gen, Pm)
[Nind, Lind] = size(nuevo_gen);
valores = rand(Nind, Lind);
muta = valores <= Pm;
nuevo_gen = xor(nuevo_gen, muta);
end