function [Criterios, NomCriterios] = EvalCriteriosConvergencia(Coords_Min, Posicion_Actual, Iter, varargin)
% EVALCRITERIOSCONVERGENCIA Funci�n que determina si se han cumplido alguno
% de los criterios de convergencia programados.
% -------------------------------------------------------------------------
% Inputs:
%   - Coords_Min: Dims (K,2). K = N�mero de m�nimos en la funci�n. Coord-
%     enadas X y Y de los puntos de la funci�n de costo donde se encuentran
%     los m�nimos globales.
%   - Posici�n_Actual: Dims (N,2). N = No Part�culas. Coordenadas X y Y de 
%     las part�culas en su iteraci�n actual.
%   - Iter: Iteraci�n actual. Com�nmente llamada "i".
%   - varargin: Par�metros adicionales que requiera el programador para
%     implementar nuevos criterios de convergencia.
%
% Outputs:
%   - Criterios: Dims (Y,1). Y = No Criterios. Vector binario donde cada
%     fila del vector indica si uno de los criterios programados se activ�
%     o no.
% -------------------------------------------------------------------------
%
% Criterios (En orden de prioridad):
%
%   1. Cierto % de part�culas llega a alguno de los m�nimos de la funci�n
%   2. Criterio 1 cumplido y ha transcurrido el 80% de las iteraciones m�x.
%   3. Todas las part�culas se han quedado "quietas" o se han movido poco.
%   4. Se ha alcanzado el n�mero de iteraciones m�ximas.
%
% NOTA: El programa despliega cual fue el criterio DE MAYOR PRIORIDAD que 
% se cumpli� para dar fin a la simulaci�n. Si se desea dar mayor prioridad
% a un criterio, reordenar los �ndices de "Criterios" para que el criterio
% de inter�s tenga un �ndice m�s peque�o.

Mean_Dists = zeros(size(Coords_Min,1),1);                                           % "Mean_Dists" es un vector columna con el mismo n�mero de filas que "Coords_Min"

% Selecci�n de un m�nimo ====
% En algunas funciones existen m�ltiples m�nimos por funci�n. Uno de los
% criterios a utilizar es que las part�culas se han acercado lo suficiente
% a un m�nimo global espec�fico. Por lo tanto, el programa debe enfocarse
% en un m�nimo espec�fico para poder evaluar el criterio o retornar� un
% error.
for j = 1:size(Coords_Min,1)
    Mean_Dists(j) = mean(sqrt(sum((Coords_Min(j,:) - Posicion_Actual).^2, 2)));     % Se calcula la distancia euclideana media de todas las part�culas a los diferentes m�nimos.
end

[~, SelectedMin] = min(Mean_Dists);                                                 % Se elige el m�nimo con la distancia media m�s peque�a.


% Criterios de finalizaci�n ====

% CRITERIO 1: Detener si cierto porcentaje de las part�culas llega a alguno 
% de los m�nimos de la funci�n.
NoParticulas = varargin{1};
PosMax = varargin{2};
PosMin = varargin{3};

AreaTotal = (PosMax - PosMin)^2;                                                    % �rea total del plano de b�squeda
Porcentaje_AreaTotal = 0.1;                                                         % Area de circulo de convergencia = Porcentaje del �rea total 
RadioConvergencia = sqrt((AreaTotal * (Porcentaje_AreaTotal/100)) / pi);            % Despeje de la f�rmula del �rea de un c�rculo (A = pi*r^2) para el radio
Porcentaje_PartDentroRadio = 0.95;                                                  % Porcentaje de part�culas que deben estar dentro del radio de convergencia para detener el algoritmo.

Dists_ToMin = sqrt(sum((Coords_Min(SelectedMin,:) - Posicion_Actual).^2, 2));       % Distancias de todas las part�culas al m�nimo global                       
Particulas_DentroRadio = sum(Dists_ToMin < RadioConvergencia);                      % Se cuentan todas las part�culas cuya distancia al m�nimo es menor al radio de convergencia.
Criterios(1) = Particulas_DentroRadio > Porcentaje_PartDentroRadio*NoParticulas; 

% CRITERIO 2: Detener si se cumpli� el criterio 1 y ha transcurrido el 80%
% de las iteraciones totales.
IteracionesMax = varargin{4};

Criterios(2) = Criterios(1) * (Iter > 0.8*IteracionesMax);                          

% CRITERIO 3: Detener si todas las part�culas se han quedado "quietas"
Threshold_PosDiff = 0.001;                                                          % Si el delta de posici�n de todas las part�culas es menor a este threshold el algoritmo se detiene. 
Posicion_Previa = varargin{5};

Dists_ToPrev = sqrt(sum((Posicion_Actual - Posicion_Previa).^2, 2));                % Distancia de la posici�n actual de cada part�cula a su posici�n previa
Particulas_Quietas = sum(Dists_ToPrev < Threshold_PosDiff);                         % Se cuentan todas las part�culas que se hayan movido una distancia menor a "Threshold_PosDiff"
Criterios(3) = Particulas_Quietas == NoParticulas;                                  

% CRITERIO 4: Detener si se llega al n�mero de iteraciones m�ximas.
Criterios(4) = (Iter == IteracionesMax);                                            

% Nombre de los criterios programados ====
% String que desplegar� el programa al finalizar el algoritmo.
NomCriterios = {"M�nimo Global Alcanzado", ...
                "M�nimo Global Alcanzado", ...
                "Posici�n ha Convergido", ...
                "Iter. M�x. Alcanzadas"};
end

