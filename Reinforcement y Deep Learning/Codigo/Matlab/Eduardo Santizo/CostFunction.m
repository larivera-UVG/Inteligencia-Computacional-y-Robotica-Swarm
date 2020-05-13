function Costo = CostFunction(X, FunctionName, varargin)
% COSTFUNCTION Evaluaci�n de las posiciones de las part�culas (X) en
% la funci�n de costo elegida. 
% ------------------------------------------------------------------
% Inputs:
%   - X: Matriz (Nx2). Cada fila corresponde a las coordenadas de una
%     part�cula. La fila 1 corresponde a la coordenada X y la fila 2
%     corresponde a la coordenada Y.
%   - FunctionName: Funci�n de costo en la que se evaluar�n las
%     coordenadas presentes en la matriz X. 9 opciones en total. 
%
% Outputs:
%   - Costo: Vector columna con cada fila consistiendo del costo
%     correspondiente a cada una de las part�culas en el swarm.
% ------------------------------------------------------------------
%
% Opciones "FunctionName"
%
%   - Schaffer F6: Utilizada originalmente por Kennedy y Eberhart para evaluar 
%     la capacidad de exploraci�n del PSO debido a las m�ltiples oscilaciones 
%     que presenta. Se puede llamar esta funci�n escribiendo tanto "Paraboloid"
%     como "Sphere". 1 M�nimo = [0,0].
%
%   - Paraboloid / Sphere: Utilizado en la investigaci�n de J. Bansal et
%     al. para evaluar el rendimiento del par�metro de inercia (W). �til para 
%     evaluar la velocidad de convergencia del enjambre por su simplicidad
%     1 M�nimo = [0,0].
%
%   - Rosenbrock / Banana: El m�nimo de esta funci�n se presenta en un
%     angosto valle parab�lico. A pesar que el valle es f�cil de ubicar, el
%     m�nimo com�nmente es dificil de localizar debido a que la pendiente
%     presente en el valle es virtualmente nula. 1 M�nimo = [1,1].
%
%   - Booth: Funci�n simple que puede llegar a describirse como una funci�n
%     "Sphere" descentrada. 1 M�nimo = [0,0]
%
%   - Ackley: Utilizada ampliamente para evaluar susceptibilidad a m�nimos
%     locales. Esto se debe a que esta funci�n posee un m�nimo absoluto en
%     [0,0], pero la regi�n circundante al valle que contiene este m�nimo
%     est� repleta de m�nimos locales. 1 M�nimo = [0,0].
%
%   - Rastrigin: Funci�n con m�ltiples m�nimos locales. Su superficie es
%     irregular pero sus m�nimos locales est�n uniformemente distribuidos.
%     1 M�nimo = [0,0].
%
%   - Levy N13: Utilizada para evaluar susceptibilidad a m�nimos locales.
%     1 M�nimo.
%
%   - Dropwave: Muy similar a la funci�n "SchafferF6". Similar al forma del
%     agua luego que una gota golpeara su superficie. PAR�METRO OPCIONAL DE
%     FUNCI�N: No. de "olas" de la funci�n. 1 M�nimo = [0,0].
%
%   - Himmelblau: Funci�n con m�ltiples m�nimos globales o absolutos. �til
%     para determinar la influencia de la posici�n inicial de las part�culas
%     sobre la decisi�n del punto de convergencia final. 4 M�nimos.
%
%   - APF: Funci�n creada utilizando artificial potential fields. PAR�METRO
%     ADICIONAL DE FUNCI�N: 

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
                    Waves = 0.2;
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
        
        % Funci�n generada utilizando Artificial Potential Fields
        case "APF"    
            Modo = varargin{1};
            Comportamiento = varargin{2};
            VerticesObsX = varargin{3};
            VerticesObsY = varargin{4};
            PosMin = varargin{5};
            PosMax = varargin{6};
            Meta = varargin{7};
            
            persistent Inicializada CoordsMasCosto NoDecimales
            
            % Si el n�mero de puntos es muy alto, se asume que la funci�n
            % se est� inicializando pas�ndole una matriz de puntos
            % correspondientes al tablero.
            if size(X,1) > 1000
                
                % Vertices de los obst�culos. Se colocan las coordenadas X
                % en la primera columna y las Y en la segunda columna.
                VerticesObs = [VerticesObsX VerticesObsY];

                % V�rtices del pol�gono cuadrado que forma el borde la mesa
                % Se repite el primer v�rtice para que la figura cierre
                VerticesMesa = [PosMin PosMin PosMax PosMax ; ...
                                PosMin PosMax PosMax PosMin]';

                % Cabe mencionar que los puntos que definen los v�rtices del pol�gono
                % tienen 4 decimales. Los puntos de X pueden tener entre 2 a 4 decimales.
                % Si se intenta usar inpolygon con esta diferencia en cifras significativas
                % el sistema encontrar� puntos dentro del pol�gono, pero no en los bordes
                % ya que busca coincidencias id�nticas de puntos y para la funci�n un 0.41005
                % es distinto de un 0.41, por ejemplo. Para evitar esto, ambos vectores se
                % redondean a 2 decimales, el valor m�nimo.
                NoDecimales = 1;
                X = round(X, NoDecimales);
                VerticesObs = round(VerticesObs, NoDecimales);
                VerticesMesa = round(VerticesMesa, NoDecimales);

                % Puntos dentro (In) y en el borde (On) de:
                %   - Los obst�culos (Obs)
                %   - Los bordes de la mesa (Mesa)
                [InObs,OnObs] = inpolygon(X(:,1),X(:,2),VerticesObs(:,1),VerticesObs(:,2));
                [~,OnMesa] = inpolygon(X(:,1),X(:,2),VerticesMesa(:,1),VerticesMesa(:,2));

                % Se obtienen los puntos del mesh que consisten de "bordes"
                BordesObs = X(OnObs,:);
                BordesMesa = X(OnMesa,:);

                % Puntos que no consisten de cuerpos s�lidos se vuelven en 0
                PuntosLibres = X .* ~InObs;

                % Traspone y luego repite las coordenadas X y Y, tantas veces 
                % como hay filas en "BordesObs". Se repite "hacia abajo".
                MatrizX = repmat(PuntosLibres(:,1)', size(BordesObs,1),1);                
                MatrizY = repmat(PuntosLibres(:,2)', size(BordesObs,1),1);

                % A las matrices se les restan los vectores columna con las
                % coordenadas de los bordes
                CambioX = min(MatrizX - BordesObs(:,1),[],1);
                CambioY = min(MatrizY - BordesObs(:,2),[],1);

                % Se calculan las distancias al obst�culo m�s cercano
                DistsAObs = sqrt(CambioX'.^2 + CambioY'.^2) .* ~InObs;

                % Se le agrega un valor de 0.1 a puntos que forman parte del
                % cuerpo del obst�culo
                DistsAObs = DistsAObs + InObs * 0.1;

                % Threshold para ignorar obst�culos lejanos
                Qi = 5;

                % Se ignoran puntos muy lejanos al obst�culo
                LejosObs = DistsAObs < Qi;

                % Se repite el proceso previo pero ahora para los puntos que
                % forman parte de los bordes de la mesa
                PuntosDentroMesa = X .* ~OnMesa;
                MatrizX = repmat(PuntosDentroMesa(:,1)', size(BordesMesa,1),1);                 
                MatrizY = repmat(PuntosDentroMesa(:,2)', size(BordesMesa,1),1);
                CambioX = min(MatrizX - BordesMesa(:,1),[],1);
                CambioY = min(MatrizY - BordesMesa(:,2),[],1);
                DistsABordes = sqrt(CambioX'.^2 + CambioY'.^2) .* OnMesa;
                DistsABordes = DistsABordes + ~OnMesa * 0.1;
                LejosBordesMesa = DistsABordes < Qi;

                switch Modo
                    case "Choset"
                        Eta = 10;
                        Zeta = 5;
                        DStar = 2;
                        PotRepulsorMesa = 0.5 * Eta * (1./DistsABordes - 1/Qi) .^2 .* LejosBordesMesa;
                        PotRepulsorObs = 0.5 * Eta * (1./DistsAObs - 1/Qi) .^2 .* LejosObs;
                        PotRepulsor = PotRepulsorMesa + PotRepulsorObs;

                        PotAtractorA = 0.5 * Zeta * sum((X - Meta).^2, 2);
                        PotAtractorB = DStar * Zeta * sqrt(sum((X - Meta).^2, 2)) - 0.5 * Zeta * DStar^2;
                        DistsAMeta = sqrt(sum((X - Meta).^2, 2));

                        LejosMeta = DistsAMeta <= DStar;
                        PotAtractor = PotAtractorA .* LejosMeta + PotAtractorB .* ~LejosMeta;
                    otherwise
                        Co = 500; Lo = 0.2;
                        Cg = 500; Lg = 3;                                               % Distancia de intensidad / Distancia de correlaci�n para migraci�n grupal
                        PotRepulsorMesa = Co * exp(-(DistsABordes .^2) / Lo^2);
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
                
            % Si la funci�n se inicializ� previamente y el n�mero de filas
            % de X (Puntos a analizar) es peque�o (Menor a 1000);
            elseif (size(X,1) < 1000 || Inicializada == 1)
                
                X = round(X,NoDecimales);
                [~,CoincidenciaFilas] = ismember(X,CoordsMasCosto(:,1:2),'rows');
                Costo = CoordsMasCosto(CoincidenciaFilas,3);
                
            else
                ErrorMsg = 'Error. No se inicializ� el artificial potential field. Si se desea inicializar, llamar a la funci�n pas�ndole un vector X con m�s de 1000 puntos o filas.';
                error(ErrorMsg);
            end
            
            
    end

% NOTA: En caso se deseen agregar m�s funciones, simplemente se debe agregar
% un "case" adicional y operar tomando en cuenta la forma de X. Porfavor
% implementar las operaciones de manera matricial (Evitando "for loops")
% para no da�ar la eficiencia del programa.

end

