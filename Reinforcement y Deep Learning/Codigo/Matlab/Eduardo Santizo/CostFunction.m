function [Costo,varargout] = CostFunction(X, FunctionName, varargin)
% COSTFUNCTION Evaluación de las posiciones de las partículas (X) en
% la función de costo elegida. 
% ------------------------------------------------------------------
% Inputs:
%   - X: Matriz (Nx2). Cada fila corresponde a las coordenadas de una
%     partícula. La fila 1 corresponde a la coordenada X y la fila 2
%     corresponde a la coordenada Y.
%   - FunctionName: Función de costo en la que se evaluarán las
%     coordenadas presentes en la matriz X. 9 opciones en total. 
%
% Outputs:
%   - Costo: Vector columna con cada fila consistiendo del costo
%     correspondiente a cada una de las partículas en el swarm.
% ------------------------------------------------------------------
%
% Opciones "FunctionName"
%
%   - Schaffer F6: Utilizada originalmente por Kennedy y Eberhart para evaluar 
%     la capacidad de exploración del PSO debido a las múltiples oscilaciones 
%     que presenta. Se puede llamar esta función escribiendo tanto "Paraboloid"
%     como "Sphere". 1 Mínimo = [0,0].
%
%   - Paraboloid / Sphere: Utilizado en la investigación de J. Bansal et
%     al. para evaluar el rendimiento del parámetro de inercia (W). Útil para 
%     evaluar la velocidad de convergencia del enjambre por su simplicidad
%     1 Mínimo = [0,0].
%
%   - Rosenbrock / Banana: El mínimo de esta función se presenta en un
%     angosto valle parabólico. A pesar que el valle es fácil de ubicar, el
%     mínimo comúnmente es dificil de localizar debido a que la pendiente
%     presente en el valle es virtualmente nula. 1 Mínimo = [1,1].
%
%   - Booth: Función simple que puede llegar a describirse como una función
%     "Sphere" descentrada. 1 Mínimo = [0,0]
%
%   - Ackley: Utilizada ampliamente para evaluar susceptibilidad a mínimos
%     locales. Esto se debe a que esta función posee un mínimo absoluto en
%     [0,0], pero la región circundante al valle que contiene este mínimo
%     está repleta de mínimos locales. 1 Mínimo = [0,0].
%
%   - Rastrigin: Función con múltiples mínimos locales. Su superficie es
%     irregular pero sus mínimos locales están uniformemente distribuidos.
%     1 Mínimo = [0,0].
%
%   - Levy N13: Utilizada para evaluar susceptibilidad a mínimos locales.
%     1 Mínimo.
%
%   - Dropwave: Muy similar a la función "SchafferF6". Similar al forma del
%     agua luego que una gota golpeara su superficie. PARÁMETRO OPCIONAL DE
%     FUNCIÓN: No. de "olas" de la función. 1 Mínimo = [0,0].
%
%   - Himmelblau: Función con múltiples mínimos globales o absolutos. Útil
%     para determinar la influencia de la posición inicial de las partículas
%     sobre la decisión del punto de convergencia final. 4 Mínimos.
%
%   - APF: Función creada utilizando artificial potential fields. PARÁMETRO
%     ADICIONAL DE FUNCIÓN: 

    switch FunctionName
        % Paraboloide o Esfera
        case {"Paraboloid", "Sphere"}                      
            Costo = sum(X.^2, 2);                                   

        % Ackley Function
        case "Ackley"                      
            a = 20; b = 0.2; c = 2*pi; d = size(X,2);              
            Sum1 = -b * sqrt((1/d) * sum(X.^2, 2));
            Sum2 = (1/d) * sum(cos(c*X), 2);
            Costo = -a*exp(Sum1) - exp(Sum2) + a + exp(1);

        % Rastrigin Function
        case "Rastrigin"
            d = size(X,2);                                          
            Costo = 10*d + sum(X.^2 - 10*cos(2*pi*X), 2);

        % Levy Function N.13
        case {"Levy N13", "Levy"}
            Costo = sin(3*pi*X(:,1)).^2 ...                        
                    + (X(:,1)-1).^2 .* (1 + sin(3*pi*X(:,2)).^2) ...
                    + (X(:,2) - 1).^2 .* (1 + sin(2*pi*X(:,2)).^2);

        % Drop Wave Function        
        case "Dropwave"
            switch numel(varargin)
                case 1
                    Waves = varargin{1};
                otherwise
                    Waves = 2;
            end
            
            Costo = -(1 + cos(Waves * sqrt(sum(X.^2, 2)))) ./ ...
                     (0.5 * sqrt(sum(X.^2, 2)) + 2);
        
        % Schaffer F6 Function
        case "Schaffer F6"
            Costo = 0.5 + ((sin(sqrt(sum(X.^2, 2))).^2 - 0.5) ./ ...
                           (1 + (0.001 * sum(X.^2, 2))));
        
        % Rosenbrock / Banana Function
        case {"Rosenbrock", "Banana"}
            Costo = sum(100*(X(:,2)-X(:,1).^2).^2 + (X(:,1)-1).^2, 2);
        
        % Booth Function
        case "Booth"
            Costo = (X(:,1) + 2*X(:,2) - 7).^2 + (2*X(:,1) + X(:,2) - 5).^2;
        
        % Himmelblau Function
        case "Himmelblau"
            Costo = (X(:,1).^2 + X(:,2) - 11).^2 + (X(:,1) + X(:,2).^2 - 7).^2;
        
        % Función generada utilizando Artificial Potential Fields
        case "APF"    
            Modo = varargin{1};
            Comportamiento = varargin{2};
            VerticesObsX = varargin{3};
            VerticesObsY = varargin{4};
            PosMin = varargin{5};
            PosMax = varargin{6};
            Meta = varargin{7};
            
            persistent Inicializada CoordsMasCosto NoDecimales
            
            % Si el número de puntos es muy alto, se asume que la función
            % se está inicializando pasándole una matriz de puntos
            % correspondientes al tablero.
            if size(X,1) > 1000
                
                % Vertices de los obstáculos. Se colocan las coordenadas X
                % en la primera columna y las Y en la segunda columna.
                VerticesObs = [VerticesObsX VerticesObsY];

                % Vértices del polígono cuadrado que forma el borde la mesa
                % Se repite el primer vértice para que la figura cierre
                VerticesMesa = [PosMin PosMin PosMax PosMax ; ...
                                PosMin PosMax PosMax PosMin]';

                % Cabe mencionar que los puntos que definen los vértices del polígono
                % tienen 4 decimales. Los puntos de X pueden tener entre 2 a 4 decimales.
                % Si se intenta usar inpolygon con esta diferencia en cifras significativas
                % el sistema encontrará puntos dentro del polígono, pero no en los bordes
                % ya que busca coincidencias idénticas de puntos y para la función un 0.41005
                % es distinto de un 0.41, por ejemplo. Para evitar esto, ambos vectores se
                % redondean a 2 decimales, el valor mínimo.
                NoDecimales = 1;
                X = round(X, NoDecimales);
                VerticesObs = round(VerticesObs, NoDecimales);
                VerticesMesa = round(VerticesMesa, NoDecimales);

                % Puntos dentro (In) y en el borde (On) de:
                %   - Los obstáculos (Obs)
                %   - Los bordes de la mesa (Mesa)
                [InObs,OnObs] = inpolygon(X(:,1),X(:,2),VerticesObs(:,1),VerticesObs(:,2));
                [InMesa,OnMesa] = inpolygon(X(:,1),X(:,2),VerticesMesa(:,1),VerticesMesa(:,2));

                % Puntos del Mesh que estén en el borde o en el interior
                % de el o los obstáculos.
                PuntosObs = X(OnObs | InObs,:);
                
                % Puntos del Mesh que estén en el borde o en el exterior de
                % la mesa.
                PuntosMesa = X(OnMesa | ~InMesa,:);
                
                % Traspone y luego repite las coordenadas X y Y, tantas veces 
                % como hay filas en "BordesObs". Se repite "hacia abajo".
                MatrizX = repelem(PuntosObs(:,1), 1, size(X,1));              
                MatrizY = repelem(PuntosObs(:,2), 1, size(X,1));

                % A las matrices se les restan los vectores columna con las
                % coordenadas de los bordes
                CambioX = MatrizX - X(:,1)';
                CambioY = MatrizY - X(:,2)';

                % Se calculan las distancias al obstáculo más cercano
                DistsAObs = sqrt(CambioX'.^2 + CambioY'.^2);
                DistsAObs = min(DistsAObs,[],2);
                
                % Se repite el proceso previo pero ahora para los puntos que
                % forman parte de los bordes de la mesa
                MatrizX = repelem(PuntosMesa(:,1), 1, size(X,1));                 
                MatrizY = repelem(PuntosMesa(:,2), 1, size(X,1));
                CambioX = MatrizX - X(:,1)';
                CambioY = MatrizY - X(:,2)';
                DistsAMesa = sqrt(CambioX'.^2 + CambioY'.^2);
                DistsAMesa = min(DistsAMesa,[],2);
                
                switch Modo
                    case "Choset"
                        Eta = 20;
                        Qi = 5;                                                                 % Threshold para ignorar obstáculos lejanos
                        PotRepulsorMesa = 0.5 * Eta * (1./DistsAMesa - 1/Qi) .^2;
                        PotRepulsorObs = 0.5 * Eta * (1./DistsAObs - 1/Qi) .^2 ;
                        
                        % Se determinan las distancias menores al threshold
                        % Qi como las distancias cercanas a los obstáculos.
                        CercaBordesMesa = DistsAMesa <= Qi;
                        CercaObs = DistsAObs <= Qi;
                        
                        % Las distancias cercanas menores a Qi adquieren
                        % una altura muy grande. El resto toman una altura
                        % de 0. 
                        PotRepulsor = PotRepulsorObs .* CercaObs + PotRepulsorMesa .* CercaBordesMesa;
                        
                        % Ecuaciones propuestas por Choset (Pag. 82)
                        Zeta = 5;                                                               % Factor para escalar el efecto de la atracción
                        DStar = 2;                                                              % Threshold de "cercanía" a un obstáculo
                        PotAtractorParabolico = 0.5 * Zeta * sum((X - Meta).^2, 2);
                        PotAtractorConico = DStar * Zeta * sqrt(sum((X - Meta).^2, 2)) - 0.5 * Zeta * DStar^2;
                        
                        % Se determinan las distancias menores al threshold
                        % DStar o D*. Estas son las distancias "cercanas" a
                        % la meta.
                        DistsAMeta = sqrt(sum((X - Meta).^2, 2));
                        CercaMeta = DistsAMeta <= DStar;
                        
                        % Los puntos cercanos utilizan un potencial atractor
                        % parabólico, mientras que los lejanos utlizan uno
                        % cónico.
                        PotAtractor = PotAtractorParabolico .* CercaMeta + PotAtractorConico .* ~CercaMeta;
                        
                    otherwise
                        Co = 500; Lo = 0.2;
                        Cg = 500; Lg = 3;                                               % Distancia de intensidad / Distancia de correlación para migración grupal
                        PotRepulsorMesa = Co * exp(-(DistsAMesa .^2) / Lo^2);
                        PotRepulsorObs = Co * exp(-(DistsAObs .^2) / Lo^2);
                        PotRepulsor = PotRepulsorMesa + PotRepulsorObs;

                        PotAtractor = Cg * (1 - exp(-(vecnorm(X - Meta).^2) / Lg^2));
                end

                switch Comportamiento
                    case "Multiplicativo"
                        if strcmp(Modo,"Choset")
                            PotTotal = PotRepulsor .* PotAtractor + PotAtractor;
                        else
                            PotTotal = PotRepulsor / Cg .* PotAtractor + PotAtractor;
                        end
                        
                    case "Aditivo"
                        PotTotal = PotRepulsor + PotAtractor;
                end
                
                Inicializada = 1;
                Costo = PotTotal;
                CoordsMasCosto = [X PotTotal];
                
            % Si la función se inicializó previamente y el número de filas
            % de X (Puntos a analizar) es pequeño (Menor a 1000);
            elseif (size(X,1) < 1000 || Inicializada == 1)
                
                % Se aproximan las coordenadas de X a la misma cantidad de
                % decimales que las coordenadas en CoordsMasCosto
                X = round(X,NoDecimales);         
                
                % Se acotan las aproximaciones de las coordenadas X para
                % que al momento de aproximar no se generen valores por
                % encima o por debajo de los límites superiores o
                % inferiores las coordenadas en "CoordsMasCosto".
                X = min(X,max(CoordsMasCosto(:,1:2)));
                X = max(X,min(CoordsMasCosto(:,1:2)));
                
                % Se buscan coincidencias entre las coordenadas de
                % "CoordsMasCosto" y X. Los índices de CoordsMasCosto donde
                % existe coincidencia se guardan en CoincidenciaFilas
                [~,CoincidenciaFilas] = ismember(X,CoordsMasCosto(:,1:2),'rows');
                Costo = CoordsMasCosto(CoincidenciaFilas,3);

            else
                ErrorMsg = 'Error. No se inicializó el artificial potential field. Si se desea inicializar, llamar a la función pasándole un vector X con más de 1000 puntos (X,Y)';
                error(ErrorMsg);
            end
            
            
    end

% NOTA: En caso se deseen agregar más funciones, simplemente se debe agregar
% un "case" adicional y operar tomando en cuenta la forma de X. Porfavor
% implementar las operaciones de manera matricial (Evitando "for loops")
% para no dañar la eficiencia del programa.

end

