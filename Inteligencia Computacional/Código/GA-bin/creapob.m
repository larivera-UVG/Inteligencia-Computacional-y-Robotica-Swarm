% ///////////////////////////////////////////////////////////////////////
% Archivo: creapob.m
% Descripci�n: Funci�n crea poblaci�n inicial
function genotipo = creapob(Nind, Lind)
genotipo = 0.5 > rand(Nind, Lind);
end