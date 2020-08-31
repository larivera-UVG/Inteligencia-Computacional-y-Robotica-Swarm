% MATLAB controller for Webots
% File: ACO_controller.m
% Date: agosto 2020
% Description: OFFLINE controller
% Author:
% Modifications:

% uncomment the next two lines if you want to use
% MATLAB's desktop to interact with the controller:
desktop;
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
MAX_CHANGE = 1;  % rad/s
goal = [0, 0];  % Diagonal larga
%goal = [0, 0.94];
% goal = [-4, -5]; % Norte
% goal = [-3, -3]; % Diagonal corta
% goal = [-4, -3]; % Sur corto
% goal = [-5, -3]; % Diagonal corta
% goal = [-5, -5]; % Diagonal corta
% goal = [-4, -2]; % Sur
% goal = [-2, -4]; % Este
% goal = [-5, -4]; % Oeste
goals = [- 0.8, 0.8;-0.6, 0.6; -0.4, 0.4; -0.2, 0.2; 0, 0;0.2, -0.2];
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
old_speed = zeros(2, 1);
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
kP_O = 20;
kD_O = 5;
kI_O = 9;

% 2 - Velocidad lineal y angular
kP_O2 = 1;
kD_O2 = 100; 
kI_O2 = 40;

kP_P = 2;
kD_P = 0;
kI_P = 0.0001;

% 3 - Control de pose
k_rho = 0.09;
k_alpha = 25;
k_beta = -0.05; 

% 4 - Control de pose de Lyapunov
k_rho2 = 0.09;
k_alpha2 = 25;

% 5 - Closed Loop Steering
k_1 = 1;
k_2 = 10;

% 6 - LQR
A = zeros(2); 
B = eye(2); 
Q = 0.1*eye(2);
R = eye(2);
Klqr = 2*lqr(A,B,Q,R);
Ti = 3;

