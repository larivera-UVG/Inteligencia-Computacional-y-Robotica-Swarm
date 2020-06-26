classdef PSO < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Posiciones y Velocidades
        Posicion_Actual
        Posicion_Previa
        Posicion_LocalBest
        Posicion_GlobalBest
        Posicion_History
        Velocidad
        
        % Propiedades Generales
        NoIteracionesMax
        NoParticulas
        NoDimensiones
        IteracionActual
        
        % Parámetros de Restricción
        W
        Wmax
        Wmin
        Chi
        Phi1
        Phi2
        VelMin
        VelMax
        PosMin
        PosMax
        TipoInercia
        TipoRestriccion
        
        % Costo
        FuncionCosto
        Costo_Local
        Costo_LocalBest
        Costo_GlobalBest    
    end
    
    methods
        function obj = PSO(Posicion_Actual, Func_Costo, Iter_Max)
            % PSO Construct an instance of this class
            %   Detailed explanation goes here
            
            % Posición y Velocidad de Partículas
            obj.Posicion_Actual = Posicion_Actual;                          % Posición de todas las partículas.                                     Dims: NoParticulas X VarDims
            obj.Posicion_Previa = Posicion_Actual;                          % Memoria con la posición previa de todas las partículas.               Dims: NoParticulas X VarDims
            obj.Posicion_LocalBest = Posicion_Actual;                       % Las posiciones que generaron los mejores costos en las partículas     Dims: NoParticulas X VarDims
            obj.Velocidad = zeros(size(Posicion_Actual));                   % Velocidad de todas las partículas. Inicialmente 0.                    Dims: NoParticulas X VarDims
            
            % Historial de Posición 
            obj.NoIteracionesMax = Iter_Max;
            obj.NoDimensiones = size(Posicion_Actual,2);
            obj.NoParticulas = size(Posicion_Actual,1);
            obj.Posicion_History = cell(obj.NoDimensiones,1);              	% Celda con arrays guardando todas las posiciones.                      Dims: VarDims X 1
            
            for i = 1:obj.NoDimensiones
                obj.Posicion_History{i} = zeros(obj.NoParticulas,Iter_Max);	% Fila "i" de "Posicion_History" = Matriz de ceros para la dimensión "i"
                obj.Posicion_History{i}(:,1) = Posicion_Actual(:,i);        % Array dentro de la fila "i" de "Posicion_History" = Todos los valores de posición para la dimensión "i".
            end
            
            % Costo y Global Best
            obj.FuncionCosto = Func_Costo;
            obj.Costo_Local = CostFunction(obj.Posicion_Actual, obj.FuncionCosto);  % Evaluación del costo en la posición actual de la partícula.           Dims: NoPartículas X 1 (Vector Columna)                               	
            obj.Costo_LocalBest = obj.Costo_Local;

            [obj.Costo_GlobalBest, Fila] = min(obj.Costo_LocalBest);     	% "Global best": El costo más pequeño del vector "CostoLocal"           Dims: Escalar
            obj.Posicion_GlobalBest = obj.Posicion_Actual(Fila, :);        	% "Global best": Posición que genera el costo más pequeño               Dims: 1 X VarDims
            
            obj.IteracionActual = 1;                                        % La etapa de setup consiste de la iteración 1 del algoritmo
            
        end
        
        function SetRestricciones(obj, Restriccion, PosMin, PosMax)
            % -------------------------------------------------------------------------
            % SETRESTRICCIONES Modos de restricción: Inercia / Constriccion / Mixto. 
            %
            % A continuación se tres opciones para restringir la velocidad: 
            %   - Utilizar el coeficiente de constricción (Chi) limitando Vmax a Xmax
            %   - Utilizar un coeficiente de inercia limitando Vmax a un valor elegido 
            %     por el usuario
            %   - Mezclar ambos métodos. Método utilizado por Aldo Nadalini en su tésis.
            % -------------------------------------------------------------------------
            
            obj.PosMin = PosMin;
            obj.PosMax = PosMax;
            obj.TipoRestriccion = Restriccion;
            
            switch Restriccion

                % Coeficiente de Inercia ====
                % Para el coeficiente de inercia, se debe seleccionar el método que se desea utilizar. 
                % En total se implementaron 5 métodos distintos. Escribir "help ComputeInertia" para 
                % más información.

                case "Inercia"
                    obj.TipoInercia = "Chaotic";                                              	% Consultar tipos de inercia utilizando "help ComputeInertia"
                    obj.Wmax = 0.9; obj.Wmin = 0.4;
                    obj.W = ComputeInertia(obj.TipoInercia, 1, obj.Wmax, obj.Wmin, obj.NoIteracionesMax);  	% Cálculo de la primera constante de inercia.

                    obj.VelMax = 0.2*(PosMax - PosMin);                                         % Velocidad máx: Largo max. del vector de velocidad = 20% del ancho/alto del plano 
                    obj.VelMin = -obj.VelMax;                                                   % Velocidad mín: Negativo de la velocidad máxima
                    obj.Chi = 1;                                                                % Igualado a 1 para que el efecto del coeficiente de constricción sea nulo
                    obj.Phi1 = 2; 
                    obj.Phi2 = 2;

                % Coeficiente de Constricción ====
                % Basado en la constricción tipo 1'' propuesta en el paper por Clerc y Kennedy (2001) 
                % titulado "The Particle Swarm - Explosion, Stability and Convergence". Esta constricción 
                % asegura la convergencia siempre y cuando Kappa = 1 y Phi = Phi1 + Phi2 > 4.

                case "Constriccion"
                    Kappa = 1;                                                      % Modificable. Valor recomendado = 1
                    obj.Phi1 = 2.05;                                                % Modificable. Coeficiente de aceleración local. Valor recomendado = 2.05.
                    obj.Phi2 = 2.05;                                                % Modificable. Coeficiente de aceleración global. Valor recomendado = 2.05
                    Phi = obj.Phi1 + obj.Phi2;
                    obj.Chi = 2*Kappa / abs(2 - Phi - sqrt(Phi^2 - 4*Phi));

                    obj.W = 1;
                    obj.VelMax = PosMax;                                            % Velocidad máx: Igual a PosMax
                    obj.VelMin = PosMin;                                            % Velocidad mín: Igual a PosMin

                % Ambos Coeficientes (Mixto) ====
                % Utilizado por Aldo Nadalini en su tésis "Algoritmo Modificado de Optimización de 
                % Enjambre de Partículas (MPSO) (2019). Chi se calcula de la misma manera, pero se
                % utiliza un Phi1 = 2, Phi2 = 10 y el coeficiente de inercia exponencial decreciente.

                case "Mixto"
                    Kappa = 1;                                                      % Valor recomendado = 1
                    obj.Phi1 = 2;                                                   % Valor recomendado = 2
                    obj.Phi2 = 10;                                                  % Valor recomendado = 10
                    Phi = obj.Phi1 + obj.Phi2;
                    obj.Chi = 2*Kappa / abs(2 - Phi - sqrt(Phi^2 - 4*Phi));

                    obj.TipoInercia = "Exponent1";                                 	% Tipo de inercia recomendada = "Exponent1"
                    obj.Wmax = 1.4; obj.Wmin = 0.5;
                    obj.W = ComputeInertia(obj.TipoInercia, 1, obj.NoIteracionesMax); 	% Cálculo de la primera constante de inercia utilizando valores default (1.4 y 0.5).

                    obj.VelMax = inf;                                               % Velocidad máx: Sin restricción
                    obj.VelMin = -inf;                                          	% Velocidad mín: Sin restricción

            end
        end
        
        function RunStandardPSO(obj, TipoEjecucion)
            % RUNPSO Summary of this method goes here
            %   Detailed explanation goes here
            
            switch TipoEjecucion
                case "Steps"
                    IteracionesMax = 2;
                    
                case "Full"
                    IteracionesMax = obj.NoIteracionesMax;
            end
            
            for i = 2:IteracionesMax
                R1 = rand([obj.NoParticulas obj.NoDimensiones]);                                            % Números normalmente distribuidos entre 0 y 1
                R2 = rand([obj.NoParticulas obj.NoDimensiones]);
                obj.Posicion_Previa = obj.Posicion_Actual;                                                  % Se guarda la posición actual como la previa antes de sobre-escribir la actual.             

                % Actualización de Velocidad de Partículas
                obj.Velocidad = obj.Chi * (obj.W * obj.Velocidad ...                                      	% Término inercial
                              + obj.Phi1 * R1 .* (obj.Posicion_LocalBest - obj.Posicion_Actual) ...        	% Componente cognitivo
                              + obj.Phi2 * R2 .* (obj.Posicion_GlobalBest - obj.Posicion_Actual));        	% Componente social

                % Se acotan las velocidades para impedir velocidades muy
                % grandes o muy pequeñas.
                obj.Velocidad = max(obj.Velocidad, obj.VelMin);                                          % Si Velocidad < VelMin, entonces Velocidad = VelMin
                obj.Velocidad = min(obj.Velocidad, obj.VelMax);                                       	% Si Velocidad > VelMax, entonces Velocidad = VelMax

                % Actualización de Posición de Partículas
                obj.Posicion_Actual = obj.Posicion_Actual + obj.Velocidad;                                  % Actualización "discreta" de la posición. El algoritmo de PSO original asume un sampling time = 1s.
                obj.Posicion_Actual = max(obj.Posicion_Actual, obj.PosMin);                              % Se acotan las posiciones de la misma forma en que se acotaron las velocidades
                obj.Posicion_Actual = min(obj.Posicion_Actual, obj.PosMax);

                % Costo Local de partículas. No es necesario pasar los
                % parámetros asociados a los obstáculos en el caso de una
                % función de costo "APF", porque solo se necesitan en el
                % paso de inicialización.
                obj.Costo_Local = CostFunction(obj.Posicion_Actual, obj.FuncionCosto);                      % Actualización de los valores del costo.

                % Cálculo del Global Best
                obj.Costo_LocalBest = min(obj.Costo_LocalBest, obj.Costo_Local);                            % Se sustituyen los costos que son menores al "Local Best" previo
                Costo_Change = (obj.Costo_Local < obj.Costo_LocalBest);                                     % Vector binario que indica con un 0 cuales son las filas de "Costo_Local" que son menores que las filas de "PartCosto_LocalBest"
                obj.Posicion_LocalBest = obj.Posicion_LocalBest .* Costo_Change + obj.Posicion_Actual;      % Se sustituyen las posiciones correspondientes a los costos a cambiar en la linea previa

                [Actual_GlobalBest, Fila] = min(obj.Costo_Local);                                           % Actual_GlobalBest = Valor mínimo de entre los valores de "Costo_Local"
                if Actual_GlobalBest < obj.Costo_GlobalBest                                                 % Si el "Actual_GlobalBest" es menor al "Global Best" previo 
                    obj.Costo_GlobalBest = Actual_GlobalBest;                                               % Se actualiza el valor del "Global Best" (Costo_GlobalBest)
                    obj.Posicion_GlobalBest = obj.Posicion_Actual(Fila, :);                                 % Y la posición correspondiente al "Global Best"
                end
                
                % Actualización de Historial de Posiciones
                obj.IteracionActual = obj.IteracionActual + 1;
                
                for j = 1:obj.NoDimensiones
                    obj.Posicion_History{j}(:,obj.IteracionActual) = obj.Posicion_Actual(:,j);              % Array dentro de la fila "j" de "Posicion_History" = Todos los valores de posición para la dimensión "j".
                end
                
                % Actualización del coeficiente inercial
                if strcmp(obj.TipoRestriccion, "Inercia") || strcmp(obj.TipoRestriccion, "Mixto")
                    obj.W = ComputeInertia(obj.TipoInercia, obj.IteracionActual, obj.Wmax, obj.Wmin, obj.NoIteracionesMax);
                end
                
            end
            
        end
    end
end

