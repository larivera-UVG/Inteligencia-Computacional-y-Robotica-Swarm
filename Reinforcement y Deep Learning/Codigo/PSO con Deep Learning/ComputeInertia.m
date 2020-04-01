function [W] = ComputeInertia(InertiaType, varargin)
% COMPUTEINERTIA C�lculo del coeficiente de inercia W (omega). 
% ------------------------------------------------------------
% Tipos de inercia disponibles:
%
%   - Constante
%       IntertiaType = "Constant"
%       Uso: 
%                   COMPUTEINERTIA("Constant",W)
%
%       Info: El enjambre aumenta su velocidad de convergencia y modera la
%       dispersi�n de las part�culas. Valores entre 0.8 y 1.2 presentan un
%       buen equilibrio entre exploraci�n y rapidez de convergencia.
%
%   - Linealmente Decreciente
%       InertiaType = "Linear"
%       Uso:  
%             Full Control - COMPUTEINERTIA("Linear", IterActual, Wmax, Wmin, IteracionesMax)
%        Default Wmax/Wmin - COMPUTEINERTIA("Linear", IterActual, IteracionesMax)         
%
%       Info: Se recomienda un Wmax = 1.4 y un Wmin = 0.5. Con estos valores
%       se favorece la dispersi�n del enjambre para encontrar el m�nimo global
%       al inicio la b�squeda y luego se acelera la convergencia del enjambre 
%       hacia ese punto, al llegar al valor de Wmin.
%
%   - Decreciente Ca�tica
%       InertiaType = "Chaotic"
%       Uso: 
%           Full Control - COMPUTEINERTIA("Chaotic", IterActual, Wmax, Wmin, IteracionesMax, Z0)
%             Default Z0 - COMPUTEINERTIA("Chaotic", IterActual, Wmax, Wmin, IteracionesMax)
%
%       Info: Se elige un valor inicial de Z (Z0) entre [0,1] y se hace un 
%       mapeo log�stico. Esta funci�n logra darle m�s precisi�n al enjambre 
%       a la hora de encontrar el m�nimo global, no obstante, no afecta la
%       rapidez de la convergencia. Z0 default = 0.2.
%
%   - Aleatoria
%       InertiaType = "Random"
%       Uso: 
%                   COMPUTEINERTIA("Random")
%
%       Info: Esta asignaci�n de inercia mejora la habilidad del enjambre
%       de salir de m�nimos locales y reduce el n�mero total de iteraciones
%       necesarias para que el algoritmo converja.
%
%   - Natural Exponent Inertia Weight Strategy (e1-PSO)
%       InertiaType = "Exponent1"
%       Uso:  
%             Full Control - COMPUTEINERTIA("Exponent1", IterActual, Wmax, Wmin, IteracionesMax)
%        Default Wmax/Wmin - COMPUTEINERTIA("Exponent1", IterActual, IteracionesMax)         
%
%       Info: Esta estrategia de ecuaci�n exponencial reduce el error promedio
%       para que el enjambre logre llegar al punto m�nimo utilizando un n�mero 
%       de iteraciones constante. Permite que al inicio de la ejecuci�n del 
%       algoritmo se tenga una buena exploraci�n del espacio de b�squeda y se 
%       tenga una aceleraci�n exponencial de la velocidad de convergencia al 
%       aumentar las iteraciones. Valores Default de W: Wmax = 1.4 / Wmin = 0.5.

switch InertiaType
    % Inercia Constante
    % Obtenido de: A Modified Particle Swarm Optimizer (Shi & Eberhart, 1998).
    case "Constant"
        W = varargin{1};
    
    % LDIW-PSO: Inercia Lineal Decreciente
    % Obtenido de: On the Performance of Linear Decreasing Inertia Weight
    % Particle Swarm Optimization for Global Optimization (2013).
    case "Linear"
        switch numel(varargin)
            case 2                          % Uso de Wmax y Wmin default
                Wmax = 1.4; Wmin = 0.5;
                Iter = varargin{1};
                MaxIter = varargin{2};
            otherwise                       % Control total de par�metros
                Iter = varargin{1};
                Wmax = varargin{2};
                Wmin = varargin{3};
                MaxIter = varargin{4}; 
        end
        
        W = Wmax - ((Wmax - Wmin) * (Iter/MaxIter));
    
    % CDIW-PSO: Inercia Decreciente Ca�tica
    % Obtenido de: On the Performance of Linear Decreasing Inertia Weight
    % Particle Swarm Optimization for Global Optimization (2013).
    case "Chaotic"
        persistent Z
        Iter = varargin{1};
        Wmax = varargin{2};
        Wmin = varargin{3};
        MaxIter = varargin{4};
        
        if Iter <= 1
            switch numel(varargin)
                case 4                      % Valor default para Z0
                    Z = 0.2;
                otherwise                   % Control total de par�metros
                    Z = varargin{5};
            end
        end
        
        Z = 4 * Z * (1 - Z);
        W = ((Wmax - Wmin) * (MaxIter - Iter)/MaxIter) + (Wmin * Z);
    
    % Inercia Aleatoria
    % Obtenido de: Inertia Weight Strategies in Particle Swarm Optimization (2012).
    case "Random"
        W = 0.5 + rand()/2;
    
    % e1-PSO: Natural Exponent Inertia Weight Strategy
    % Obtenido de: Inertia Weight Strategies in Particle Swarm Optimization (2012).
    case "Exponent1"
        switch numel(varargin)
            case 2                          % Uso de Wmax y Wmin default
                Wmax = 1.4; Wmin = 0.5;
                Iter = varargin{1};
                MaxIter = varargin{2};
            otherwise                       % Control total de par�metros
                Iter = varargin{1};
                Wmax = varargin{2};
                Wmin = varargin{3};
                MaxIter = varargin{4}; 
        end
        
        W = Wmin + (Wmax - Wmin) * exp((-1*Iter)/(MaxIter/10));
        
end

% NOTA SOBRE USO DE VARARGIN: La variable "varargin" consiste de un dato
% tipo celda que puede tener longitud variable. Esto permite la creaci�n de
% funciones con un n�mero de inputs variable, donde cada input puede llegar
% a tener un tipo de dato distinto. Es por esto que en los casos donde la
% inercia puede utilizarse en su valor "default" o "custom" se comprueba el
% n�mero de elementos dentro de "varargin" (numel()). Si el n�mero de
% elementos = 2 se asume que se tomar� el valor default. De lo contrario
% se asume que se recibir�n 4 par�metros adicionales a "InertiaType".

end
