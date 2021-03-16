function [W] = computeInertia(InertiaType, varargin)
% COMPUTEINERTIA Cálculo del coeficiente de inercia "W" según el tipo
% seleccionado por el usuario.
% -------------------------------------------------------------------------
%
% Tipos de inercia disponibles:
%
%   - Constante:
%     IntertiaType = "Constant"
%     Uso: 
%                 COMPUTEINERTIA("Constant",W)
%
%     Info: El enjambre aumenta su velocidad de convergencia y modera la
%     dispersión de las partículas. Valores entre 0.8 y 1.2 presentan un
%     buen equilibrio entre exploración y rapidez de convergencia.
%
%   - Linealmente Decreciente:
%     InertiaType = "Linear"
%     Uso:  
%           Full Control - COMPUTEINERTIA("Linear", IterActual, Wmax, Wmin, IteracionesMax)
%      Default Wmax/Wmin - COMPUTEINERTIA("Linear", IterActual, IteracionesMax)         
%
%     Info: Se recomienda un Wmax = 1.4 y un Wmin = 0.5. Con estos valores
%     se favorece la dispersión del enjambre para encontrar el mínimo global
%     al inicio la búsqueda y luego se acelera la convergencia del enjambre 
%     hacia ese punto, al llegar al valor de Wmin.
%
%   - Decreciente Caótica:
%     InertiaType = "Chaotic"
%     Uso: 
%         Full Control - COMPUTEINERTIA("Chaotic", IterActual, Wmax, Wmin, IteracionesMax, Z0)
%           Default Z0 - COMPUTEINERTIA("Chaotic", IterActual, Wmax, Wmin, IteracionesMax)
%
%     Info: Se elige un valor inicial de Z (Z0) entre [0,1] y se hace un 
%     mapeo logístico. Esta función logra darle más precisión al enjambre 
%     a la hora de encontrar el mínimo global, no obstante, no afecta la
%     rapidez de la convergencia. Z0 default = 0.2.
%
%   - Aleatoria:
%     InertiaType = "Random"
%     Uso: 
%                 COMPUTEINERTIA("Random")
%
%     Info: Esta asignación de inercia mejora la habilidad del enjambre
%     de salir de mínimos locales y reduce el número total de iteraciones
%     necesarias para que el algoritmo converja.
%
%   - Natural Exponent Inertia Weight Strategy (e1-PSO):
%     InertiaType = "Exponent1"
%     Uso:  
%           Full Control - COMPUTEINERTIA("Exponent1", IterActual, Wmax, Wmin, IteracionesMax)
%      Default Wmax/Wmin - COMPUTEINERTIA("Exponent1", IterActual, IteracionesMax)         
%
%     Info: Esta estrategia de ecuación exponencial reduce el error promedio
%     para que el enjambre logre llegar al punto mínimo utilizando un número 
%     de iteraciones constante. Permite que al inicio de la ejecución del 
%     algoritmo se tenga una buena exploración del espacio de búsqueda y se 
%     tenga una aceleración exponencial de la velocidad de convergencia al 
%     aumentar las iteraciones. Valores Default de W: Wmax = 1.4 / Wmin = 0.5.
%
% -------------------------------------------------------------------------

IP = inputParser;
            
% Inputs Obligatorios / Requeridos
IP.addRequired('InertiaType', @isstring);

% Parámetros (Usuario debe escribir su nombre seguido del valor que desea).
IP.addParameter('CostoGB', 0, @isnumeric);
IP.addParameter('CostoPB', 0, @isnumeric);
IP.addParameter('CostoLocal', 0, @isnumeric);
IP.addParameter('Wmin', 0.5, @isnumeric);
IP.addParameter('Wmax', 0.9, @isnumeric);
IP.addParameter('Iter', 1, @isnumeric);
IP.addParameter('MaxIter', 1000, @isnumeric);
IP.addParameter('CaosInicial', 0.2, @isnumeric);

% Se ordenan las variables de entrada contenidas en IP.Results según los 
% inputs previos
IP.parse(InertiaType, varargin{:});

CostoGB = IP.Results.CostoGB;                       % Costo del global best (GB) de todas las partículas
CostoPB = IP.Results.CostoPB;                       % Costo del personal best (PB) de cada partícula
CostoLocal = IP.Results.CostoLocal;                 % Costo actual de cada partícula
Wmin = IP.Results.Wmin;
Wmax = IP.Results.Wmax;
Iter = IP.Results.Iter;
MaxIter = IP.Results.MaxIter;
CaosInicial = IP.Results.CaosInicial;

