% =========================================================================
% FUNCIÓN DISTENTREAGENTES
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 01/07/2019
% =========================================================================
function [mDist] = DistEntreAgentes(X)
%DISTENTREAGENTES Genera matriz con distancias entre agentes
% Paramétros:
%   X = Matriz con vectores de posición actual de los agentes (x,y)
% Salidas:
%   mDist = Matriz de adyacencia del grafo formado por la posición actual
%           de los agentes

    n = size(X,2);          % cantidad de agentes
    mDist = zeros(n,n);     % inicialización de la matriz
    
    for i = 1:n
        for j = 1:n
            dij = norm(X(:,i) - X(:,j));    % distancia entre agente i y j
            mDist(i,j) = dij;               % se añade distancia en la matriz
        end
    end

end

