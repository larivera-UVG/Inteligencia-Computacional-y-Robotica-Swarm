clear;

% Listas vacías
Muestras = [];
Params = [];

% Parámetros generales
NoParts = 1000;
IterMaxPSO = 100;
Runs = 20;

% Creación de barra de progreso
ProgressBar = waitbar(0,'Corriendo Pruebas PSO...');

% Dims Mesa
AnchoMesa = 20;                                     
AltoMesa = 20;
Margen = 0.4;
LimsX = [-AnchoMesa/2 AnchoMesa/2]';                
LimsY = [-AltoMesa/2 AltoMesa/2]';      

% Un set de "runs" por cada función de costo
FuncionesCosto = ["Banana" "Dropwave" "Levy" "Himmelblau" "Rastrigin" "Schaffer F6" "Sphere" "Booth" "Ackley" "APF"];
for n = 1:numel(FuncionesCosto)
    
    FuncCosto_Actual = FuncionesCosto(n);
    
    % Función benchmark?
    FuncionesBenchmark = ["Banana" "Dropwave" "Levy" "Himmelblau" "Rastrigin" "Schaffer F6" "Sphere" "Booth" "Ackley"];
    if contains(FuncCosto_Actual,FuncionesBenchmark)
        isBenchmark = 1;
    else
        isBenchmark = 0;
    end
    
    % Si la función de costo elegida es de tipo APF, se define el
    % obstáculo asociado a la mesa de trabajo de forma aleatoria.
    if strcmp(FuncCosto_Actual,"APF")
        
        % Se elige un obstáculo de forma aleatoria
        IndObs = randi([1 4]);
        Obstaculos = ["Cilindro" "Caso A" "Caso B" "Caso C"];
        Obstaculo_Actual = Obstaculos(IndObs);
        
        RadioObstaculo = 1;                                                     
        AlturaObstaculo = 1;
        OffsetObstaculo = 0;
        Meta = [-3 3];
        
        switch Obstaculo_Actual
            
            case "Cilindro"
                [XObs,YObs,ZObs] = DrawObstacles(TipoObstaculo, AlturaObstaculo, OffsetObstaculo, RadioObstaculo);
            
            case "Caso A"
                XObs = [-2 -2 0 0 -2]'; 
                YObs = [-7 7 7 -7 -7]';
                XObs = interp1([-10 10],[LimsX(1) LimsX(2)],XObs);
                YObs = interp1([-10 10],[LimsY(1) LimsY(2)],YObs);
                [XObs,YObs,ZObs] = DrawObstacles("Custom",AlturaObstaculo,OffsetObstaculo,XObs, YObs);
            
            case "Caso B"
                XObs = [ 0 0 2  2  0]'; 
                YObs = [-2 2 2 -2 -2]';
                XObs = interp1([-10 10],[LimsX(1) LimsX(2)],XObs);
                YObs = interp1([-10 10],[LimsY(1) LimsY(2)],YObs);
                [XObs,YObs,ZObs] = DrawObstacles("Custom",AlturaObstaculo,OffsetObstaculo,XObs, YObs);
                
            case "Caso C"
                Meta = [-3 0];
                XObs = [-6 -6 -5 -5 -6 NaN -6 -6 -5 -5 -6 NaN -1 -1 0  0 -1 NaN]';
                YObs = [-5 -4 -4 -5 -5 NaN  5  4  4  5  5 NaN -1  0 0 -1 -1 NaN]';
                XObs = interp1([-10 10],[LimsX(1) LimsX(2)],XObs);
                YObs = interp1([-10 10],[LimsY(1) LimsY(2)],YObs);
                [XObs,YObs,ZObs] = DrawObstacles("Custom",AlturaObstaculo,OffsetObstaculo,XObs, YObs);
        end
        
    end
    
    % Se actualizan los parámetros ambientales
    switch FuncCosto_Actual
        case "APF"
            EnvironmentParams = {XObs(:,1), YObs(:,1), LimsX, LimsY, Meta};
              
        otherwise
            EnvironmentParams = {};
    end
    
    % Se inicializa la función de costo y se establece la meta.
    Resolucion = 0.1;
    [MeshX, MeshY] = meshgrid(LimsX(1)-Margen:Resolucion:LimsX(2)+Margen, LimsY(1)-Margen:Resolucion:LimsY(2)+Margen);
    Mesh2D = [MeshX(:) MeshY(:)];
    
    if isBenchmark
        [~, Meta] = CostFunction(Mesh2D, FuncCosto_Actual, EnvironmentParams{:});
    else
        CostoPart = CostFunction(Mesh2D, FuncCosto_Actual, EnvironmentParams{:});
    end
    
    % Se crea el objeto PSO
    Swarm = PSO(NoParts, 2, FuncCosto_Actual, "Meta Alcanzada", IterMaxPSO, [LimsX' ; LimsY']);
    
    % Un set de "runs" para cada tipo de restricción
    Restricciones = ["Mixto" "Inercia" "Constriccion"];
    for i = 1:numel(Restricciones)
        
        Restriccion_Actual = Restricciones(i);
        
        % El sweep cambia según el tipo de caso a utilizar.
        switch Restriccion_Actual
            
            case "Inercia"
                
                % Un set de "runs" para cada tipo de inercia disponible
                TiposInercia = ["Constant" "Linear" "Chaotic" "Random" "Exponent1"];
                for j = 1:numel(TiposInercia)
                    
                    Inercia_Actual = TiposInercia(j);
                    
                    % Runs para la combinación de parámetros actual
                    for k = 1:Runs
                    
                        Swarm.InitPSO(EnvironmentParams);
                        Swarm.SetRestricciones(Restriccion_Actual,LimsX,LimsY,'TipoInercia',Inercia_Actual);   
                        Swarm.RunStandardPSO("Full", Meta, EnvironmentParams);
                        
                        % Se extraen las iteraciones necesarias para converger
                        IterFinal = Swarm.IteracionActual;
                        
                        % Se da forma al feature vector que tendrá como input la
                        % Neural Net. Este consiste de un vector columna construido
                        % por las siguientes partes
                        % - 1000 filas: Coordenadas X de partículas
                        % - 1000 filas: Coordenadas Y de partículas
                        % - 1 fila: Media de coordenadas X
                        % - 1 fila: Media de coordenadas Y
                        % - 1 fila: Desviación estándar de coordenadas X
                        % - 1 fila: Desviación estándar de coordenadas Y
                        FeatureVector = [Swarm.Posicion_History{1}(:,1:IterFinal) ;
                                         Swarm.Posicion_History{2}(:,1:IterFinal) ;
                                         mean(Swarm.Posicion_History{1}(:,1:IterFinal));
                                         mean(Swarm.Posicion_History{2}(:,1:IterFinal));
                                         std(Swarm.Posicion_History{1}(:,1:IterFinal));
                                         std(Swarm.Posicion_History{2}(:,1:IterFinal))];
        
                        % Se agrega el feature vector generado como una nueva
                        % muestra.
                        Muestras = [Muestras FeatureVector];
                        
                        % Se toma nota de 4 de los parámetros actuales del PSO.
                        Params_Actuales = [Swarm.W ; Swarm.Phi1 ; Swarm.Phi2; Swarm.IteracionActual];
                        Params = [Params repmat(Params_Actuales,1,Swarm.IteracionActual)];
                        
                    end
                end
                
            otherwise
                
                for k = 1:Runs
                    Swarm.InitPSO(EnvironmentParams);
                    Swarm.SetRestricciones(Restriccion_Actual,LimsX,LimsY);   
                    Swarm.RunStandardPSO("Full", Meta, EnvironmentParams);
                    
                    % Se extraen las iteraciones necesarias para converger
                    IterFinal = Swarm.IteracionActual;
                    
                    % Se da forma al feature vector que tendrá como input la
                    % Neural Net. Este consiste de un vector columna construido
                    % por las siguientes partes
                    % - 1000 filas: Coordenadas X de partículas
                    % - 1000 filas: Coordenadas Y de partículas
                    % - 1 fila: Media de coordenadas X
                    % - 1 fila: Media de coordenadas Y
                    % - 1 fila: Desviación estándar de coordenadas X
                    % - 1 fila: Desviación estándar de coordenadas Y
                    FeatureVector = [Swarm.Posicion_History{1}(:,1:IterFinal) ;
                                     Swarm.Posicion_History{2}(:,1:IterFinal) ;
                                     mean(Swarm.Posicion_History{1}(:,1:IterFinal));
                                     mean(Swarm.Posicion_History{2}(:,1:IterFinal));
                                     std(Swarm.Posicion_History{1}(:,1:IterFinal));
                                     std(Swarm.Posicion_History{2}(:,1:IterFinal))];
    
                    % Se agrega el feature vector generado como una nueva
                    % muestra.
                    Muestras = [Muestras FeatureVector];
                    
                    % Se toma nota de 4 de los parámetros actuales del PSO.
                    Params_Actuales = [Swarm.W ; Swarm.Phi1 ; Swarm.Phi2; Swarm.IteracionActual];
                    Params = [Params repmat(Params_Actuales,1,Swarm.IteracionActual)];
                    
                    % Nueva permutación de parámetros de PSO
                    %Swarm.Phi1 = randi([2 15]);
                    %Swarm.Phi2 = randi([2 15]);
                end
                  
        end
        
    end
    
    % Se actualiza la barra de progreso
    waitbar(n / numel(FuncionesCosto));
    
end

close(ProgressBar);
Input = Muestras;
Output = Params;
save("Deep PSO Tuner\Datasets\PSOParameterSweep_Dataset",'Input','Output');