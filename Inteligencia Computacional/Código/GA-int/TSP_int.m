% Universidad Nacional Autónoma de México - Coursera
% Curso de cómputo evolutivo
% http://elib.zib.de/pub/mp-testdata/tsp/tsplib/tsp/gr24.tsp
% 19/07/2020
% Traveling Salesman Problem
%% Definición de parámetros
load('Groetschel')
Nind = 100;
G = graph(B);
plot(G)
Lind = 23;  % Longitud de los individuos 
Pc = 0.9;  % Probabilidad de cruzamiento de 60 a 100%
Pm = 0.05;  % Probabilidad de mutación pequeño, menor que 10%
Maxgen = 200;
Nvar = 23;  % La ciudad 1 es fija, entonces esa no se considera
Mejor = NaN*ones(Maxgen, 1); % Vector columna con el mejor de cada generación
Mejor_cromosoma = zeros(Nind, Lind);  % Variables de decision codificadas

%% Algoritmo genético básico
genotipo = creapob_int(Nind, Lind); % Se crean los individuos
% fenotipo = decodifica(genotipo, rango); % ya en el dominio del problema
fenotipo = genotipo;
objv = objfun_int(fenotipo, G); % costo inicial
generaciones = 1;
while generaciones < Maxgen
    aptitud = rankeo(objv, 2);  % Ya todos los valores positivos
    nuevo_gen = ruleta(genotipo, fenotipo, aptitud);
    nuevo_gen = PMX(nuevo_gen, Pc);
    nuevo_gen = muta_int(nuevo_gen, Pm);
    nuevo_feno = nuevo_gen; % decodifica(nuevo_gen, rango);
    nuevo_objv = objfun_int(nuevo_feno, G);
    genotipo = nuevo_gen;
    objv = nuevo_objv;
    [valor, idx] = min(objv);
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



