switch InertiaType
    
    % CLASE PRIMITIVA: Inercias basadas en un único valor dado por el
    % usuario, ya sea una variable aleatoria o una constante
    
    % - Constant Inertia Weight (CIW)
    %   Fuente: A Modified Particle Swarm Optimizer (Shi & Eberhart, 1998)
    case {"Constant", "CIW"}
        
        % Se recomiendan valores entre 0.8 y 1.2. Valores superiores a 1.2
        % resultan en una mala exploración. Valores menores a 0.8 en un
        % alta susceptibilidad a mínimos locales.
        W = 0.95;
    
    % - Random Inertia Weight (RIW)
    % 	Fuente: Tracking & Optimizing Dynamic Systems with Particle Swarms
    %   (Shi & Eberhart, 2001).
    case {"Random", "RIW"}
        W = 0.5 + rand()/2;
      
        
    % CLASE ADAPTIVA: Inercias que monitorean la situación de búsqueda y se
    % adaptan según una señal o parámetro de feedback
    
    % - Global-average Local Best Inertia Weight (GLBIW)
    %   Fuente: On the Improved Performances of the PSO Algorithms with
    %   Adaptive parameters, Cross-Over Operators and RMS variants for
    %   computing optimal control of a class of hybrid systems (Arumugam &
    %   Rao, 2008).    
    case {"Global", "GLBIW"}
        W = 1.1 - (CostoGB / mean(CostoPB));
        
    % - Adaptive Inertia Weight (AIW)
    %   Fuente: Computational Intelligence: An Introduction (Engelbrecht, 
    %   2007).
    case {"Adaptive", "AIW"}
        % Cálculo del "improvement" o "m" (mejora relativa)
        m = (CostoGB - CostoLocal) ./ (CostoGB + CostoLocal);
        
        % La inercia es un vector, con cada fila representando la inercia
        % asociada a una partícula distinta.
        Winit = 0.1;
        Wend = 0.5;
        W = Winit + (Wend - Winit) * ((exp(m) - 1) ./ (exp(m) + 1));    
    
    % CLASE VARIANTE EN EL TIEMPO: Inercias en las que el valor de "W"
    % cambia según el número de iteración actual.
    
    % - Linearly Decreasing Inertia Weight (LDIW)
    %   Fuente: On the Performance of Linear Decreasing Inertia Weight
    %   Particle Swarm Optimization for Global Optimization (2013).
    case {"Linear", "LDIW"}
        W = Wmax - ((Wmax - Wmin) * (Iter/MaxIter));
    
    % - Chaotic Inertia Weight (CHIW)
    %   Fuente: Chaotic Inertia Weight in Particle Swarm Optimization
    %   (Feng, 2007).
    case {"Chaotic", "CHIW"}
        persistent Z
        
        if Iter <= 1
            Z = CaosInicial;
        else
            Z = 4 * Z * (1 - Z);
        end
        
        W = ((Wmax - Wmin) * (MaxIter - Iter)/MaxIter) + (Wmin * Z);
    
    % - Nonlinear Inertia Weight (NIW)
    %   Fuente: Nonlinear Inertia Weight Variation for Dynamic Adaptation
    %   in Particle Swarm Optimization (Chatterjee & Siarry, 2006).
    case {"Nonlinear", "NIW"}
        % Índice de modulación. Parámetro puede ser variado entre 0.9 y
        % 1.3, pero los resultados más prometedores parecen obtenerse al
        % emplear 1.2.
        n = 1.2;
        
        W = (((MaxIter - Iter)/ MaxIter)^n) * (Wmax - Wmin) + Wmin;
        
    % - Natural Exponential Inertia Weight (NEIW)
    %   Fuente: Natural Exponential Inertia Weight Strategy in Particle
    %   Swarm Optimization (Chen, Huang, Jia & Min, 2006).
    case {"NatExp", "NEIW"}    
        
        % Implementación de Aldo Nadalini
        % W = Wmin + (Wmax - Wmin) * exp((-1*Iter)/(MaxIter/10));
        
        % Implementación sugerida por Amoshahy
        W = Wmin + (Wmax - Wmin) * exp(-(Iter/(MaxIter/4))^2);
    
    % - Exponent Decreasing Inertia Weight (EDIW)
    %   Fuente: Particle Swarm Optimization Algorithm with Exponent
    %   Decreasing Inertia Weight and Stochastic Mutation (2009).
    case {"DecExp", "EDIW"}
        % Constantes que por experimentos de Li y Gao probaron ser la mejor 
        % alternativa
        d1 = 0.2;
        d2 = 7;
        Wmax = 0.95;
        
        W = (Wmax - Wmin - d1)*exp(MaxIter/(MaxIter + d2*Iter));   
        
    % - Flexible Exponential Inertia Weight (FEIW)
    %   Fuente: A Novel Flexible Inertia Weight PSO Algorithm (Amoshahy,
    %   2016).
    case {"Flexible", "FEIW"}
        
        % La parte de "Flexible" de este tipo de inercia viene del hecho
        % que a esta se le pueden modificar sus parámetros para obtener
        % diferentes comportamientos. En total se analizaron 6 variaciones
        % pero aquellas que mejor se comportaron fueron la FEIW-1 y FEIW-5.
        % A continuación se listan los parámetros para cada variación.
        
        % Numerito mágico (Número aureo)
        G = (1 + sqrt(5)) / 2;
        
        % FEIW-1 (La mejor)
        Psi = G^2;
        W1 = 0.001;
        W2 = 1.001;
        
        % FEIW-5 (La segunda mejor)
        % Psi = sqrt(G);
        % W1 = 0.3;
        % W2 = 1;
        
        Alpha1 = (W2*exp(Psi) - W1*exp(2*Psi)) / (1 - exp(2*Psi));
        Alpha2 = (W1 - W2*exp(Psi)) / (1 - exp(2*Psi));
        
        W = Alpha1*exp((-Psi*Iter)/MaxIter) + Alpha2*exp((Psi*Iter)/MaxIter); 
end

% NOTA SOBRE USO DE VARARGIN: La variable "varargin" consiste de un dato
% tipo celda que puede tener longitud variable. Esto permite la creación de
% funciones con un número de inputs variable, donde cada input puede llegar
% a tener un tipo de dato distinto. Es por esto que en los casos donde la
% inercia puede utilizarse en su valor "default" o "custom" se comprueba el
% número de elementos dentro de "varargin" (numel()). Si el número de
% elementos = 2 se asume que se tomará el valor default. De lo contrario
% se asume que se recibirán 4 parámetros adicionales a "InertiaType".

end
