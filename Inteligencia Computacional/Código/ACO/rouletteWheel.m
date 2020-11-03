% Parámetros:
% probabilidad es un vector con la probabilidad de cada nodo a seleccionar.
% No importa si es fila o columna.
% Output:
% Index del vector donde está el seleccionado.
function nextIndx = rouletteWheel(probabilidad)
    
    total = sum(probabilidad); % Sumo todas las probabilidades
    norm_probability = probabilidad/total; % Normalizamos las probabilidades
    r = rand(1);
    ind = 1;
    suma = norm_probability(ind); % Número inicial
    while (suma < r) % Si la probabilidad es menor que el random
        ind = ind + 1; % Siguiente número
        suma = suma + norm_probability(ind); % Probabilidad acumulada
    end
    nextIndx = ind;
end