function [VelLineal, VelAngular] = getControllerOutput(ControllerType, Meta, PuckPosicion_Actual, PuckOrientacion_Actual, RadioPuck)
% GETCONTROLLEROUTPUT Funci�n que retorna la velocidad lineal y angular de
% los E-Pucks de acuerdo al controlador deseado. 
% -------------------------------------------------------------------------
% Inputs:
%   - ControllerType: Tipo de controlador que se desea acoplar al E-Puck.
%     Seg�n el tipo de controlador se pueden llegar a requerir inputs
%     adicionales.
%   - Meta: Matriz de 1x2. Punto que desea alcanzar actualmente el E-Puck. 
%   - PuckPosicion_Actual: Matriz de Nx2. Cuenta con la misma estructura
%     que en el caso de "PartPosicion_Actual" con la diferencia que N ahora
%     simboliza el n�mero de robots.
%   - PuckOrientacion_Actual: Vector columna con N �ngulos en radianes, uno
%     por cada E-Puck. Este consiste del �ngulo que existe entre el eje X+
%     del plano y la l�nea de orientaci�n de los pucks si nos desplazamos
%     en contra de las manecillas del reloj. 
%   - RadioPuck: Radio de isomorfismo de E-Puck (Si eso son� a chino: Es
%     un ajuste que se hace porque no se puede suponer que el centro del
%     robot est� en el centro como tal. Se supone que est� adelante de �l,
%     com�nmente en el radio del mismo). 
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
%   - PID: Control PID con filtro "hard stops".    
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
    % Controlador de Pose con Criterio de Estabilidad de Lyapunov
    case "Lyapunov"
        
        % Par�metros de controlador
        K_Rho = 0.1;
        K_Alpha = 0.5;
        
        % Rho_p: Distancia de todos los Pucks a la Meta
        [~,Rho_p] = dsearchn(Meta,PuckPosicion_Actual);
        
        % Error de posici�n
        ErrorPos = Meta - PuckPosicion_Actual;
        %ErrorPos = PuckPosicion_Actual - Meta;
        
        % �ngulo de l�nea entre meta y robot (Theta goal)
        Theta_g = atan2(ErrorPos(:,2),ErrorPos(:,1));
        %Theta_g = wrapTo2Pi(Theta_g);
        %Theta_g = atan(ErrorPos(:,2) ./ ErrorPos(:,1));
        
        % Orientaci�n actual del robot
        Theta_o = PuckOrientacion_Actual;
        %Theta_o = wrapTo2Pi(Theta_o);
        %Theta_o = atan2(sin(Theta_o),cos(Theta_o));
        
        % Error de orientaci�n
        Alpha = - Theta_o + Theta_g;
        %Alpha = wrapTo2Pi(Alpha);
        %Alpha = atan2(sin(Alpha),cos(Alpha)) + pi;
        
        % Velocidades Lineal y Angular (Nadalini, p�g. 31)
        VelLineal = K_Rho .* Rho_p .* cos(Alpha);
        VelAngular = (K_Rho .* sin(Alpha) .* cos(Alpha)) + K_Alpha .* Alpha;
        
        % Si "alpha" se encuentra en cuadrantes izquierdos, se invierte la
        % velocidad lineal
        %CuadrantesIzq = Alpha <= -pi/2 | Alpha > pi/2;
        %VelLineal(CuadrantesIzq) = -VelLineal(CuadrantesIzq);
    
    % Controlador por Regulador Lineal Cuadr�tico (LQR)
    case "LQR"
        
        % Se inicializa el error acumulado, en caso a�n no tenga valor
        % alguno.
        if isempty(ErrorAcumulado)
            ErrorAcumulado = zeros(size(PuckPosicion_Actual));                             
        end
        
        % Error de posici�n entre robot y meta
        ErrorPos = PuckPosicion_Actual - Meta;
        
        % Controlador LQR
    	K = 0.1;              	% Par�metros de controlador (Nadalini, p�g 82)
        U = -K * (ErrorPos);  	% Retroalimentaci�n (Nadalini, p�g 36)
        
        % Actualizaci�n de velocidades
        VelLineal = U(:,1).*cos(PuckOrientacion_Actual) + U(:,2).*sin(PuckOrientacion_Actual);
        VelAngular = (-U(:,1).*sin(PuckOrientacion_Actual) + U(:,2).*cos(PuckOrientacion_Actual)) / RadioPuck;
    
    % Controlador Lineal Cuadr�tico Integral
    case "LQI"

        % Se inicializa el error acumulado, en caso a�n no tenga valor
        % alguno.
        if isempty(ErrorAcumulado)
            ErrorAcumulado = zeros(size(PuckPosicion_Actual));                             
        end
        
        % Par�metros de controlador (Nadalini, p�g 85 y 86)
        SamplingTime = 0.032;
        Bp = 0.95;             	% Amortiguamiento de control proporcional
        Bi = 0.01;              % Amortiguamiento de control integral                      
        KLQR = -0.2127;         % Control
        KLQI = -0.0224;
        
        % Error de posici�n entre robot y meta
        ErrorPos = Meta - PuckPosicion_Actual;
        
        % Controlador LQI (u = -K*e - Ki * Ei)
        U = (-KLQR * (1 - Bp) * ErrorPos) - (KLQI * ErrorAcumulado);
        
        % Integraci�n num�rica de error entre posici�n actual y meta
        ErrorAcumulado = ErrorAcumulado + (ErrorPos * SamplingTime);
        
        % Frenado de intregrador para evitar oscilaciones en posiciones
        ErrorAcumulado = (1 - Bi) * ErrorAcumulado;
        
        % Mapeo de velocidades LQI a velocidades de robot por medio de
        % difeomorfismo.
        VelLineal = U(:,1).*cos(PuckOrientacion_Actual) + U(:,2).*sin(PuckOrientacion_Actual);
        VelAngular = (-U(:,1).*sin(PuckOrientacion_Actual) + U(:,2).*cos(PuckOrientacion_Actual)) / RadioPuck;

end

