""" =========================================================================
# SIMULACIÓN MODELO DINÁMICO CON CONTROL DE FORMACIÓN, USANDO COSENO
# HIPERBÓLICO, Y EVASIÓN DE COLISIONES CON EVASIÓN DE OBSTÁCULOS,
# INCLUYENDO LÍMITES DE VELOCIDAD Y CAMBIO DE FORMACIÓN
# =========================================================================
# Autor: Andrea Maybell Peña Echeverría
# Última modificación: 01/04/2019
# (MODELO 6 con obstáculos)
# =========================================================================
# El siguiente script implementa la simulación del modelo dinámico de
# modificación a la ecuación de consenso utilizando evasión de obstáculos y
# luego una combinación de control de formación con una función de coseno 
# hiperbólico para grafos mínimamente rígidos y evasión de colisiones.
# Ahora, con evasión de obstáculos y cambio de formación.
# Es un controlador del tipo supervisor. 
# ========================================================================= """

"""SupervisorObstaculos3 controller."""

# Librerías importadas
from controller import Robot, Supervisor
import numpy as np
import random
import math
import pickle
from funVel import Fmatrix
import funciones


TIME_STEP = 64

# Supervisor instance
supervisor = Supervisor()
supervisor.step(TIME_STEP)

""" ARENA """
arena = supervisor.getFromDef("Arena")
size = arena.getField("floorSize")
sizeVec = size.getSFVec2f()								# vector con el tamaño de la arena

""" OBSTACULOS """
cantO = 3												# cantidad de obstáculos
obs1 = supervisor.getFromDef("Obs1")
obs2 = supervisor.getFromDef("Obs2")
obs3 = supervisor.getFromDef("Obs3")
Obstaculos = [obs1, obs2, obs3]
sizeO = 2.5*obs1.getField("majorRadius").getSFFloat()	# tamaño del obstáculo

## Posiciones de los agentes ##
posO1 = obs1.getField("translation")
posO2 = obs2.getField("translation")
posO3 = obs3.getField("translation")
posObs = [posO1, posO2, posO3]

""" Objetivo """
objetivo = supervisor.getFromDef("OBJ")
pObj = objetivo.getField("translation")
pObjVec = pObj.getSFVec3f()

""" AGENTES """
N = 10									# cantidad de agentes
r = 0.1								 	# radio a considerar para evitar colisiones
R = 2									# rango del radar
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
    sizeR0 = sizeVec[0] - 2*r
    sizeR1 = sizeVec[1] - 2*r
    X[0,a] = random.random()*sizeR0 - sizeR0/2
    X[1,a] = random.random()*sizeR1 - sizeR1/2
# print("X",X)

# Revisión de las posiciones    
cW1 = 2					# contador de agentes sobre agentes
cW2 = 2					# contador de agentes sobre obstáculos
while(cW1 > 1 or cW2 > 1):
    cW1 = 0
    cW2 = 0
    # Asegurar que los agentes no empiecen uno sobre otro
    contR = 1			# contador de intersecciones
    while(contR > 0):
        contR = 0
        for i in range(1, N):
            for j in range(1, N-i):
				# diferencia entre las posiciones
                resta = math.sqrt((X[0,i]-X[0,i+j])**2+(X[1,i]-X[1,i+j])**2)	
                if(abs(resta) < r):
					# cambio de posición
                    X[0, i+j] = random.random()*sizeR0 - sizeR0/2
                    X[1, i+j] = random.random()*sizeR1 - sizeR1/2
                    contR = contR+1				# hay intersección
        cW1 = cW1+1
    
    # Asegurar que los agentes no empiecen sobre los obstáculos
    contRO = 1			# contador de intersecciones con obstáculos
    while(contRO > 0):
        contRO = 0
        for i in range(1,N):
            for j in range(1,cantO):
				# distancia agente obstáculo
                resta = math.sqrt((X[0,i]-posObs[j].getSFVec3f()[0])**2 + (X[1,i]-posObs[j].getSFVec3f()[2])**2)	
                if(abs(resta) < sizeO):
					# cambio de posición
                    X[0,i] = X[0,i] + sizeO + r
                    X[1,i] = X[1,i] + sizeO + r
                    contRO = contRO + 1			# hay intersección
        cW2 = cW2 + 1        

Xi = X
  
# Asignar posiciones revisadas  
for b in range(0, N):
    PosTodos[b].setSFVec3f([X[0,b], -6.39203e-05, X[1,b]])


# Posiciones actuales
posActuales = np.zeros([2,N])
posNuevas = np.zeros([2,N])
posAnteriores = np.zeros([2,N])

# Matriz de velocidades
V = np.empty([2,N])

## Definición e inicialización de las formaciones posibles
Formaciones = [Fmatrix(1,8), Fmatrix(2,8)]	# celda con posiciones posibles
FSel = 1									# formación inicial
Rig = 1										# rigidez de la formación
iniciarCont = False							# bandera de conteo cambio
contF = 0									# conteo de ciclos para el cambio
cicloCambio = []							# celda para ciclo de cambio
cantCambios = 0								# conteo de cambios de formación
puntosCambio = []							# celda de puntos de cambio
cantPuntos = 0								# cantidad de puntos de cambio
d = Fmatrix(FSel,Rig)						# matriz de formación inicial

## Inicialización simulación
errorDist = 0.2			# distancia del líder a la meta
ciclos = 0				# cuenta de la cantidad de ciclos 
hX = []					# histórico posiciones en X
hY = []					# histórico posiciones en Y
historico = []			# histórico de velocidades
Error1 = []				# registro de error formación 1
Error2 = []				# registro de error formación 2
cambio = 0				# variable para el cambio de control

