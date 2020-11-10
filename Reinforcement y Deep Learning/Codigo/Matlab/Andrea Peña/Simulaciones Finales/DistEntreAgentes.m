% =========================================================================
% FUNCI�N DISTENTREAGENTES
% =========================================================================
% Autor: Andrea Maybell Pe�a Echeverr�a
% �ltima modificaci�n: 01/07/2019
% =========================================================================
function [mDist] = DistEntreAgentes(X)
%DISTENTREAGENTES Genera matriz con distancias entre agentes
% Param�tros:
%   X = Matriz con vectores de posici�n actual de los agentes (x,y)
% Salidas:
%   mDist = Matriz de adyacencia del grafo formado por la posici�n actual
%           de los agentes

    n = size(X,2);          % cantidad de agentes
    mDist = zeros(n,n);     % inicializaci�n de la matriz
    
    for i = 1:n
        for j = 1:n
            dij = norm(X(:,i) - X(:,j));    % distancia entre agente i y j
            mDist(i,j) = dij;               % se a�ade distancia en la matriz
        end
    end

end

