% Description: MATLAB controller example for Webots
%              This example does not need the Image Processing Toolbox

% uncomment the next two lines if you want to use
% MATLAB's desktop and interact with the controller
desktop;
%keyboard;

% control step
TIME_STEP = 32;
SPEED_UNIT = 0.00628;
ell = 71/2000;  % Distance from center
r = 20.5/1000;  % Radio de las llantas
MAX_SPEED = 6.28;

goal_points= [-4, 0;
    2, 4;
    2, 2;
    2, -4];

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
step = 0;
angle = 0;
xg = goal_points(3, 1);
zg = goal_points(3, 2);
xi = 0;
zi = 0;

alpha = 0.9;
epsilon = 0.1;

%% Variables PID
ex = 0;
ez = 0;
ep = 0;
theta_g = 0;
eO = 0;
v = 0;

e_k_1 = 0;
E_k = 0;
e_k = 0;
eD = 0;
w = 0;

e_k_12 = 0;
E_k2 = 0;
e_k2 = 0;
eD2 = 0;
u_k2 = 0;

% CONSTANTES DEL PID
kP = 12;
kD = 0.1;
kI = 0.8;
% kP = 2;
% kI = 0.0001; 
% kD = 0;


kP1 = 0;
kD1 = 0;
kI1 = 0;

kP2 = 5;
kD2 = 0.1;
kI2 = 1;

speed = zeros(1,2);
controlador = 1;

%% Main loop
while wb_robot_step(TIME_STEP) ~= -1
    step = step + 1;
    
    north = wb_compass_get_values(orientation_sensor);
    % rad es el phi de aldo
    if north(3)*north(1) < 0
        rad = atan2(north(3), north(1));
    else
        rad = atan2(north(1), north(3));
    end
    
    pos = wb_gps_get_values(position_sensor);
    xi = pos(1);
    zi = pos(3);
    
    angle = rad;

    if (xi >= xg - epsilon) && (xi <= xg + epsilon) && (zi >= zg - epsilon) && (zi <= zg + epsilon) && (abs(eO) <= epsilon)
        controlador = 0;
    end
    
    

    formatSpec = 'xi: %.2f - zi: %.2f control: %d ep: %.2f theta: %.2f theta g: %.2f \n';
    fprintf(formatSpec, xi, zi, controlador, ep, angle, theta_g);
    
    % ------------- OFF -------------
    if controlador == 0
        left_speed = 0;
        right_speed = 0;
    elseif controlador == 1
        % Error de posicion
        
        ex = xg - xi;
        ez = zg - zi;
        e = [ex; ez];
        theta_g = atan2(ex, ez);  % atan2(ez, ex);
        ep = norm(e);  % error total de posicion
        
        % Error de orientacion
        eO = theta_g - angle;
        eO = atan2(sin(eO), cos(eO));
        e_k = eO;
        
        % Control de velocidad lineal
        v = MAX_SPEED*(1 - exp(-alpha*ep^2));
        
        % Controlador
        eD = e_k - e_k_1;  
        E_k = E_k + e_k;
        w = kP*e_k + kI*E_k + kD*eD;
        e_k_1 = e_k;  % actualizar las variables
        
        left_speed = (v - w*ell)/r;
        right_speed = (v + w*ell)/r;
        %         wb_console_print('si.', WB_STDOUT);
    elseif controlador == 2
        % Error de posicion
        ex = xg - xi;
        ez = zg - zi;
        e = [ex; ez];
        theta_g = atan2(ez, ex);
        ep = norm(e);  % error total de posicion
        e_k2 = ep;
        
        % Error de orientacion
        eO = theta_g - angle;
        eO = atan2(sin(eO), cos(eO));
        e_k = eO;
        
        % Controlador
        eD2 = e_k2 - e_k_12;  % error derivat
        E_k2 = E_k2 + e_k2;  % error acumulado
        v = kP2*e_k2 + kI2*E_k2 + kD2*eD2;  % salida del controlador
        e_k_12 = e_k2;  % actualizar las variables
        
        % Controlador
        eD = e_k - e_k_1;  % error derivat
        E_k = E_k + e_k;  % error acumulado
        w = kP1*e_k + kI1*E_k + kD1*eD;  % salida del controlador
        e_k_1 = e_k;  % actualizar las variables
        
        left_speed = (v - w*ell)/r;
        right_speed = (v + w*ell)/r;
        %         wb_console_print('si.', WB_STDOUT);
    end
    
    speed = [left_speed, right_speed];
    for k = 1:2
        if speed(k) < -MAX_SPEED
            speed(k) = -MAX_SPEED;
        elseif speed(k) > MAX_SPEED
            speed(k) = MAX_SPEED;
        end
    end
    left_speed = speed(1);
    right_speed = speed(2);
%     right_speed = MAX_SPEED/4;
    wb_motor_set_velocity(left_motor, left_speed);
    wb_motor_set_velocity(right_motor, right_speed);
    
end

% your cleanup code goes here