# Main loop:
while (supervisor.step(TIME_STEP) != -1 and errorDist > 0.1 and ciclos < 3000):
    print("cambio",cambio)
    print("FSel",FSel)
    print("ciclos", ciclos)

	# Obtener posiciones actuales
    for c in range(0,N):
        posC = Agentes[c].getField("translation")
        posActuales[0][c] = posC.getSFVec3f()[0]
        posActuales[1][c] = posC.getSFVec3f()[2]        

    if(cambio != 2):
        hX = np.insert(hX, 0, posActuales[0], axis = 0)
        hY = np.insert(hY, 0, posActuales[1], axis = 0)
    
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
                    # collision avoidance
					w = (mdist - (2*(r+0.05)))/(mdist - (r+0.05))**2 
                elif(cambio == 1 or cambio == 2):
                    if(dij == 0):										# si no hay arista, se usa función plana como collision avoidance
                        # w = 0.018*math.sinh(1.8*mdist-8.4)/mdist 		# modelo usado en Matlab
                        w = 0.15*math.sinh(15*mdist-6)/mdist 
                    else:
						# collision avoidance & formation control
                        w = (4*(mdist - dij)*(mdist - r) - 2*(mdist - dij)**2)/(mdist*(mdist - r)**2)
                else:													# ha llegado a la meta
                    w = 0
                    cambio = 1
            
			# Tensión de aristas entre agentes
            E0 = E0 + 2*w*dist[0]
            E1 = E1 + 2*w*dist[1]
        
        ## Collision avoidance con obstáculos
        for j in range(0,cantO):
            distO0 = posActuales[0,g] - posObs[j].getSFVec3f()[0]
            distO1 = posActuales[1,g] - posObs[j].getSFVec3f()[2]  
            mdistO = math.sqrt(distO0**2 + distO1**2) - sizeO

            if(abs(mdistO) < 0.0001):
                mdistO = 0.0001
            w = -1/(mdistO**2)

            E0 = E0 + 0.1*w*distO0
            E1 = E1 + 0.1*w*distO1
            
        # Actualización de velocidad
        V[0][g] = 1*(E0)*TIME_STEP/1000 
        V[1][g] = 1*(E1)*TIME_STEP/1000 

        # Movimiento del líder
        if(cambio == 2):
            errorDist = 0
            V[0][0] = V[0][0] + 0.2*(posActuales[0][0]-pObjVec[0])
            V[1][0] = V[1][0] + 0.2*(posActuales[1][0]-pObjVec[2])
            errorDist = math.sqrt((posActuales[0][0]-pObjVec[0])**2 + (posActuales[1][0]-pObjVec[2])**2)
           
   
    normV2 = 0
    for m in range(0,N):
        nV2 = V[0][m]**2 + V[1][m]**2
        normV2 = normV2 + nV2
    normV = math.sqrt(normV2)
    
	# Al llegar muy cerca de la posición deseada realizar cambio de control
    if(normV < 0.3 and cambio == 0):
        cambio = cambio + 1
    elif(normV < 0.15 and cambio == 1):
        cambio = cambio + 1
	
	# Almacenamiento de variables para graficar
    for z in range(0,N):  
        historico.append(math.sqrt(V[0][z]**2 + V[1][z]**2))
    
	## Selección de formación según el error 
    mDist = 5*funciones.DistEntreAgentes(posActuales)			# distancia actual entre agentes
    Error1.append(funciones.ErrorForm(mDist, Fmatrix(1,8)))		# error con formación 1
    Error2.append(funciones.ErrorForm(mDist, Fmatrix(2,8)))		# error con formación 2
    FSel_old = FSel												# registro de formación anterior
    FSel = funciones.SelectForm(Formaciones, mDist)				# selección de formación
    
    if(cambio == 2):
	# cuando la mejor formación ya no es la misma que la actual
        if(FSel != FSel_old):
            cantPuntos = cantPuntos + 1			# contador de puntos de cambio
            puntosCambio.append(ciclos)			# almacenamiento puntos de cambio
            iniciarCont = True					# iniciar conteo de ciclos
            contF = 0							# contador de ciclos
        
		# Conteo de ciclos
        if(iniciarCont):
            contF = contF + 1
            
		# Hasta que el conteo supere cierta cantidad de ciclos cambiar de formación
        if(contF > 500):
            if(iniciarCont == True):
                cantCambios = cantCambios + 1
                cicloCambio.append(ciclos*(TIME_STEP/1000))
            d = Fmatrix(FSel,Rig)				# cambio de matriz de formación
            iniciarCont = False					# reiniciar conteo de ciclos
        

    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos.pickle','wb') as f:
        pickle.dump(posActuales, f)
    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos3.pickle','wb') as f:
        pickle.dump(V, f)
        
    ciclos = ciclos + 1
    
    pass
    
if(errorDist < 0.1 or ciclos >= 3000):
    V = np.zeros([2,N])
with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos3.pickle','wb') as f:
        pickle.dump(V, f)

## Almacenamiento de datos para graficar       
with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/ResultadosPickle/hX1.pickle','wb') as f:
    pickle.dump(hX, f)
with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/ResultadosPickle/hY1.pickle','wb') as f:
    pickle.dump(hY, f) 
with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/ResultadosPickle/historico1.pickle','wb') as f:
    pickle.dump(historico, f)
with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/ResultadosPickle/Error1.pickle','wb') as f:
    pickle.dump(Error1, f)
with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/ResultadosPickle/Error2.pickle','wb') as f:
    pickle.dump(Error2, f)
with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/ResultadosPickle/cicloCambio1.pickle','wb') as f:
    pickle.dump(cicloCambio, f)