% 7 - LQI
Cr = eye(2);
Dr = zeros(2);
AA = [A, zeros(size(Cr')); Cr, zeros(size(Cr,1))];
BB = [B; Dr];
QQ = eye(size(A,1) + size(Cr,1)); 
ref = [xg; zg];
sigma = zeros(2, 1); 
% Modificaciones de Aldo para el LQI:
bv_p = 0.95;          % Reducir velocidad de control proporcional en 95% evitando aceleracion brusca por actualizacion PSO
bv_i = 0.01;          % Reducir velocidad de control integrador en 1% cada iteracion para frenado al acercarse a Meta PSO

controlador = 8;
% controlador
% 0 - OFF
% 1 - PID de acercamiento exponencial
% 2 - PID
% 3 - Pose
% 4 - Pose de Lyapunov
% 5 - Steering Wheel
% 6 - LQR
% 7 - LQI
% 8 - TUC

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
%     disp(north);
%     disp(rad);
    %         formatSpec = 'xi: %.2f, zi: %.2f eP: %.2f | theta: %.2f theta g: %.2f eO: %.2f \n';
%         fprintf(formatSpec, xi, zi, eP, theta, theta_g, eO);
    
    theta = pi - rad;  % Se corrige el ángulo para que esté igual que theta_g
    
   
    if sqrt((xg - xi)^2 + (zg - zi)^2) <= epsilon
        controlador = 0;
    end

    % ------------- OFF -------------
    if controlador == 0
        v = 0;
        w = 0;
    % ------------- PID exp ---------
    elseif controlador == 1
        % Error total de posicion
        eP = sqrt((xg - xi)^2 + (zg - zi)^2);
        
        % Error de orientacion
        theta_g = -atan2((zg - zi), (xg - xi));
        eO = atan2(sin(theta_g - theta), cos(theta_g - theta));
        
        % Control de velocidad angular
        eD = eO - eO_k_1;  % error derivativo
        EO_k = EO_k + eO;  % error acumulado
        w = kP_O*eO + kI_O*EO_k + kD_O*eD;
        eO_k_1 = eO;  % actualizar las variables
        
        v = MAX_SPEED*(1 - exp(-eP*eP*alpha))/eP;
        
    elseif controlador == 2
        % Error total de posicion
        eP = sqrt((xg - xi)^2 + (zg - zi)^2);
        
        % Error de orientacion
        theta_g = -atan2((zg - zi), (xg - xi));
        eO = atan2(sin(theta_g - theta), cos(theta_g - theta));

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
        
    elseif controlador == 3
        % Error total de posicion
        rho = sqrt((xg - xi)^2 + (zg - zi)^2);
        
        % Error de orientacion
        theta_g = -atan2((zg - zi), (xg - xi));
        alpha = -theta + theta_g;
        beta = -theta - alpha;
        % disp(theta_g*180/pi)
        
        formatSpec = 'xi: %.2f, zi: %.2f  | theta: %.2f theta g: %.2f \n';
        fprintf(formatSpec, xi, zi, theta*180/pi, theta_g*180/pi);
        
        
        if (alpha < -pi)
            alpha = alpha + (2*pi);
        elseif (alpha > pi)
            alpha = alpha - (2*pi);
        end
        
        if (beta < -pi)
            beta = beta + (2*pi);
        elseif (beta > pi)
            beta = beta - (2*pi);
        end
        
        v = k_rho*rho;
        w = k_alpha*alpha + k_beta*beta;
        
    elseif controlador == 4       
        % Error total de posicion
        rho = sqrt((xg - xi)^2 + (zg - zi)^2);
        
        % Error de orientacion
        theta_g = -atan2((zg - zi), (xg - xi));
        alpha = -theta + theta_g;
        
        if (alpha < -pi)
            alpha = alpha + (2*pi);
        elseif (alpha > pi)
            alpha = alpha - (2*pi);
        end
               
        v = k_rho2 * rho * cos(alpha);
        w = k_rho2 * sin(alpha) * cos(alpha) + k_alpha2*alpha;
        
        if alpha <= -pi/2 || alpha > pi/2
            v = -v;
        end
        
    elseif controlador == 5
        % Error total de posicion
        rho = sqrt((xg - xi)^2 + (zg - zi)^2);
        % Error de orientacion
        theta_g = -atan2((zg - zi), (xg - xi));
        alpha = -theta + theta_g;
        beta = -theta - alpha;
        
        if (alpha < -pi)
            alpha = alpha + (2*pi);
        elseif (alpha > pi)
            alpha = alpha - (2*pi);
        end
        
        if (beta < -pi)
            beta = beta + (2*pi);
        elseif (beta > pi)
            beta = beta - (2*pi);
        end
        
        v = k_rho * rho * cos(alpha);
        w = (2/5)*(v/rho)*(k_2*(alpha + atan(-k_1*beta)) + (1 + k_1/(1 + (k_1*beta)^2))*sin(alpha));
        
    elseif controlador == 6
        e = [xi - xg; zi - zg];
        u = -Klqr*e;
        % Difeomorfismo:
        v = u(1)*cos(theta) + u(2)*sin(theta);
        w = (-u(1)*sin(theta) + u(2)*cos(theta))/ell;
        
    elseif controlador == 7
        R = 2000*eye(2);
        Klqi = lqr(AA, BB, QQ, R);
        e = [xi - xg; zi - zg];
        sigma = sigma + (Cr*[xi; zi] - ref)*TIME_STEP/1000;
        u = -Klqi*[e*(1-bv_p); sigma];
        sigma = sigma + [xg - xi; zg - zi]*TIME_STEP/1000;
        sigma = (1 - bv_i)*sigma;
        
        % Difeomorfismo:
        v = u(1)*cos(theta) + u(2)*sin(theta);
        w = (-u(1)*sin(theta) + u(2)*cos(theta))/ell;
    elseif controlador == 8
        % Error total de posicion
        eP = sqrt((xg - xi)^2 + (zg - zi)^2);
        I = 2;
        k = 3.12*(1 - exp(-2*eP))/eP;
        u1 = I*tanh(k*(xg - xi)/MAX_SPEED);
        u2 = I*tanh(k*(zg - zi)/MAX_SPEED);
        v = u1*cos(270-theta) + u2*sin(270-theta);
        w = (-u1*sin(270-theta) + u2*cos(270-theta))/ell;
        % Ni idea de por que 270-theta, pero asi me funciona xd    
    end
    
    % velocidad uniciclo
    left_speed = (v - w*ell)/r;
    right_speed = (v + w*ell)/r;
    speed = [left_speed, right_speed];
    
    % Truncamos la velocidad
    for k = 1:2
        if speed(k) < -MAX_SPEED
            speed(k) = -MAX_SPEED;
        elseif speed(k) > MAX_SPEED
            speed(k) = MAX_SPEED;
        end
        
        % Hardstop filter
        if abs(speed(k) - old_speed(k)) > MAX_CHANGE
            speed(k) = (speed(k) + 2*old_speed(k))/3;
        end
    end
    old_speed = speed;
    
    left_speed = speed(1); right_speed = speed(2);
    wb_motor_set_velocity(left_motor, left_speed);
    wb_motor_set_velocity(right_motor, right_speed);

end

% cleanup code goes here: write data to files, etc.
