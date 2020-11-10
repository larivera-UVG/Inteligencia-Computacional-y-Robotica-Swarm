""" =========================================================================
# FUNCIONES PARA MEDIR MÉTRICAS
# =========================================================================
# Autor: Andrea Maybell Peña Echeverría
# Última modificación: 01/09/2019
# ========================================================================= """

# Librerías importadas
import numpy as np
import math


def DistEntreAgentes(X):
#DISTENTREAGENTES Genera matriz con distancias entre agentes
# Paramétros:
#   X = Matriz con vectores de posición actual de los agentes (x,y)
# Salidas:
#   mDist = Matriz de adyacencia del grafo formado por la posición actual
#           de los agentes 

    n = len(X[0])			# cantidad de agentes
    mDist = np.zeros([n,n])	# inicialización de la matriz

    for i in range(0,n):
        for j in range(0,n):
            dij1 = X[0,i] - X[0,j]
            dij2 = X[1,i] - X[1,j]
            normdij = math.sqrt(dij1**2 + dij2**2)	# distancia entre agente i y j
            mDist[i,j] = normdij					# se añade distancia en la matriz
    return mDist

def SelectForm(aF, FAct):
#SELECTFORM Selecciona la formación con menor error respecto a la formación
#           actual
# Parámetros:
#   aF = Arreglo de celdas con formaciones posibles
#   FAct = Matriz adyacente de formación actual
# Salidas:
#   f = Posición en el arreglo de celdas de la formación con el menor error

    cantF = len(aF)			# cantidad de formaciones posibles
    errores = []			# inicialización vector de errores
    for i in range(0,cantF):
        errores.append(ErrorForm(FAct,aF[i]))	# error con formación i

    f = errores.index(min(errores))
    return f


def ErrorForm(FAct, FDes):
#ERRORFORM Calcula error entre formación actual y formación deseada
# Parámetros:
#   FAct = Matriz de adyacencia de la formación actual
#   FDes = Matriz de adyacencia de la formación deseada
# Salida:
#   error = Error cuadrático medio de la formación actual comparada con la 
#           formación deseada

    s1 = len(FAct[0])
    suma = 0
    for i in range(0,s1):
        for j in range(0,s1):
            mDif = (FAct[i][j] - FDes[i][j])**2		# diferencia al cuadrado
            suma = suma + mDif						# suma de filas y columnas
    tot = s1*s1										# cantidad de agentes
    error = suma/tot								# error promedio
    return error

