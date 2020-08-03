% Universidad Nacional Autónoma de México - Coursera
% Curso de cómputo evolutivo
% Se quiere maximizar la función f(x,y) = 21.5 + xsin(4pix)+ysin(20piy)
% para los rangos: x(-3, 12.1) y y(4.1, 5.8)
%% Definición de parámetros
Nind = 100;  % Número de individuos en la población
Lind = 20;  % Longitud de los individuos
Pc = 0.9;  % Probabilidad de cruzamiento de 60 a 100%
Pm = 0.01;  % Probabilidad de mutación pequeño, menor que 10%
Maxgen = 300;
Nvar = 2;
rango = [-3, 4.1;12.1, 5.8];
Mejor = NaN*ones(Maxgen, 1);
Mejor_cromosoma = zeros(Nind, Lind); %*Nvar);  % Variables de decision codificadas
% tamaño Y = log2((5.8-4.1)*10^4) = 15 bits
% tamaño X = log2((12.1+3)*10^4) = 18 bits
% Entonces el cromosoma/individuo tiene una longitud de 15+18 = 33 bits
% Se redondea al siguiente entero para no perder información
% Decodificación de las variables:
% x = -3+decimal(numbinario)*((12.1+3)/(2^18-1))
% y = 4.1+decimal(numbinario)*((5.8-4.1)/(2^15-1))

%% Algoritmo genético básico
genotipo = creapob(Nind, Lind); % Se crean los 100 individuos en binario, con 20 dígitos cada uno
fenotipo = decodifica(genotipo, rango); % ya en el dominio del problema
objv = objfun(fenotipo); % costo inicial
generaciones = 1;
while generaciones < Maxgen
    aptitud = rankeo(objv, 1);  % Ya todos los valores positivos
    nuevo_gen = ruleta(genotipo, fenotipo, aptitud);
    nuevo_gen = xunpunto(nuevo_gen, Pc);
    nuevo_gen = muta(nuevo_gen, Pm);
    nuevo_feno = decodifica(nuevo_gen, rango);
    nuevo_objv = objfun(nuevo_feno);
    genotipo = nuevo_gen;
    objv = nuevo_objv;
    [valor, idx] = max(objv);
    Mejor(generaciones) = valor;
    Mejor_cromosoma(generaciones, :) = genotipo(idx, :);
    plot(Mejor, 'ro');
    xlabel('generaciones');
    ylabel('log10(f(x))');
    text(0.5, 0.95, ['Mejor = ', num2str(Mejor(generaciones))], 'Units', ...
        'normalized');
    drawnow;
    generaciones = generaciones + 1;
end



















