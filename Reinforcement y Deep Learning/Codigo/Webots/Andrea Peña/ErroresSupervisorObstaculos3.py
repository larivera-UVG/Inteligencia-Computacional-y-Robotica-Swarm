"""=========================================================================
# MEDICIÓN DE MÉTRICAS EN LA SIMULACIÓN DEL MODELO DINÁMICO CON CONTROL DE 
# FORMACIÓN, USANDO COSENO HIPERBÓLICO, Y EVASIÓN DE OBSTÁCULOS INCLUYENDO 
# LÍMITES DE VELOCIDAD
# =========================================================================
# Autor: Andrea Maybell Peña Echeverría
# Última modificación: 27/09/2019
# (Métricas MODELO 6)
# =========================================================================
# El siguiente script implementa la simulación del modelo dinámico de
# modificación a la ecuación de consenso utilizando evasión de obstáculos y
# luego una combinación de control de formación con una función de coseno 
# hiperbólico para grafos mínimamente rígidos y evasión de obstáculos.
# Además incluye cotas de velocidad para que no se sobrepasen los límites
# físicos de los agentes cierto número de veces para determinar las métricas
# de error y cálculos de energía.
# ========================================================================="""

"""ErroresSupervisorObstaculos3 controller."""

# Librerías importadas
from controller import Robot, Supervisor
import numpy as np
import random
import math
import pickle
from funVel import Fmatrix
import funciones
import xlsxwriter

# Inicialización de hoja de Excel
workbook = xlsxwriter.Workbook('ResultadosWebots1.xlsx')
worksheet1 = workbook.add_worksheet('A')
worksheet2 = workbook.add_worksheet('Sheet2')
worksheet3 = workbook.add_worksheet('Sheet3')

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

## Posiciones de los obstáculos ##
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

cantI = 10							# cantidad de simulaciones a realizar
EIndividual = np.zeros([cantI,N])	# energía individual por agente en cada simulación
ETotal = []							# energía total en cada simulación
EI = []								# error individual en cada simulación
ExitoTotalF = 0						# cantidad de formaciones 100% exitosas
Exito9F = 0							# cantidad de formaciones 90% exitosas
Exito8F = 0							# cantidad de formaciones 80% exitosas
Exito7F = 0							# cantidad de formaciones 70% exitosas
Fail = 0							# cantidad de formaciones fallidas

for I in range(0,cantI):

    # Asignar posiciones random a cada agente
    for a in range(0,N):
        sizeR0 = sizeVec[0] - 2*r
        sizeR1 = sizeVec[1] - 2*r
        X[0,a] = random.random()*sizeR0 - sizeR0/2
        X[1,a] = random.random()*sizeR1 - sizeR1/2
    
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
					# diferencia entre las posiciones
                    resta = math.sqrt((X[0,i]-posObs[j].getSFVec3f()[0])**2 + (X[1,i]-posObs[j].getSFVec3f()[2])**2)
                    if(abs(resta) < sizeO):
						# cambio de posición
                        X[0, i] = random.random()*sizeR0 - sizeR0/2
                        X[1, i] = random.random()*sizeR1 - sizeR1/2
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
    d = Fmatrix(FSel,Rig)						# matriz de formación inicial
	
	## Inicialización simulación
    ciclos = 0				# cuenta de la cantidad de ciclos 
    historico = []			# histórico de velocidades
    energiaT = 0			# energía total
	cambio = 0				# variable para el cambio de control
    
    # Main loop:
    while (supervisor.step(TIME_STEP) != -1 and ciclos < 1000):
        
        print(I)
        print("cambio",cambio)
        print("FSel",FSel)
        print("ciclos", ciclos)
    
		# Obtener posiciones actuales
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
            
            # Collision avoidance con obstáculos
            for j in range(0,cantO):
                distO0 = posActuales[0,g] - posObs[j].getSFVec3f()[0]
                distO1 = posActuales[1,g] - posObs[j].getSFVec3f()[2]  
                mdistO = math.sqrt(distO0**2 + distO1**2) - sizeO
				
                if(abs(mdistO) < 0.0001):
                    mdistO = 0.0001
                w = -1/(mdistO**2)
				
                E0 = E0 + 0.2*w*distO0
                E1 = E1 + 0.2*w*distO1
                
            # Actualización de velocidad
            V[0][g] = 1*(E0)*TIME_STEP/1000 
            V[1][g] = 1*(E1)*TIME_STEP/1000 
            
           
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
        
        
        with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos.pickle','wb') as f:
            pickle.dump(posActuales, f)
        with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos3.pickle','wb') as f:
            pickle.dump(V, f)
            
        ciclos = ciclos + 1
        
        pass
        
    V = np.zeros([2,N])
    with open('C:/Users/Andrea Maybell/Documents/AMPE/2019/Robotat/WeBots/PruebasBasicas1/controllers/Datos3.pickle','wb') as f:
            pickle.dump(V, f)
    
    # CÁLCULO DEL ERROR FINAL
    mDistF = 5*funciones.DistEntreAgentes(posActuales)
    errorF = funciones.ErrorForm(mDistF, Fmatrix(FSel, 8))		# error de formación simulación I
    
    for z in range(0, len(historico)):
        energiaT =  energiaT + historico[z]*(TIME_STEP/1000)	# energía total simulación I
        
    ETotal.append(energiaT)
    EI.append(errorF)
        
    ## Porcentaje exito formacion
	# Una formación se considera exitosa con un error cuadrático medio menor a 0.05
    if(errorF > 0.05):
		# Si la formación no fue exitosa se evalua el éxito individual de 
        # de cada agente. Un agente llegó a la posición deseada si tiene un
        # porcentaje de error menor al 15%.
        errorR, cantAS = funciones.ErrorIndividual(mDistF, Fmatrix(FSel,8), 15)
    else:
		# El que la formación haya sido exitosa implica que todos los
        # agentes llegaron a la posición deseada
        errorR = errorF		# error de formación relativo
        cantAS = N			# cantidad de agentes que llegan a la posición deseada
    
	## Porcentaje de agentes en posición deseada
    # Si el error de formación sin tomar en cuenta a los agentes que se
    # alejaron considerablemente, es menor a 0.05 implica que hubo un
    # porcentaje de la formación que sí se logró.
    if(errorR < 0.05):
        if(cantAS == N):					# formación 100% exitosa
            ExitoTotalF = ExitoTotalF + 1
        elif(cantAS == N-1):				# formación 90% exitosa
            Exito9F = Exito9F + 1
        elif(cantAS == N-2):				# formación 80% exitosa
            Exito8F = Exito8F + 1
        elif(cantAS == N-3):				# formacion 70% exitosa
            Exito7F = Exito7F + 1
        else:
            Fail = Fail + 1					# formación fallida
    else:
        Fail = Fail + 1
    
    VResults = [ExitoTotalF, Exito9F, Exito8F, Exito7F, Fail]
    
# Se escriben los resultados en Excel
worksheet1.write_row('K3', EI)
worksheet2.write_row('D3', VResults)
worksheet3.write_row('K3', ETotal)
workbook.close()




