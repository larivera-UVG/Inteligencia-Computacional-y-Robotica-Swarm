function indx = nodeid(nodo,nodos)
    [LIA,indx] = ismember(nodo,nodos,'rows');
    if (LIA == 0)
        print ("Error, el nodo que ingres� no est� en nodos.")
    end
end