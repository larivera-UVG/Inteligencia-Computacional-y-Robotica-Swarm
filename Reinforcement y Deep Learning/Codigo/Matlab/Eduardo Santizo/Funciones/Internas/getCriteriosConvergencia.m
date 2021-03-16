function [Stop] = getCriteriosConvergencia(Criterio, varargin)
% EVALCRITERIOSCONVERGENCIA El usuario indica el criterio que desea evaluar
% En caso este se cumpla, se retorna una señal binaria indicando que se
% debe detener el algoritmo. Si se selecciona un criterio diferente a
% "Iteraciones Max" pero se alcanza el número de iteraciones máximas, la
% función retorna una señal de parada.
% -------------------------------------------------------------------------
% Inputs:
%   - Criterio: Criterio de convergencia a evaluar. Existen tres opciones
%     "Meta Alcanzada", "Entidades Detenidas" e "Iteraciones Max".
%   - Posicion_Meta: Dims = (K,2). K = Número de mínimos o metas en la 
%     función. Coordenadas X y Y de los puntos a los que deben llegar los 
%     robots (Meta dada por el usuario o mínimos de la función de costo).
%   - Posición_Actual: Dims = (NoEntidades,2). Coordenadas X y Y de las 
%     entidades en su iteración actual (E-Pucks por ejemplo).
%   - Costo_Meta: Escalar. Costo obtenido al evaluar las coordenadas de la
%     meta en la función de costo. No necesario al evaluar convergencia de
%     algo distinto a partículas PSO.
%   - Costo_Local: Dims = (NoEntidades,1). Costo asociado a la posición de
%     cada partícula en un enjambre de partículas. No necesario al evaluar
%     convergencia de algo distinto a partículas PSO (E-Pucks por ejemplo).
%   - Porcentaje_Progreso: Razón entre la iteración actual y el número de
%     iteraciones máximas del algoritmo (i / IterMax). 
%
%   NOTA: El único input "obligatorio" de la función es 'Criterio', los
%   inputs restantes se consideran "parámetros" y necesitan ser llamados
%   manualmente por el usuario en lugar de ser ingresados en orden como se
%   haría tradicionalmente con una función. A pesar de ser considerados
%   parámetros, su utilización es obligatoria para el correcto
%   funcionamiento de todos los criterios de convergencia. A continuación
%   se presenta un ejemplo.
%       
%       getCriteriosConvergencia(Criterio, 'Posicion_Actual', Pos, ...
%                                          'Posicion_Meta', Meta, ...
%                                          'Porcentaje_Progreso', 0);
%
% Outputs:
%   - Stop: Señal binaria que indica si el algoritmo debería de detenerse.
%     Si Stop = 1, el algoritmo se debe detener. Si Stop = 0, el algoritmo
%     debe continuar.
%
% -------------------------------------------------------------------------
%
% Criterios:
%
% "Meta Alcanzada": Cierto % de partículas llega lo suficientemente cerca a
% alguna de las metas establecidas. La cercanía a la meta se puede
% determinar ya sea utilizando las coordenadas de la meta (Posicion_Meta) o
% el costo asociado a dicha meta (Costo_Meta).
%
%   Parámetros Modificables
%   - 'ThresholdDist': Distancia que debe de existir entre una entidad y la
%     meta para considerarse "cercana". Default = 0.4
%   - 'ThresholdCosto': Diferencia que debe existir entre el costo del
%     Global Best del enjambre y el costo de la meta para que el enjambre
%     se considere que ha convergido en la meta. Default = 0.0001
%   - 'ThresholdPorcentajeMeta': Porcentaje de entidades que deben estar
%     cercanas a la meta para detener el algoritmo. Default = 0.95
%
% "Entidades Detenidas": Todas las partículas se han quedado "quietas" o se 
% han movido poco.
%
%   Parámetros Modificables
%   - 'ThresholdPosDiff': Distancia euclideana mínima que debe existir
%     entre la posición actual y previa para considerar a la entidad como
%     quieta. Default = 0.01
%   - 'ThresholdPorcentajeQuietas': Porcentaje de entidades que deben estar
%     quietas para detener el algoritmo. Default = 0.95.
%
% "Iteraciones Max": Se ha alcanzado el número de iteraciones máximas.
%
% -------------------------------------------------------------------------

% Se crea el objeto encargado de "parsear" los inputs
IP = inputParser; 

% Inputs Obligatorios / Requeridos: Necesarios para el funcionamiento 
% del programa. La función da error si el usuario no los pasa.                                                     
IP.addRequired('Criterio', @isstring);

% Parámetros: Similar a cuando se utiliza 'FontSize' en plots. El
% usuario debe escribir el nombre del parámetro a modificar seguido
% de su valor. Si no se provee un valor Matlab asume uno "default".
IP.addParameter('Posicion_Meta', [0 0], @isnumeric);
IP.addParameter('Posicion_Actual', [0 0], @isnumeric);
IP.addParameter('Costo_Local', inf, @isnumeric);
IP.addParameter('Costo_Meta', 0, @isnumeric);
IP.addParameter('Porcentaje_Progreso', 0, @isnumeric);

IP.addParameter('ThresholdDist', 0.4, @isnumeric);
IP.addParameter('ThresholdCosto', 0.0001, @isnumeric);
IP.addParameter('ThresholdPorcentajeMeta', 0.95, @isnumeric);
IP.addParameter('ThresholdPosDiff', 0.01, @isnumeric);
IP.addParameter('ThresholdPorcentajeQuietas', 0.95, @isnumeric);
IP.parse(Criterio, varargin{:});

