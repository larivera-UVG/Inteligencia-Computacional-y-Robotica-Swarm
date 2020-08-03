% Partially-mapped crossover (PMX)
% Operador de cruza para TSP
function nuevo_gen = PMX(nuevo_gen, Pc)
[Nind, Lind] = size(nuevo_gen);
par = mod(Nind, 2);

for i=1:2:Nind-1
    cruza = rand;
    if cruza <= Pc
        corte = randperm(Lind-1); % De aquí sacamos dos cortes random
        corte = corte(1:2);
        corte = sort(corte);
        mapping_sec_1 =  nuevo_gen(i, corte(1)+1:corte(2)-1);
        mapping_sec_2 =  nuevo_gen(i+1, corte(1)+1:corte(2)-1);
        for k = 1:corte(1)
            [Lia,Locb] = ismember(nuevo_gen(i, k), mapping_sec_2);
            while(Lia)
                nuevo_gen(i, k) = mapping_sec_1(Locb);
                [Lia,Locb] = ismember(nuevo_gen(i, k), mapping_sec_2);
            end
            
            [Lia,Locb] = ismember(nuevo_gen(i+1, k), mapping_sec_1);
            while(Lia)
                nuevo_gen(i+1, k) = mapping_sec_2(Locb);
                [Lia,Locb] = ismember(nuevo_gen(i+1, k), mapping_sec_1);
            end
        end
        
        for k = corte(2):Lind
            [Lia,Locb] = ismember(nuevo_gen(i, k), mapping_sec_2);
            while(Lia)
                nuevo_gen(i, k) = mapping_sec_1(Locb);
                [Lia,Locb] = ismember(nuevo_gen(i, k), mapping_sec_2);
            end
            
            [Lia,Locb] = ismember(nuevo_gen(i+1, k), mapping_sec_1);
            while(Lia)
                nuevo_gen(i+1, k) = mapping_sec_2(Locb);
                [Lia,Locb] = ismember(nuevo_gen(i+1, k), mapping_sec_1);
            end
        end
        % Sustituir la mitad
        nuevo_gen(i, corte(1)+1:corte(2)-1) = mapping_sec_2;
        nuevo_gen(i+1, corte(1)+1:corte(2)-1) = mapping_sec_1;
    end
end

if par == 1
    nuevo_gen(Nind, :) = nuevo_gen(Nind, :);
end

end