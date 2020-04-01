function Costo = CostFunction(X, FunctionName, varargin)
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
    end

% NOTA: En caso se deseen agregar más funciones, simplemente se debe agregar
% un "case" adicional y operar tomando en cuenta la forma de X. Porfavor
% implementar las operaciones de manera matricial (Evitando "for loops")
% para no dañar la eficiencia del programa.

end

