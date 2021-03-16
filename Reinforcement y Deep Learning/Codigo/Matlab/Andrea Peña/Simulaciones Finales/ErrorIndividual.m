% =========================================================================
% FUNCIÓN ERRORINDIVIDUAL
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 13/09/2019
% =========================================================================

function [errorR, CantAS] = ErrorIndividual(FAct,FDes,threshold)
%ERRORINDIVIDUAL Calcula el error de cada agente por separado y encuentra
%               cuántos agentes llegaron a la posición deseada
% Parámetros:
%   FAct = Matriz de adyacencia de la formación actual
%   FDes = Matriz de adyacencia de la formación deseada  
%   threshold = Porcentaje de error permitido para considerar el éxito de
%               la formación
% Salidas:
%   errorR = Vector con el porcentaje de error de cada agente
%   CantAS = Cantidad de agentes que tienen un error relativo menor a 1

    nFDes = FDes;
    nFAct = FAct;
    
    % Cálculo del porcentaje de error
    mDif2 = 100*((FAct - FDes).^2).^0.5 ./abs(FDes);
   
    mT = mDif2 > threshold;     % matriz de threshold
    sMT = sum(mT);              % suma de columnas
    
    i = 1;
    fin = size(sMT,2);          % cantidad de columnas
    while(i < fin)
        if(sMT(i) >= 5)   
        % si se supera el threshold en 5 filas de la misma columna
            nFDes(:,i) = [];    % eliminar fila en matriz de formación deseada
            nFDes(i,:) = [];    % eliminar columna en matriz de formación deseada
            nFAct(:,i) = [];    % eliminar fila en matriz de formación actual
            nFAct(i,:) = [];    % eliminar columna en matriz de formación actual
            sMT(i) = [];        % eliminar valor en la suma de columnas
            fin = size(sMT,2);  % cantidad de columnas
        end
        i = i+1;
    end
    
    CantAS = fin;
    errorR = ErrorForm(nFAct, nFDes);
    
            
            
end

