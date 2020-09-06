function [Stop] = getCriteriosConvergencia(Criterio, Meta, Posicion_Actual, Porcentaje_Progreso, varargin)
% EVALCRITERIOSCONVERGENCIA El usuario indica el criterio que desea evaluar
% En caso este se cumpla, se retorna una se�al binaria indicando que se
% debe detener el algoritmo. Si se selecciona un criterio diferente a
% "Iteraciones Max" pero se alcanza el n�mero de iteraciones m�ximas, la
% funci�n retorna una se�al de parada.
% -------------------------------------------------------------------------
% Inputs:
%   - Criterio: Criterio de convergencia a evaluar. Existen tres opciones
%     "Meta Alcanzada", "Entidades Detenidas" e "Iteraciones Max".
%   - Meta: Dims (K,2). K = N�mero de m�nimos o metas en la funci�n. Coord-
%     enadas X y Y de los puntos a los que deben llegar los robots (Meta
%     dada por el usuario o m�nimos de la funci�n de costo).
%   - Posici�n_Actual: Dims = (NoEntidades,2). Coordenadas X y Y de las 
%     entidades en su iteraci�n actual.
%   - Porcentaje_Progreso: Raz�n entre la iteraci�n actual y el n�mero de
%     iteraciones m�ximas del algoritmo (i / IterMax). 
%
% Outputs:
%   - Stop: Se�al binaria que indica si el algoritmo deber�a de detenerse.
%     Si Stop = 1, el algoritmo se debe detener. Si Stop = 0, el algoritmo
%     debe continuar.
%
% -------------------------------------------------------------------------
%
% Criterios:
%
% "Meta Alcanzada": Cierto % de part�culas llega lo suficientemente cerca a
% alguna de las metas establecidas.
%
%   Par�metros Modificables
%   - 'ThresholdDist': Distancia que debe de existir entre una entidad y la
%     meta para considerarse "cercana". Default = 0.4
%   - 'ThresholdPorcentajeMeta': Porcentaje de entidades que deben estar
%     cercanas a la meta para detener el algoritmo. Default = 0.95
%
% "Entidades Detenidas": Todas las part�culas se han quedado "quietas" o se 
% han movido poco.
%
%   Par�metros Modificables
%   - 'ThresholdPosDiff': Distancia euclideana m�nima que debe existir
%     entre la posici�n actual y previa para considerar a la entidad como
%     quieta. Default = 0.01
%   - 'ThresholdPorcentajeQuietas': Porcentaje de entidades que deben estar
%     quietas para detener el algoritmo. Default = 0.95.
%
% "Iteraciones Max": Se ha alcanzado el n�mero de iteraciones m�ximas.
%
% -------------------------------------------------------------------------

% Se crea el objeto encargado de "parsear" los inputs
IP = inputParser; 

% Inputs Obligatorios / Requeridos: Necesarios para el funcionamiento 
% del programa. La funci�n da error si el usuario no los pasa.                                                     
IP.addRequired('Criterio', @isstring);
IP.addRequired('Meta', @isnumeric);
IP.addRequired('Posicion_Actual', @isnumeric);
IP.addRequired('Porcentaje_Progreso', @isnumeric);

% Par�metros: Similar a cuando se utiliza 'FontSize' en plots. El
% usuario debe escribir el nombre del par�metro a modificar seguido
% de su valor. Si no se provee un valor Matlab asume uno "default".
IP.addParameter('ThresholdDist', 0.4, @isnumeric);
IP.addParameter('ThresholdPorcentajeMeta', 0.95, @isnumeric);
IP.addParameter('ThresholdPosDiff', 0.01, @isnumeric);
IP.addParameter('ThresholdPorcentajeQuietas', 0.95, @isnumeric);
IP.parse(Criterio,Meta,Posicion_Actual,Porcentaje_Progreso, varargin{:});

ThresholdDist = IP.Results.ThresholdDist;
ThresholdPorcentajeMeta = IP.Results.ThresholdPorcentajeMeta;
ThresholdPosDiff = IP.Results.ThresholdPosDiff;
ThresholdPorcentajeQuietas = IP.Results.ThresholdPorcentajeQuietas;

switch Criterio
    case "Meta Alcanzada"
        % En algunas funciones existen m�ltiples m�nimos o metas por 
        % funci�n. Este criterio consiste en contar el n�mero n�mero de
        % part�culas que se han acercado lo suficiente a la meta. 
        
        % Se obtiene la distancia de cada una de las posiciones hasta la o 
        % las metas.
        
        % Caso 1: 1 meta para todos los pucks o 1 meta por Puck
        if (size(Meta,1) == size(Posicion_Actual,1)) || (size(Meta,1) == 1)
            Distancias = hypot(Meta(:,1)-Posicion_Actual(:,1), Meta(:,2)-Posicion_Actual(:,2));
        
        % Caso 2: M�ltiples metas a seguir por los pucks.
        else
            [~,Distancias] = dsearchn(Meta,Posicion_Actual);
        end
        
        % Se calcula el n�mero de entidades que est�n a menos del
        % threshold de distancia requerido.
        EntidadesEnMinimo = sum(Distancias < ThresholdDist);
        
        % Porcentaje de entidades cercanas a la meta
        NoEntidades = size(Posicion_Actual,1);
        PorcentajeEnMinimo = EntidadesEnMinimo / NoEntidades;
        
        % Si el porcentaje es mayor al threshold de porcentaje deseado, se
        % env�a una se�al para detener el algoritmo.
        if PorcentajeEnMinimo > ThresholdPorcentajeMeta
            Stop = 1;
        else
            Stop = 0;
        end
        
    case "Entidades Detenidas"
        
        % Se crea una variable persistente que almacena o recuerda la
        % "Posicion_Actual" previamente ingresada por el usuario.
        persistent Posicion_Previa
        
        % Si es la primera vez que se utiliza "Posicion_Previa" esta se
        % inicializa con posiciones muy grandes para asegurarse que nunca
        % se active el criterio al iniciar la simulaci�n.
        if isempty(Posicion_Previa)
            Posicion_Previa = ones(size(Posicion_Actual)) * 10000;
        end
        
        % Se obtienen las distancias euclideanas entre la posici�n actual y
        % previa.
        Dists2Prev = hypot(Posicion_Actual(:,1) - Posicion_Previa(:,1), Posicion_Actual(:,2) - Posicion_Previa(:,2));
        
        % Se determina el porcentaje de part�culas que se han movido menos
        % del "ThresholdPosDiff".
        EntidadesQuietas = sum(Dists2Prev < ThresholdPosDiff);
        NoEntidades = size(Posicion_Actual,1);
        PorcentajeQuietas = EntidadesQuietas / NoEntidades;
        
        % Si el porcentaje es menor al threshold, se env�a una se�al para
        % detenerse.
       	if PorcentajeQuietas > ThresholdPorcentajeQuietas
            Stop = 1;
        else
            Stop = 0;
        end
        
        % Se actualiza el valor de "Posicion_Previa"
        Posicion_Previa = Posicion_Actual;
        
    case "Iteraciones Max"
        
        % Si ya se ha llegado al 100% de las iteraciones se env�a una se�al
        % para detenerse
        if Porcentaje_Progreso == 1
            Stop = 1;
        else
            Stop = 0;
        end
        
end                              

% No importando si el criterio de convergencia corresponde al n�mero m�ximo
% de iteraciones, la funci�n retorna una se�al de parada cuando alcanza el
% n�mero m�ximo de iteraciones.
if Porcentaje_Progreso == 1
    Stop = 1;
end

end

