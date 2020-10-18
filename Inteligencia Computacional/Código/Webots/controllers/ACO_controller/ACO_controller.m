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
load('webots_test.mat');
controlador = 3;
% get and enable devices, e.g.:
%  camera = wb_robot_get_device('camera');
%  wb_camera_enable(camera, TIME_STEP);
%  motor = wb_robot_get_device('motor');
% control step
TIME_STEP = 32;  % milisegundos
ell = 71/2000;  % Distance from center en metros
r = 20.5/1000;  % Radio de las llantas en metros
MAX_SPEED = 6.28;
MAX_CHANGE = 0.001;  % rad/s
% goals = webots_path; %[- 0.8, 0.8;-0.6, 0.6; -0.4, 0.4; -0.2, 0.2; 0, 0;0.2, -0.2];

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

graph_type = "grid";

if graph_type == "grid"
    pos = [-0.94 0 0.94];
    if controlador == 3 || controlador == 4
        interpolate_step = 0.02;
        epsilon = 0.01;
    elseif controlador == 8
        interpolate_step = 0.005;
        epsilon = interpolate_step/2;
    elseif controlador == 6
        interpolate_step = 0.01;
        epsilon = 3*interpolate_step/5;
    elseif controlador == 7
        interpolate_step = 0.1;
        epsilon = 3*interpolate_step/5;
    elseif controlador == 5
        interpolate_step = 0.1;
        epsilon = interpolate_step/2;
    end
    x = [pos(1); webots_path(:, 1)]; 
    y = [pos(3); webots_path(:, 2)];
    xi = (x(1):interpolate_step:x(end))';
    yi = interp1q(x, y, xi);
    goals = [xi(2:end), yi(2:end)]; % [- 0.8, 0.8;-0.6, 0.6; -0.4, 0.4; -0.2, 0.2; 0, 0;0.2, -0.2];%
else   
    pos = [0.4376 0 0.4659];
    % epsilon = 0.02;
    % goals = [webots_path(2:end, 1), webots_path(2:end, 2)];
    if controlador == 3 || controlador == 4
        interpolate_step = 0.02;
        epsilon = 0.01;
    end
    x = [pos(1); webots_path(:, 1)]; 
    y = [pos(3); webots_path(:, 2)];
    xi = (x(1):interpolate_step:x(end))';
    yi = spline(x, y, xi);
    goals = [xi(2:end), yi(2:end)];
end


% Graficando la interpolaci�n y el camino normal
% subplot(1, 2, 1)
% scatter(x,y,'Marker','o','MarkerFaceColor','k', 'MarkerEdgeColor', 'k')
% subplot(1, 2, 2)
% scatter(xi,yi,'Marker','o','MarkerFaceColor','k', 'MarkerEdgeColor', 'k')
% plot(x,y,'k*',xi,yi,'r*')
% drawnow;

xg = goals(1, 1);  
zg = goals(1, 2);
step = 0;

old_speed = zeros(2, 1);


%% Variables de controladores
% Acercamiento exponencial
alpha = 0.9;

% PID de orientaci�n
eO_k_1 = 0; % Error derivativo
EO_k = 0;   % Error integral

% PID de posici�n
eP_1 = 0;
EP = 0;

% CONSTANTES DEL PID
% 1 - Acercamiento exponencial
kP_O = 20;
kD_O = 5;
kI_O = 9;

% 2 - Velocidad lineal y angular
kP_O2 = 0.01;
kD_O2 = 0; 
kI_O2 = 0;

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
yn_1 = [0, 0];
yn = [0, 0];
x_n = [0, 0];

controlador_copy = controlador;
stop_counter = 0;
path_node = 1;
save('analysis.mat', 'controlador')
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

%% Variables para graficar
pos = wb_gps_get_values(position_sensor);
xi = pos(1);  zi = pos(3);
trajectory = [xi, zi];
v_hist = [];
w_hist = [];
rwheel_hist = [];
lwheel_hist = [];

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
    
    if rad < 0
       rad = rad + 2*pi; 
    end
    
%     disp(north);
%     disp(rad);
    %         formatSpec = 'xi: %.2f, zi: %.2f eP: %.2f | theta: %.2f theta g: %.2f eO: %.2f \n';
%         fprintf(formatSpec, xi, zi, eP, theta, theta_g, eO);
    
    theta = pi - rad;  % Se corrige el �ngulo para que est� igual que theta_g