% Parámetros altamente recomendados ingresar a la función para su correcto
% funcionamiento.
Posicion_Meta = IP.Results.Posicion_Meta;
Posicion_Actual = IP.Results.Posicion_Actual;
Costo_Local = IP.Results.Costo_Local;
Costo_Meta = IP.Results.Costo_Meta;
Porcentaje_Progreso = IP.Results.Porcentaje_Progreso;

% Parámetros opcionales para simplemente ajustar el algoritmo
ThresholdDist = IP.Results.ThresholdDist;
ThresholdCosto = IP.Results.ThresholdCosto;
ThresholdPorcentajeMeta = IP.Results.ThresholdPorcentajeMeta;
ThresholdPosDiff = IP.Results.ThresholdPosDiff;
ThresholdPorcentajeQuietas = IP.Results.ThresholdPorcentajeQuietas;

switch Criterio
    case "Meta Alcanzada"
        % En algunas funciones existen múltiples mínimos por función. Este 
        % criterio consiste en contar el número de partículas que se han 
        % acercado lo suficiente a la meta o al mínimo global. La meta 
        % puede estar dada ya sea por un grupo de coordenadas o por un
        % costo objetivo que se desea alcanzar. Si se dan las coordenadas,
        % se utilizan las mismas, si se da el costo se utiliza este. Si se
        % proporcionan ambos valores se le da prioridad a las coordenadas.
        
        % Se proporcionaron las coordenadas de la meta
        if ~any(isnan(Posicion_Meta),'all')

            % Se obtiene la distancia de cada una de las posiciones hasta la o 
            % las metas.

            % Caso 1: 1 meta para todos los pucks o 1 meta por Puck
            if (size(Posicion_Meta,1) == size(Posicion_Actual,1)) || (size(Posicion_Meta,1) == 1)
                Distancias = hypot(Posicion_Meta(:,1)-Posicion_Actual(:,1), Posicion_Meta(:,2)-Posicion_Actual(:,2));

            % Caso 2: Múltiples metas a seguir por los pucks.
            else
                [~,Distancias] = dsearchn(Posicion_Meta,Posicion_Actual);
            end

            % Se calcula el número de entidades que están a menos del
            % threshold de distancia requerido.
            EntidadesEnMinimo = sum(Distancias < ThresholdDist);

            % Porcentaje de entidades cercanas a la meta
            NoEntidades = size(Posicion_Actual,1);
            PorcentajeEnMinimo = EntidadesEnMinimo / NoEntidades;

            % Si el porcentaje es mayor al threshold de porcentaje deseado, se
            % envía una señal para detener el algoritmo.
            if PorcentajeEnMinimo > ThresholdPorcentajeMeta
                Stop = 1;
            else
                Stop = 0;
            end
        
        % Se proporcionó el costo objetivo de la meta
        elseif ~isempty(Costo_Meta) || ~any(isnan(Costo_Meta),'all')
                      
            % Diferencia entre el costo asociado al Global Best y el costo
            % meta.
            DiferenciaCosto = abs(Costo_Local - Costo_Meta);
            
            % Se calcula el número de entidades cuyo costo es menor al
            % threshold de costo requerido
            EntidadesEnMinimo = sum(DiferenciaCosto < ThresholdCosto);
            
            % Porcentaje de entidades cercanas a la meta
            NoEntidades = size(Posicion_Actual,1);
            PorcentajeEnMinimo = EntidadesEnMinimo / NoEntidades;
            
            % Se calcula el número de entidades que tienen una diferencia
            % en costo menor al threshold de costo requerido. Si la
            % diferencia es menor, se establece que se alcanzó la meta.
            if PorcentajeEnMinimo > ThresholdPorcentajeMeta
                Stop = 1;
            else
                Stop = 0;
            end
        
        % No se proporcionó información sobre la meta
        else
            
            error("ERROR: No se proporcionaron ni las coordenadas ni el costo objetivo de la meta");
            
        end
        
    case "Entidades Detenidas"
        
        % Se crea una variable persistente que almacena o recuerda la
        % "Posicion_Actual" previamente ingresada por el usuario.
        persistent Posicion_Previa
        
        % Si es la primera vez que se utiliza "Posicion_Previa" esta se
        % inicializa con posiciones muy grandes para asegurarse que nunca
        % se active el criterio al iniciar la simulación.
        if isempty(Posicion_Previa)
            Posicion_Previa = ones(size(Posicion_Actual)) * 10000;
        end
        
        % Se obtienen las distancias euclideanas entre la posición actual y
        % previa.
        Dists2Prev = hypot(Posicion_Actual(:,1) - Posicion_Previa(:,1), Posicion_Actual(:,2) - Posicion_Previa(:,2));
        
        % Se determina el porcentaje de partículas que se han movido menos
        % del "ThresholdPosDiff".
        EntidadesQuietas = sum(Dists2Prev < ThresholdPosDiff);
        NoEntidades = size(Posicion_Actual,1);
        PorcentajeQuietas = EntidadesQuietas / NoEntidades;
        
        % Si el porcentaje es menor al threshold, se envía una señal para
        % detenerse.
       	if PorcentajeQuietas > ThresholdPorcentajeQuietas
            Stop = 1;
        else
            Stop = 0;
        end
        
        % Se actualiza el valor de "Posicion_Previa"
        Posicion_Previa = Posicion_Actual;
        
    case "Iteraciones Max"
        
        % Si ya se ha llegado al 100% de las iteraciones se envía una señal
        % para detenerse
        if Porcentaje_Progreso == 1
            Stop = 1;
        else
            Stop = 0;
        end
        
end                              

% No importando si el criterio de convergencia corresponde al número máximo
% de iteraciones, la función retorna una señal de parada cuando alcanza el
% número máximo de iteraciones.
if Porcentaje_Progreso == 1
    Stop = 1;
end

end

