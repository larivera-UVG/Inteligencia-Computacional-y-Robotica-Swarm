function nextIndx = rouletteWheel(probabilidad)
    
    total = sum(probabilidad); % Sumo todas las probabilidades
    a = 0; b = total;
    r = (b-a).*rand(1) + a;
    ind = 1;
    suma = sum(probabilidad(ind)); % Número inicial
    while (suma < r) % Si la probabilidad es menor que el random
        ind = ind + 1; % Siguiente número
        suma = suma + probabilidad(ind); % Probabilidad acumulada
    end
    nextIndx = ind;
end