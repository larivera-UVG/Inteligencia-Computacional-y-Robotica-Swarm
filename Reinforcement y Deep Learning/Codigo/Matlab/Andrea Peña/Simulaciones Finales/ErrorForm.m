% =========================================================================
% FUNCI�N ERRORFORM
% =========================================================================
% Autor: Andrea Maybell Pe�a Echeverr�a
% �ltima modificaci�n: 01/07/2019
% =========================================================================
function [error] = ErrorForm(FAct, FDes)
%ERRORFORM Calcula error entre formaci�n actual y formaci�n deseada
% Par�metros:
%   FAct = Matriz de adyacencia de la formaci�n actual
%   FDes = Matriz de adyacencia de la formaci�n deseada
% Salida:
%   error = Error cuadr�tico medio de la formaci�n actual comparada con la 
%           formaci�n deseada

    mDif = (FAct - FDes).^2;            % diferencia al cuadrado
    suma = sum(sum(mDif));              % suma de filas y columnas
    tot = size(mDif,1)*size(mDif,2);    % cantidad de agentes
    error = suma/tot;                   % error promedio
end

