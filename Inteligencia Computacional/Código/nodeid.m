function indx = nodeid(nodo,nodos)
    [LIA,indx] = ismember(nodo,nodos,'rows');
    if (LIA == 0)
        print ("Error, el nodo que ingresó no está en nodos.")
    end
end