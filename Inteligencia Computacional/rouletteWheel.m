function nextIndx = rouletteWheel(probabilidad)
    
    total = sum(probabilidad);
    a = 0; b = total;
    r = (b-a).*rand(1) + a;
    ind = 1;
    suma = sum(probabilidad(ind));
    while (suma < r)
        ind = ind + 1;
        suma = suma + probabilidad(ind);
    end
    nextIndx = ind;
end