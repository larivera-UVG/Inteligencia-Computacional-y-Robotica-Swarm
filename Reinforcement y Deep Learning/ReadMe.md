## Por implementar

### Controladores
'''
% En el caso de los robots diferenciales, el cambio de estado (x') no
% depende del estado actual, sino únicamente de las entradas del
% controlador no escalado (u). Por lo tanto, A = 0, B y C = Vector
% Columna "identidad".
%
%       x' = Ax + Bu
%       y = Cx

%     A = 0 * eye(size(StateVars,2));
%     B = ones(size(StateVars,2), 1);                                                     % Vector columna "identidad" o de solo unos
%     C = ones(size(StateVars,2), 1)';                                                    % Vector columna "identidad" o de solo unos
%     Sistema = ss(A, B, C, 0);
%     
%     AAumentada = [A 0; -C 0];
%     
%     Q = eye(4);
%     R = 2000 * eye(2);
%     
%     LQI_Output = lqi(Sistema, Q, R);
%     K = LQI_Output(1:end-1);
%     Ki = LQI_Output(end);
% ------------------------------------------------------------
%     ErrorPos = PartPosicion_Actual - PuckPosicion_Actual;                               % Error de posición    
%     
%     AnguloMeta = atan2(ErrorPos(:,2), ErrorPos(:,1));                                   % Ángulo Meta (Theta_g): Ángulo que debería de buscar alcanzar el puck
%     ErrorAng = atan2(sin(AnguloMeta - PuckOrientacion_Actual), cos(AnguloMeta - PuckOrientacion_Actual));
%     
%     StateVars = [PuckPosicion_Actual PuckVelLineal];

    %ErrorPos = sqrt(sum(CompsErrorPos.^2, 2));                                           % Distancia euclideana existente entre la partícula y el Puck.
    %K = 3.12 * (1 - exp(-2 * ErrorPos)) ./ ErrorPos;                                    % Ponderación K en función de magnitud del error de posición
    
%     PuckVelLineal  = (2*tanh((K/PuckVelMax).*CompsErrorPos(:,1))) .* cos(PuckOrientacion_Actual) + ...
%                      (2*tanh((K/PuckVelMax).*CompsErrorPos(:,2))) .* sin(PuckOrientacion_Actual);
% %     PuckVelAngular = (2*tanh((K/PuckVelMax).*CompErrorPos(:,1))) .* -sin(PuckOrientacion_Actual)/RadioDisomorfismo + ...
% %                      (2*tanh((K/PuckVelMax).*CompErrorPos(:,2))) .* cos(PuckOrientacion_Actual)/RadioDisomorfismo;
%     
%     
%     % PID de Velocidad Angular
%     ErrorPID = ErrorAng - ErrorAngPrev;
%     ErrorAcumulado = ErrorAcumulado + ErrorAng;
%     
%     PuckVelAngular = KP*ErrorAng + KI*ErrorAcumulado + KD * ErrorPID;
%          
'''