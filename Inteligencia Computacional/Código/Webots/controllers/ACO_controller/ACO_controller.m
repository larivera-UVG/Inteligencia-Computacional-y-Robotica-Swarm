% MATLAB controller for Webots
% File:          ACO_controller.m
% Date:
% Description:
% Author:
% Modifications:

% uncomment the next two lines if you want to use
% MATLAB's desktop to interact with the controller:
desktop;
%keyboard;

TIME_STEP = 32;

% get and enable devices, e.g.:
%  camera = wb_robot_get_device('camera');
%  wb_camera_enable(camera, TIME_STEP);
%  motor = wb_robot_get_device('motor');
% control step
TIME_STEP = 32;
SPEED_UNIT = 0.00628;
ell = 71/2000;  % Distance from center
r = 20.5/1000;  % Radio de las llantas
MAX_SPEED = 6.28;
goal_points= [-5, -4]; % Este
%goal_points= [-2, -4]; % Este
% goal_points= [-4, -2]; % SUR

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
xg = goal_points(1);
zg = goal_points(2);
step = 0;
angle = 0;
alpha = 0.9;
epsilon = 0.1;

%% Variables PID
ex = 0;
ez = 0;
ep = 0;
theta_g = 0;
eo = 0;
v = 0;

e_k_1 = 0;
E_k = 0;
e_k = 0;
eD = 0;
u_k = 0;

% CONSTANTES DEL PID
kP = 8;
kD = 1;
kI = 5;

speed = zeros(1,2);
state = "f";
controlador = 1;
left_speed = 0;
right_speed = 0;
% main loop:
% perform simulation steps of TIME_STEP milliseconds
% and leave the loop when Webots signals the termination
%
while wb_robot_step(TIME_STEP) ~= -1

  step = step + 1;
  
  pos = wb_gps_get_values(position_sensor);
  xi = pos(1);
  zi = pos(3);  
  
  north = wb_compass_get_values(orientation_sensor);
  rad = atan2(north(1), north(3));
  angle = rad + pi;
  
   if (xi >= xg - epsilon) && (xi <= xg + epsilon) && (zi >= zg - epsilon) && (zi <= zg + epsilon)
        controlador = 0;
    end
    
    % ------------- OFF ------------- 
    if controlador == 0
        left_speed = 0;
        right_speed = 0;
 
    % ------------- PID ------------- 
    elseif controlador == 1
        % Error de posicion
        ex = xg - xi;
        ez = zg - zi;
        ep = sqrt(ex*ex + ez*ez);  % error total de posicion
        theta_g = atan2(ez, ex);

        % Error de orientacion
        eo = atan2(sin(theta_g - angle), cos(theta_g - angle));
        e_k = eo;
        
        disp(north)
        formatSpec = 'xi: %.2f, zi: %.2f ep: %.2f | theta: %.2f theta g: %.2f eo: %.2f \n';
        fprintf(formatSpec, xi, zi, ep, angle, theta_g, eo);
        
        % Control de velocidad angular
        eD = e_k - e_k_1;  % error derivat
        E_k = E_k + e_k;  % error acumulado
        u_k = kP*e_k + kI*E_k + kD*eD;  % salida del controlador
        e_k_1 = e_k;  % actualizar las variables
        
        
        v = MAX_SPEED*(1 - exp(-ep*ep*alpha))/ep;  % velocidad uniciclo
        
        left_speed = (v + u_k*ell)/r;
        right_speed = (v - u_k*ell)/r;
   end
    speed = [left_speed, right_speed];
    for k = 1:2
        if speed(k) < -MAX_SPEED
            speed(k) = -MAX_SPEED;
        elseif speed(k) > MAX_SPEED
            speed(k) = MAX_SPEED;
        end
    end
   % speed = [0, 0];
    left_speed = speed(1);
    right_speed = speed(2);
%    right_speed = MAX_SPEED/4;
    wb_motor_set_velocity(left_motor, left_speed);
    wb_motor_set_velocity(right_motor, right_speed);
         


end

% cleanup code goes here: write data to files, etc.
