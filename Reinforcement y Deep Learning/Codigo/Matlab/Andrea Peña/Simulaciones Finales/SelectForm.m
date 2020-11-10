% =========================================================================
% FUNCI�N SELECTFORM
% =========================================================================
% Autor: Andrea Maybell Pe�a Echeverr�a
% �ltima modificaci�n: 01/07/2019
% =========================================================================

function [f] = SelectForm(aF, FAct)
%SELECTFORM Selecciona la formaci�n con menor error respecto a la formaci�n
%           actual
% Par�metros:
%   aF = Arreglo de celdas con formaciones posibles
%   FAct = Matriz adyacente de formaci�n actual
% Salidas:
%   f = Posici�n en el arreglo de celdas de la formaci�n con el menor error

    cantF = size(aF,2);             % cantidad de formaciones posibles
    errores = zeros(1,cantF);       % inicializaci�n vector de errores
    for i = 1:cantF
        errores(i) = ErrorForm(FAct,aF{i});     % error con formaci�n i
    end
    f = find(errores == min(errores));
end

