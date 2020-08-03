% ///////////////////////////////////////////////////////////////////////
% Archivo: creapob.m
% Descripción: Función crea población inicial
function genotipo = creapob(Nind, Lind)
genotipo = 0.5 > rand(Nind, Lind);
end