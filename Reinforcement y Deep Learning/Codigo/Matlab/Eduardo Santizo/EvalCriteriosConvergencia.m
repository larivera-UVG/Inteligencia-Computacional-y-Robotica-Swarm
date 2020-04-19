function [Criterios, NomCriterios] = EvalCriteriosConvergencia(Coords_Min, Posicion_Actual, Iter, varargin)
% EVALCRITERIOSCONVERGENCIA Función que determina si se han cumplido alguno
% de los criterios de convergencia programados.
% -------------------------------------------------------------------------
% Inputs:
%   - Coords_Min: Dims (K,2). K = Número de mínimos en la función. Coord-
%     enadas X y Y de los puntos de la función de costo donde se encuentran
%     los mínimos globales.
%   - Posición_Actual: Dims (N,2). N = No Partículas. Coordenadas X y Y de 
%     las partículas en su iteración actual.
%   - Iter: Iteración actual. Comúnmente llamada "i".
%   - varargin: Parámetros adicionales que requiera el programador para
%     implementar nuevos criterios de convergencia.
%
% Outputs:
%   - Criterios: Dims (Y,1). Y = No Criterios. Vector binario donde cada
%     fila del vector indica si uno de los criterios programados se activó
%     o no.
% -------------------------------------------------------------------------
%
% Criterios (En orden de prioridad):
%
%   1. Cierto % de partículas llega a alguno de los mínimos de la función
%   2. Criterio 1 cumplido y ha transcurrido el 80% de las iteraciones máx.
%   3. Todas las partículas se han quedado "quietas" o se han movido poco.
%   4. Se ha alcanzado el número de iteraciones máximas.
%
% NOTA: El programa despliega cual fue el criterio DE MAYOR PRIORIDAD que 
% se cumplió para dar fin a la simulación. Si se desea dar mayor prioridad
% a un criterio, reordenar los índices de "Criterios" para que el criterio
% de interés tenga un índice más pequeño.

Mean_Dists = zeros(size(Coords_Min,1),1);                                           % "Mean_Dists" es un vector columna con el mismo número de filas que "Coords_Min"

% Selección de un mínimo ====
% En algunas funciones existen múltiples mínimos por función. Uno de los
% criterios a utilizar es que las partículas se han acercado lo suficiente
% a un mínimo global específico. Por lo tanto, el programa debe enfocarse
% en un mínimo específico para poder evaluar el criterio o retornará un
% error.
for j = 1:size(Coords_Min,1)
    Mean_Dists(j) = mean(sqrt(sum((Coords_Min(j,:) - Posicion_Actual).^2, 2)));     % Se calcula la distancia euclideana media de todas las partículas a los diferentes mínimos.
end

[~, SelectedMin] = min(Mean_Dists);                                                 % Se elige el mínimo con la distancia media más pequeña.


% Criterios de finalización ====

% CRITERIO 1: Detener si cierto porcentaje de las partículas llega a alguno 
% de los mínimos de la función.
NoParticulas = varargin{1};
PosMax = varargin{2};
PosMin = varargin{3};

AreaTotal = (PosMax - PosMin)^2;                                                    % Área total del plano de búsqueda
Porcentaje_AreaTotal = 0.1;                                                         % Area de circulo de convergencia = Porcentaje del área total 
RadioConvergencia = sqrt((AreaTotal * (Porcentaje_AreaTotal/100)) / pi);            % Despeje de la fórmula del área de un círculo (A = pi*r^2) para el radio
Porcentaje_PartDentroRadio = 0.95;                                                  % Porcentaje de partículas que deben estar dentro del radio de convergencia para detener el algoritmo.

Dists_ToMin = sqrt(sum((Coords_Min(SelectedMin,:) - Posicion_Actual).^2, 2));       % Distancias de todas las partículas al mínimo global                       
Particulas_DentroRadio = sum(Dists_ToMin < RadioConvergencia);                      % Se cuentan todas las partículas cuya distancia al mínimo es menor al radio de convergencia.
Criterios(1) = Particulas_DentroRadio > Porcentaje_PartDentroRadio*NoParticulas; 

% CRITERIO 2: Detener si se cumplió el criterio 1 y ha transcurrido el 80%
% de las iteraciones totales.
IteracionesMax = varargin{4};

Criterios(2) = Criterios(1) * (Iter > 0.8*IteracionesMax);                          

% CRITERIO 3: Detener si todas las partículas se han quedado "quietas"
Threshold_PosDiff = 0.001;                                                          % Si el delta de posición de todas las partículas es menor a este threshold el algoritmo se detiene. 
Posicion_Previa = varargin{5};

Dists_ToPrev = sqrt(sum((Posicion_Actual - Posicion_Previa).^2, 2));                % Distancia de la posición actual de cada partícula a su posición previa
Particulas_Quietas = sum(Dists_ToPrev < Threshold_PosDiff);                         % Se cuentan todas las partículas que se hayan movido una distancia menor a "Threshold_PosDiff"
Criterios(3) = Particulas_Quietas == NoParticulas;                                  

% CRITERIO 4: Detener si se llega al número de iteraciones máximas.
Criterios(4) = (Iter == IteracionesMax);                                            

% Nombre de los criterios programados ====
% String que desplegará el programa al finalizar el algoritmo.
NomCriterios = {"Mínimo Global Alcanzado", ...
                "Mínimo Global Alcanzado", ...
                "Posición ha Convergido", ...
                "Iter. Máx. Alcanzadas"};
end

