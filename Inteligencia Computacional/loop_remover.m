function corregido = loop_remover(pa)

    temp = zeros(size(pa));
    jaja = 1;
    for r = flip(1:size(pa,1))
        if (jaja == 1)
        temp(jaja,:) = pa(r,:);
        jaja = jaja + 1;
        end
        [LIA,indxtemp] = ismember(pa(r,:),temp,'rows');
        if (LIA ~= 0)
            temp(indxtemp:size(temp,1),:) = [];
            jaja = size(temp,1) + 1;
        end
        temp(jaja,:) = pa(r,:);
        jaja = jaja + 1;
    end
    
    corregido = flip(temp);

    

end