function nextIndx = rouletteWheel(probabilidad)
    
    total = sum(probabilidad); % Sumo todas las probabilidades
    norm_probability = probabilidad/total; % Normalizamos las probabilidades
    %a = 0; b = total;
    %r = (b-a).*rand(1) + a;
    r = rand(1);
    ind = 1;
    suma = norm_probability(ind); % Número inicial
    while (suma < r) % Si la probabilidad es menor que el random
        ind = ind + 1; % Siguiente número
        suma = suma + norm_probability(ind); % Probabilidad acumulada
    end
    nextIndx = ind;
end