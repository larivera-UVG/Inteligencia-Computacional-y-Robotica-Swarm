% ///////////////////////////////////////////////////////////////////////
% Archivo: decodifica.m
% Descripción: Función que mapea el genotipo al fenotipo
% En este caso va de binario a decimal y en el rango de las variables de
% decisión.
function fenotipo = decodifica(genotipo, rango)
Nvar = size(rango, 2);  % Dos variables independientes: X, Y
[Nind, Lind] = size(genotipo);
Lvar = Lind/Nvar;
potencias = 2.^(0:Lvar-1);
for i=1:Nind
    for j=1:Nvar
        fenotipo(i,j) = sum(potencias.*genotipo(i, (j-1)*Lvar+1:j*Lvar));
    end
end
for i=1:Nvar
    fenotipo(:, i) = rango(1, i) + ((rango(2,i)-rango(1,i))/(2^Lvar-1))*fenotipo(:,i);
end
end