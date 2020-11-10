% =========================================================================
% FUNCIÓN SELECTFORM
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 01/07/2019
% =========================================================================

function [f] = SelectForm(aF, FAct)
%SELECTFORM Selecciona la formación con menor error respecto a la formación
%           actual
% Parámetros:
%   aF = Arreglo de celdas con formaciones posibles
%   FAct = Matriz adyacente de formación actual
% Salidas:
%   f = Posición en el arreglo de celdas de la formación con el menor error

    cantF = size(aF,2);             % cantidad de formaciones posibles
    errores = zeros(1,cantF);       % inicialización vector de errores
    for i = 1:cantF
        errores(i) = ErrorForm(FAct,aF{i});     % error con formación i
    end
    f = find(errores == min(errores));
end

