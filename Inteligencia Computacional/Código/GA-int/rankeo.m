% ///////////////////////////////////////////////////////////////////////
% Archivo: rankeo.m
% Descripci�n: Funci�n que asigna el valor de aptitud a cada uno de los
% individuos de la poblaci�n de acuerdo a su posici�n en una lista
% ordenada.
% La aptitud va de 0 a 2, donde el m�s apto tiene 2 y el menos apto 0.
function aptitud = rankeo(objv, direccion)
SP = 2;
[Nind, Nobj] = size(objv);
if direccion == 1
    [nuevo_objv, posori] = sort(objv);
    % Obj ordenado, posici�n original
else
    [nuevo_objv, posori] = sort(-1*objv);
end
apt = 2-SP+2*(SP-1)*((1:Nind)-1)/(Nind-1);
aptitud(posori, 1) = apt';
end