function d2b = d2b(x, Lind, rango,func)
% Obtenido de:
% https://la.mathworks.com/matlabcentral/answers/25549-convert-floating-point-to-binary
n = 5;         % number bits for integer part of your number      
m = 5;         % number bits for fraction part of your number
if strcmp(func, "Ackley")
    n = 6; m = 6;
end
a = (x-rango(1))/((2^Lind-1)/(rango(2)-rango(1)));
d2b = fix(rem(a.*pow2(-(n-1):m),2)); % binary number
% the inverse transformation
% b2d = d2b*pow2(n-1:-1:-m).';

end