%     if xg == goals(length(goals), 1) && zg == goals(length(goals), 2)
%         epsilon = 0.05;
%     end
   
    if sqrt((xg - xi)^2 + (zg - zi)^2) <= epsilon
        controlador = 0;
    end

    % ------------- OFF -------------
    if controlador == 0
        if xg == goals(length(goals), 1) && zg == goals(length(goals), 2)
            v = 0;
            w = 0;
        else
            controlador = controlador_copy;
            path_node = path_node + 1;
            xg = goals(path_node, 1);  zg = goals(path_node, 2);
        end
        
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
        
        v = MAX_SPEED*(1 - exp(-eP*eP*alpha));
        
        formatSpec = 'xi: %.2f, zi: %.2f  | theta: %.2f theta g: %.2f eO:%.2f sin: %.2f cos: %.2f \n';
        fprintf(formatSpec, xi, zi, theta*180/pi, theta_g*180/pi, eO, sin(theta_g - theta), cos(theta_g - theta));
        
        
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
        
        theta_g = -atan2((zg - zi), (xg - xi));
        eO = atan2(sin(theta_g - theta), cos(theta_g - theta));

        %formatSpec = 'xi: %.2f, zi: %.2f  | theta: %.2f theta g: %.2f eO:%.2f sin: %.2f cos: %.2f \n';
        %fprintf(formatSpec, xi, zi, theta*180/pi, theta_g*180/pi, eO, sin(theta_g - theta), cos(theta_g - theta));
        [controlador xi zi xg zg]
        
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
        v = u(1)*cos(-theta) + u(2)*sin(-theta);
        w = (-u(1)*sin(-theta) + u(2)*cos(-theta))/ell;
        [controlador xi zi xg zg]
    elseif controlador == 7
        R = 2000*eye(2);
        Klqi = lqr(AA, BB, QQ, R);
        e = [xi - xg; zi - zg];
        sigma = sigma + (Cr*[xi; zi] - ref)*TIME_STEP/1000;
        u = -Klqi*[e*(1-bv_p); sigma];
        sigma = sigma + e*TIME_STEP/1000;
        bv_i = -0.05;
        sigma = (1 - bv_i)*sigma;
        [controlador xi zi xg zg]
        
        % Difeomorfismo:
        v = u(1)*cos(-theta) + u(2)*sin(-theta);
        w = (-u(1)*sin(-theta) + u(2)*cos(-theta))/ell;
    elseif controlador == 8
        % Error total de posicion
        eP = sqrt((xg - xi)^2 + (zg - zi)^2);
        I = 2;
        k = 3.12*(1 - exp(-2*eP))/eP;
        u1 = I*tanh(k*(xg - xi)/MAX_SPEED);
        u2 = I*tanh(k*(zg - zi)/MAX_SPEED);
        v = u1*cos(-theta) + u2*sin(-theta);
        w = (-u1*sin(-theta) + u2*cos(-theta))/ell;
        [controlador xi zi xg zg]
    end
    
    % velocidad uniciclo
    left_speed = (v - w*ell)/r;
    right_speed = (v + w*ell)/r;
    speed = [left_speed, right_speed];
    
    % Truncamos la velocidad
    for k = 1:2
        
        
        % Hardstop filter
        %         if abs(speed(k) - old_speed(k)) > MAX_CHANGE
        %             speed(k) = (speed(k) + 2*old_speed(k))/3;
        %         end
        if controlador == 3 || controlador == 4
            if (abs(speed(k)) < 1) && (controlador ~= 0)
                if path_node >= length(goals)-1
                    speed(k) = (speed(k)+ MAX_SPEED/2)*exp(-stop_counter);
                    stop_counter = stop_counter + 0.0375;
                else
                    speed(k) = speed(k) + MAX_SPEED/2;
                end
            end
        elseif controlador == 8
            lambda = 0.95;
            
            if path_node <= 10
                x_n(k) = speed(k);
                yn(k) = ((1-lambda)*x_n(k) + lambda*yn_1(k));
                speed(k) = yn(k);
                yn_1(k) = yn(k);
            else
                if (abs(speed(k)) < 1) && (controlador ~= 0)
                    x_n(k) = speed(k)*2;
                    yn(k) = ((1-lambda)*x_n(k) + lambda*yn_1(k));
                    speed(k) = yn(k);
                    yn_1(k) = yn(k);
                end
            end
            
        elseif controlador == 6
            lambda = 0.95;
            
            if path_node <= 5
                x_n(k) = speed(k);
                yn(k) = ((1-lambda)*x_n(k) + lambda*yn_1(k));
                speed(k) = yn(k);
                yn_1(k) = yn(k);
            else
                if (abs(speed(k)) < 1) && (controlador ~= 0)
                    x_n(k) = speed(k)-1;
                    yn(k) = ((1-lambda)*x_n(k) + lambda*yn_1(k));
                    speed(k) = yn(k);
                    yn_1(k) = yn(k);
                end
            end
            
        elseif controlador == 5
            lambda = 0.95;
            
            if path_node <= 5
                x_n(k) = speed(k);
                yn(k) = ((1-lambda)*x_n(k) + lambda*yn_1(k));
                speed(k) = yn(k);
                yn_1(k) = yn(k);
            else
                if (abs(speed(k)) < 1) && (controlador ~= 0)
                    x_n(k) = speed(k)*4;
                    yn(k) = ((1-lambda)*x_n(k) + lambda*yn_1(k));
                    speed(k) = yn(k);
                    yn_1(k) = yn(k);
                end
            end
        end
        
        
        if speed(k) < -MAX_SPEED
            speed(k) = -MAX_SPEED;
        elseif speed(k) > MAX_SPEED
            speed(k) = MAX_SPEED;
        end
        
    end
    
            
       
    old_speed = speed;
    
    left_speed = speed(1); right_speed = speed(2);
    wb_motor_set_velocity(left_motor, left_speed);
    wb_motor_set_velocity(right_motor, right_speed);

    trajectory = [trajectory; [xi, zi]];
    v_hist = [v_hist; v];
    w_hist = [w_hist; w];
    rwheel_hist = [rwheel_hist; right_speed];
    lwheel_hist = [lwheel_hist; left_speed];
    goal = [xg, zg];
    save('analysis.mat', 'trajectory', 'v_hist', 'w_hist', 'rwheel_hist', 'lwheel_hist', 'goal','-append')
end

% cleanup code goes here: write data to files, etc.
