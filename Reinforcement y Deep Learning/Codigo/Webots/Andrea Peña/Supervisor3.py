""" =========================================================================
% SIMULACIÓN MODELO DINÁMICO CON CONTROL DE FORMACIÓN, USANDO COSENO
% HIPERBÓLICO, Y EVASIÓN DE COLISIONES INCLUYENDO LÍMITES DE VELOCIDAD
% =========================================================================
% Autor: Andrea Maybell Peña Echeverría
% Última modificación: 27/09/2019
% (MODELO 6)
% =========================================================================
% El siguiente script implementa la simulación del modelo dinámico de
% modificación a la ecuación de consenso utilizando evasión de obstáculos y
% luego una combinación de control de formación con una función de coseno 
% hiperbólico para grafos mínimamente rígidos y evasión de obstáculos.
% Además incluye cotas de velocidad para que no se sobrepasen los límites
% físicos de los agentes. 
% Es un controlador del tipo supervisor. 
========================================================================="""

"""Supervisor3 controller."""

# Imports de librerías
from controller import Robot, Supervisor
import numpy as np
import random
import math
import pickle
from funVel import Fmatrix


TIME_STEP = 64
# Se crea instancia de supervisor
supervisor = Supervisor()

""" ARENA """
arena = supervisor.getFromDef("Arena")
size = arena.getField("floorSize")
sizeVec = size.getSFVec2f()				# vector con el tamaño de la arena

""" AGENTES """
N = 10									# cantidad de agentes
r = 0.1								 	# radio a considerar para evitar colisiones
R = 1									# rango del radar
MAX_SPEED = 6.28						# velocidad máxima
agente0 = supervisor.getFromDef("Agente0")
agente1 = supervisor.getFromDef("Agente1")
agente2 = supervisor.getFromDef("Agente2")
agente3 = supervisor.getFromDef("Agente3")
agente4 = supervisor.getFromDef("Agente4")
agente5 = supervisor.getFromDef("Agente5")
agente6 = supervisor.getFromDef("Agente6")
agente7 = supervisor.getFromDef("Agente7")
agente8 = supervisor.getFromDef("Agente8")
agente9 = supervisor.getFromDef("Agente9")

Agentes = [agente0, agente1, agente2, agente3, agente4, agente5, agente6, agente7, agente8, agente9]

## Posiciones de los agentes ##
pos0 = agente0.getField("translation")
pos1 = agente1.getField("translation")
pos2 = agente2.getField("translation")
pos3 = agente3.getField("translation")
pos4 = agente4.getField("translation")
pos5 = agente5.getField("translation")
pos6 = agente6.getField("translation")
pos7 = agente7.getField("translation")
pos8 = agente8.getField("translation")
pos9 = agente9.getField("translation")

PosTodos = [pos0, pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9]
X = np.empty([2,N])

# Asignar posiciones random a cada agente
for a in range(0,N):
    sizeR0 = sizeVec[0] - 4*r
    sizeR1 = sizeVec[1] - 4*r
    X[0,a] = random.random()*sizeR0 - sizeR0/2 - 2*r
    X[1,a] = random.random()*sizeR1 - sizeR1/2 - 2*r 
print("X",X)

# Revisión de las posiciones    
cW1 = 2						# contador de agentes sobre agentes
while(cW1 > 1 or cW2 > 1):
    cW1 = 0
    cW2 = 0
    # Asegurar que los agentes no empiecen uno sobre otro
    contR = 1				# contador de intersecciones
    while(contR > 0):
        contR = 0
        for i in range(1, N):
            for j in range(1, N-i):
                resta = math.sqrt((X[0,i]-X[0,i+j])**2+(X[1,i]-X[1,i+j])**2)	# diferencia entre las posiciones
                if(abs(resta) < r):
                    X[0,i+j] = X[0,i+j] + 0.1									# cambio de posición
                    X[1,i+j] = X[1,i+j] + 0.1									# hay intersección
                    contR = contR+1
        cW1 = cW1+1

Xi = X
  
# Asignar posiciones revisadas  
for b in range(0, N):
    PosTodos[b].setSFVec3f([X[0,b], -6.39203e-05, X[1,b]])


# Posiciones actuales
posActuales = np.zeros([2,N])
posNuevas = np.zeros([2,N])

# Matriz de velocidades
V = np.empty([2,N])

# Matriz de formación
d = Fmatrix(1,8)
print(d)

# Main loop:
cambio = 0						# variable para cambio de control 
while supervisor.step(TIME_STEP) != -1:
    print("cambio",cambio)
	
	# Se obtienen posiciones actuales
    for c in range(0,N):
        posC = Agentes[c].getField("translation")
        posActuales[0][c] = posC.getSFVec3f()[0]
        posActuales[1][c] = posC.getSFVec3f()[2]        
    
    for g in range(0,N):
        E0 = 0
        E1 = 0
        for h in range(0,N):
            dist = np.asarray([posActuales[0][g]-posActuales[0][h], posActuales[1][g]-posActuales[1][h]])	# vector xi - xj   
            mdist = math.sqrt(dist[0]**2 + dist[1]**2)														# norma euclidiana vector xi - xj
            dij = 0.2*d[g][h]																				# distancia deseada entre agentes i y j
            
			# Peso añadido a la ecuación de consenso
			if(mdist == 0 or mdist >= R):
                w = 0
            else:
                if(cambio == 0): 										# inicio: acercar a los agentes sin chocar
                    print("collision avoidance")
                    w = (mdist - (2*(r+0.05)))/(mdist - (r+0.05))**2 	# collision avoidance
                else:
                    if(dij == 0):										# si no hay arista, se usa función plana como collision avoidance
                        print("cosh")
                        w = 0.018*math.sinh(1.8*mdist-8.4)/mdist 		
                    else:												# collision avoidance & formation control
                        print("formacion")
                        w = (4*(mdist - dij)*(mdist - r) - 2*(mdist - dij)**2)/(mdist*(mdist - r)**2)
                
            # Tensión de aristas entre agentes 
            E0 = E0 + w*dist[0]
            E1 = E1 + w*dist[1]
            
        # Actualización de velocidad
        V[0][g] = 2*(E0)*TIME_STEP/1000 
        V[1][g] = 2*(E1)*TIME_STEP/1000 
    
	# Al llegar muy cerca de la posición deseada realizar cambio de control
    normV2 = 0
    for m in range(0,N):
        nV2 = V[0][m]**2 + V[1][m]**2
        normV2 = normV2 + nV2
    normV = math.sqrt(normV2)
    print(normV)
    
    if(normV < 0.5):
        cambio = cambio + 1
     
        
    # Guardar datos necesarios para asignar velocidad a cada agente  
    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos.pickle','wb') as f:
        pickle.dump(posActuales, f)
    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos2.pickle','wb') as f:
        pickle.dump(posNuevas, f)
    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos3.pickle','wb') as f:
        pickle.dump(V, f)
    pass



