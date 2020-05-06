function [VelLineal, VelAngular] = getControllerOutput(ControllerType, PartPosicion_Actual, PuckPosicion_Actual, PuckOrientacion_Actual, Iter, varargin)
% GETCONTROLLEROUTPUT Funci�n que retorna la velocidad lineal y angular de
% los E-Pucks de acuerdo al controlador deseado. 
% -------------------------------------------------------------------------
% Inputs:
%   - ControllerType: Tipo de controlador que se desea acoplar al E-Puck.
%     Seg�n el tipo de controlador se pueden llegar a requerir inputs
%     adicionales.
%   - PartPosicion_Actual: Matriz de Nx2, donde N consiste del n�mero de
%     part�culas y las dos columnas corresponden a las coords (X,Y) de las
%     part�culas sobre el plano. 
%   - PuckPosicion_Actual: Matriz de Nx2. Cuenta con la misma estructura
%     que en el caso de "PartPosicion_Actual" con la diferencia que N ahora
%     simboliza el n�mero de robots.
%   - PuckOrientacion_Actual: Vector columna con N �ngulos en radianes, uno
%     por cada E-Puck. Este consiste del �ngulo que existe entre el eje X+
%     del plano y la l�nea de orientaci�n de los pucks si nos desplazamos
%     en contra de las manecillas del reloj. 
%   - Iter: N�mero de iteraci�n actual del algoritmo principal. Requerido
%     porque algunos controladores requieren una inicializaci�n previa.
%     Dado que esta inicializaci�n cambia seg�n el controlador, se prefiri�
%     utilizar variables "persistentes" y contener todas las variables
%     dentro de la funci�n.
%
% Outputs:
%   - VelLineal: Vector columna con tantas filas como Pucks. Velocidad en
%     la direcci�n de la l�nea de orientaci�n del Puck.
%   - VelAngular: Vector columna con tantas filas como Pucks. Velocidad
%     angular o tasa a la que cambia el �ngulo de la l�nea de orientaci�n
%     del Puck.
% -------------------------------------------------------------------------
%
% Opciones "ControllerType"
%
%   - TUC-LQR: Control LQR dise�ado utilizando la funci�n lqr(A,B,Q,R) de 
%     Matlab donde A = [0 0; 0 0], B = [1 0; 0 1], R = B y Q = B*0.01.
%     Utilizando este controlador se observaron trayectorias casi rectas
%     hacia la meta. No ventajoso para espacios de b�squeda con obst�culos.
%     Par�metros adicionales: RadioCuerpoPuck
%
%   - TUC-LQI: Control LQI dise�ado utilizando la funci�n lqr(A,B,Q,R) de 
%     Matlab donde A = 0, B = I, C = I, Q = eye(4) y R = 2000 * eye(2). 
%     Las matrices resultantes K y Ki fueron 0.2127 * eye(2) y -0.0224 *
%     eye(2) respectivamente. Resultados casi id�nticos a los del LQR, con
%     la diferencia que este presentaba velocidades m�s "suaves".
%     Par�metros adicionales: RadioCuerpoPuck, Posicion_GlobalBest
%
% -------------------------------------------------------------------------

% Variables que mantienen su valor entre diferentes llamadas a una funci�n
persistent ErrorAcumulado

switch ControllerType
    case 'TUC-LQR'
        RadioCuerpoPuck = varargin{1};

        if Iter == 2                                                        % Se inicializan las variables. El loop principal inicia en 2 no en 1.     
            ErrorAcumulado = PartPosicion_Actual;
        end
        
    	K = 0.1;                                                            % Par�metros de controlador (Nadalini, p�g 82)
        U = -K * (PuckPosicion_Actual - PartPosicion_Actual);               % Retroalimentaci�n (Nadalini, p�g 36)
        
        % Actualizaci�n de velocidades
        VelLineal = U(:,1).*cos(PuckOrientacion_Actual) + U(:,2).*sin(PuckOrientacion_Actual);
        VelAngular = (-U(:,1).*sin(PuckOrientacion_Actual) + U(:,2).*cos(PuckOrientacion_Actual)) / RadioCuerpoPuck;
    
    case 'TUC-LQI'
        RadioCuerpoPuck = varargin{1};
        Posicion_GlobalBest = varargin{2};
        
        % El loop principal inicia en 2 no en 1
        if Iter == 2
            ErrorAcumulado = PartPosicion_Actual;                           % Se inicializan las variables. El loop principal inicia en 2 no en 1.     
        end
        
        % Par�metros de controlador (Nadalini, p�g 85 y 86)
        SamplingTime = 0.032;
        Bp = 0.95;                                                          % Amortiguamiento de control proporcional
        Bi = 0.01;                                  
        KLQR = -0.2127;
        KLQI = -0.0224;
        
        % Controlador LQI (u = -K*e - Ki * Ei)
        U = -KLQR * (1 - Bp) * (PuckPosicion_Actual - PartPosicion_Actual) - KLQI * ErrorAcumulado;
        
        % Integraci�n num�rica de error entre posici�n actual y global best
        ErrorAcumulado = ErrorAcumulado + (Posicion_GlobalBest - PuckPosicion_Actual) * SamplingTime;
        
        % Frenado de intregrador para evitar oscilaciones en posiciones
        ErrorAcumulado = (1 - Bi) * ErrorAcumulado;
        
        % Mapeo de velocidades LQI a velocidades de robot por medio de
        % difeomorfismo.
        VelLineal = U(:,1).*cos(PuckOrientacion_Actual) + U(:,2).*sin(PuckOrientacion_Actual);
        VelAngular = (-U(:,1).*sin(PuckOrientacion_Actual) + U(:,2).*cos(PuckOrientacion_Actual)) / RadioCuerpoPuck;

end

