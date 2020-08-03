% ///////////////////////////////////////////////////////////////////////
% Archivo: decodifica.m
% Descripción: Función que mapea el genotipo al fenotipo
% En este caso va de binario a decimal y en el rango de las variables de
% decisión.
function fenotipo = decodifica(genotipo, rango, func)

% Obtenido de:
% https://la.mathworks.com/matlabcentral/answers/25549-convert-floating-point-to-binary
% n = 5;         % number bits for integer part of your number      
% m = 5;         % number bits for fraction part of your number
% if strcmp(func, "Ackley")
%     n = 6; m = 6;
% end
% % d2b = fix(rem(a.*pow2(-(n-1):m),2)); % binary number
% % the inverse transformation
% tam = size(genotipo, 2)/2;
% disp(tam)
% fenotipo = [genotipo(:, 1:tam)*pow2(n-1:-1:-m).', genotipo(:, tam+1:end)*pow2(n-1:-1:-m).'];


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