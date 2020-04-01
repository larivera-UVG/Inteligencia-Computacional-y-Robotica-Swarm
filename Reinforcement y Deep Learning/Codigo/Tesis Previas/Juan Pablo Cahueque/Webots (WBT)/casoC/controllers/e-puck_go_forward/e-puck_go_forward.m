TIME_STEP = 64;

% get the motor devices
left_motor = wb_robot_get_device('left wheel motor');
right_motor = wb_robot_get_device('right wheel motor');
% set the target position of the motors
wb_motor_set_position(left_motor, 10.0);
wb_motor_set_position(right_motor, 10.0);

while wb_robot_step(TIME_STEP) ~= -1
end
