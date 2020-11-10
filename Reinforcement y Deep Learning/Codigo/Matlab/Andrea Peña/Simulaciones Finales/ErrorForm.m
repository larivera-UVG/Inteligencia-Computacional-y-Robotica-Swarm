% =========================================================================
% FUNCIÓN ERRORFORM
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 01/07/2019
% =========================================================================
function [error] = ErrorForm(FAct, FDes)
%ERRORFORM Calcula error entre formación actual y formación deseada
% Parámetros:
%   FAct = Matriz de adyacencia de la formación actual
%   FDes = Matriz de adyacencia de la formación deseada
% Salida:
%   error = Error cuadrático medio de la formación actual comparada con la 
%           formación deseada

    mDif = (FAct - FDes).^2;            % diferencia al cuadrado
    suma = sum(sum(mDif));              % suma de filas y columnas
    tot = size(mDif,1)*size(mDif,2);    % cantidad de agentes
    error = suma/tot;                   % error promedio
end

