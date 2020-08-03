% ///////////////////////////////////////////////////////////////////////
% Archivo: xpunto.m
% Descripción: Implementación del operador de cruza, el cual aplica la
% cruza a los individuos previamente seleccionados.

function nuevo_gen = xunpunto(nuevo_gen, Pc)
[Nind, Lind] = size(nuevo_gen);
auxgen = [];
par = mod(Nind, 2);

% Para los impares:
for i=1:2:Nind-1
    cruza = rand;
    if cruza <= Pc
        corte = ceil((Lind-1)*rand);
        aux_gen(i, :) = [nuevo_gen(i, 1:corte), nuevo_gen(i+1, corte+1:Lind)];
        aux_gen(i+1,:) = [nuevo_gen(i+1, 1:corte), nuevo_gen(i, corte+1:Lind)];
    else
        aux_gen(i,:) = nuevo_gen(i,:);
        aux_gen(i+1,:) = nuevo_gen(i+1,:);
    end
end

% Para los pares:
if par == 1
    aux_gen(Nind, :) = nuevo_gen(Nind, :);
end
nuevo_gen = aux_gen;
end