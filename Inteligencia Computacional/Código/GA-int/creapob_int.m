% ///////////////////////////////////////////////////////////////////////
% Archivo: creapob.m
% Descripción: Función crea población inicial
function genotipo = creapob_int(Nind, Lind)
a = 2:Lind+1;
genotipo = zeros(Nind, Lind);
for k = 1:Nind
    genotipo(k, :) = a(randperm(length(a)));
end
end