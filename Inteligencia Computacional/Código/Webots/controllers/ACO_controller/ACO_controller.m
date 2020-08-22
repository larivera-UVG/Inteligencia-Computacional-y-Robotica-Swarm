% MATLAB controller for Webots
% File:          ACO_controller.m
% Date:
% Description:
% Author:
% Modifications:

% uncomment the next two lines if you want to use
% MATLAB's desktop to interact with the controller:
% desktop;
% keyboard;

TIME_STEP = 32;

% get and enable devices, e.g.:
%  camera = wb_robot_get_device('camera');
%  wb_camera_enable(camera, TIME_STEP);
%  motor = wb_robot_get_device('motor');
% control step
TIME_STEP = 32;  % milisegundos
ell = 71/2000;  % Distance from center en metros
r = 20.5/1000;  % Radio de las llantas en metros
MAX_SPEED = 6.28;
goal = [0, 0];  % Diagonal
goal = [-4, -5]; % Norte
% goal = [4, -4];
 goal = [-2, -4]; % Este
% goal = [-4, -2]; % Sur

%% Obtener todos los sensores del e-Puck

% Pose
position_sensor = wb_robot_get_device('gps');
orientation_sensor = wb_robot_get_device('compass');

left_motor = wb_robot_get_device('left wheel motor');
right_motor = wb_robot_get_device('right wheel motor');
wb_motor_set_position(left_motor, inf);
wb_motor_set_position(right_motor, inf);
wb_motor_set_velocity(left_motor, 0);
wb_motor_set_velocity(right_motor, 0);

% emitter = wb_robot_get_device('emitter');
% receiver = wb_robot_get_device('receiver');

% Enables GPS and compass
wb_gps_enable(position_sensor, TIME_STEP);
wb_compass_enable(orientation_sensor, TIME_STEP);
% wb_receiver_enable(receiver,TIME_STEP);

%% Valores iniciales
xg = goal(1);  zg = goal(2);
step = 0;
epsilon = 0.05;

%% Variables PID
% Acercamiento exponencial
alpha = 0.9;

% PID de orientación
eO_k_1 = 0; % Error derivativo
EO_k = 0;   % Error integral

% PID de posición
eP_1 = 0;
EP = 0;

% CONSTANTES DEL PID
% 1 - Acercamiento exponencial
% kP_O = 20;
% kD_O = 5;
% kI_O = 9;

% 2 - Velocidad lineal y angular
% kP_O2 = 1;
% kD_O2 = 100; 
% kI_O2 = 40;

% kP_P = 2;
% kD_P = 0;
% kI_P = 0.0001;

% 3 - Control de pose
k_rho = 0.1;
k_alpha = 50;
k_beta = -25; % Mejor: -25

% k_rho = 0.1;
% k_alpha = 0.5;
% k_beta = -25; % Mejor: -25

controlador = 3;
% controlador
% 0 - OFF
% 1 - PID de acercamiento exponencial
% 2 - PID
% 3 - Pose

% main loop:
% perform simulation steps of TIME_STEP milliseconds
% and leave the loop when Webots signals the termination
%
while wb_robot_step(TIME_STEP) ~= -1
    
    step = step + 1;
    
    pos = wb_gps_get_values(position_sensor);
    xi = pos(1);  zi = pos(3);
    
    north = wb_compass_get_values(orientation_sensor);
    rad = atan2(north(1), north(3));
    theta = rad + pi;  % Se corrige el ángulo para que esté igual que theta_g
    
    if (xi >= xg - epsilon) && (xi <= xg + epsilon) && (zi >= zg - epsilon) && (zi <= zg + epsilon)
        controlador = 0;
    end
    
    % ------------- OFF -------------
    if controlador == 0
        speed = [0, 0];
        
    % ------------- PID exp ---------
    elseif controlador == 1
        % Error total de posicion
        eP = sqrt((xg - xi)^2 + (zg - zi)^2);
        
        % Error de orientacion
        theta_g = atan2((zg - zi), (xg - xi));
        eO = atan2(sin(theta_g - theta), cos(theta_g - theta));
        
        
        % Control de velocidad angular
        eD = eO - eO_k_1;  % error derivativo
        EO_k = EO_k + eO;  % error acumulado
        w = kP_O*eO + kI_O*EO_k + kD_O*eD;
        eO_k_1 = eO;  % actualizar las variables
        
        v = MAX_SPEED*(1 - exp(-eP*eP*alpha))/eP;
        
        % velocidad uniciclo
        left_speed = (v + w*ell)/r;
        right_speed = (v - w*ell)/r;
        speed = [left_speed, right_speed];
        
    elseif controlador == 2
        % Error total de posicion
        eP = sqrt((xg - xi)^2 + (zg - zi)^2);
        
        % Error de orientacion
        theta_g = atan2((zg - zi), (xg - xi));
        eO = atan2(sin(theta_g - theta), cos(theta_g - theta));
        
%         formatSpec = 'xi: %.2f, zi: %.2f eP: %.2f | theta: %.2f theta g: %.2f eO: %.2f \n';
%         fprintf(formatSpec, xi, zi, eP, theta, theta_g, eO);

        % Control de velocidad lineal
        eP_D = eP - eP_1;
        EP = EP + eP;
        v = kP_P*eP + kI_P*EP + kD_P*eP_D;
        eP_1 = eP;
        
        % Control de velocidad angular
        eD = eO - eO_k_1;  % error derivativo
        EO_k = EO_k + eO;  % error acumulado
        w = kP_O2*eO + kI_O2*EO_k + kD_O2*eD;
        eO_k_1 = eO;  % actualizar las variables
        
        % velocidad uniciclo
        left_speed = (v + w*ell)/r;
        right_speed = (v - w*ell)/r;
        speed = [left_speed, right_speed];
        
    elseif controlador == 3
        % Error total de posicion
        rho = sqrt((xg - xi)^2 + (zg - zi)^2);
        
        % Error de orientacion
        theta_g = atan2((zg - zi), (xg - xi));
        alpha = -theta + theta_g;
        beta = -theta - alpha;
        v = k_rho*rho;
        w = k_alpha*alpha + k_beta*beta;
        
        % velocidad uniciclo
        left_speed = (v + w*ell)/r;
        right_speed = (v - w*ell)/r;
        speed = [left_speed, right_speed];
    end
    
    % Truncamos la velocidad
    for k = 1:2
        if speed(k) < -MAX_SPEED
            speed(k) = -MAX_SPEED;
        elseif speed(k) > MAX_SPEED
            speed(k) = MAX_SPEED;
        end
    end
    
    left_speed = speed(1); right_speed = speed(2);
    wb_motor_set_velocity(left_motor, left_speed);
    wb_motor_set_velocity(right_motor, right_speed);

end

% cleanup code goes here: write data to files, etc.
