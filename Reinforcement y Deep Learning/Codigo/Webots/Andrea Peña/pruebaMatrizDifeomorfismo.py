""" =========================================================================
% CONTROLADOR DE AGENTES PARA TRANSFORMACIÓN DE VELOCIDADES LINEALES A
% VELOCIDADES RADIALES DE LAS RUEDAS
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 27/09/2019
% =========================================================================
% El siguiente script implementa las transformaciones necesarias para que
% los robots E-Puck se muevan a la velocidad determinada por el Supervisor.
% Es un controlador del tipo robot. 
========================================================================="""

"""pruebaMatrizDifeomorfismo controller."""

# Import de librerías
from controller import Robot
import math
import numpy as np
import pickle

TIME_STEP = 64
MAX_SPEED = 6.28

# Dimensiones robot
r = 0.0205
l = 0.0355
a = 0.0355

# Robot instance.
robot = Robot()
argc = int(robot.getControllerArguments())

# Enable compass
compass = robot.getCompass("compass")
compass.enable(TIME_STEP)
robot.step(TIME_STEP)

# get a handler to the motors and set target position to infinity (speed control)
leftMotor = robot.getMotor('left wheel motor')
rightMotor = robot.getMotor('right wheel motor')
leftMotor.setPosition(float('inf'))
rightMotor.setPosition(float('inf'))
leftMotor.setVelocity(0)
rightMotor.setVelocity(0)

# Main loop:
while robot.step(TIME_STEP) != -1:
    # Posiciones actuales y finales según Supervisor
    # print("AGENTE",argc)
    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos.pickle','rb') as f:
            posActuales = pickle.load(f)
    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos2.pickle','rb') as f:
            posNuevas = pickle.load(f)
    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos3.pickle','rb') as f:
            V = pickle.load(f)
    
    # Posición nueva/final
    posFinal = np.asarray([posNuevas[0][argc], -6.39203e-05, posNuevas[1][argc]])
    # print("posFinal",posFinal)
    
    # Posición actual
    posAct = np.asarray([posActuales[0, argc], -6.39203e-05, posActuales[1, argc]])
    # print("posAct",posAct)
    
    # Velocidades
    
    # Orientación robot
    comVal = compass.getValues()
    angRad = math.atan2(comVal[0],comVal[2])
    angDeg = (angRad/math.pi)*180
    if(angDeg < 0):
        angDeg = angDeg + 360
    theta_o = angDeg
    
	# Transformación de velocidad lineal y velocidad angular
    v = (V[0][argc])*(math.cos(theta_o*math.pi/180)) + (V[1][argc])*(math.sin(theta_o*math.pi/180))
    w = (V[0][argc])*(-math.sin(theta_o*math.pi/180)/a) + (V[1][argc])*(math.cos(theta_o*math.pi/180)/a)
    
    # Cálculo de velocidades de las ruedas   
    phi_r = (v+(w*l))/r
    # print(phi_r)
    phi_l = (v-(w*l))/r
    # print(phi_l)
    
    # Truncar velocidades a la velocidad maxima
    if(phi_r > 0):
        if(phi_r > MAX_SPEED):
            phi_r = MAX_SPEED
    else:
        if(phi_r < -MAX_SPEED):
            phi_r = -MAX_SPEED
            
    if(phi_l > 0):
        if(phi_l > MAX_SPEED):
            phi_l = MAX_SPEED
    else:
        if(phi_l < -MAX_SPEED):
            phi_l = -MAX_SPEED
    
	# Asignación de velocidades a las ruedas
    leftMotor.setVelocity(phi_l)
    rightMotor.setVelocity(phi_r)
    pass

