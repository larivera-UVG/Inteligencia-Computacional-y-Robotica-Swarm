![version](https://img.shields.io/badge/version-v1.2-blueviolet)
![buil](https://img.shields.io/badge/build-success-brightgreen)
![Matlab](https://img.shields.io/badge/Matlab-R2017a-blue)
![license](https://img.shields.io/badge/license-no%20se%20Luis%20cu%C3%A1l%20ponemos%3F-green)
![issues](https://img.shields.io/badge/issues-1%20open-orange)
# Aprendizaje Automático, Computación Evolutiva e Inteligencia de Enjambre para Aplicaciones de Robótica
En este proyecto se implementa el algoritmo **Ant Colony System** (AS) :ant: :ant: en Matlab para su posterior uso en robots similares a el robot E-Puck en aplicaciones de búsqueda.

## Tabla de contenido

1. [ Prerrequisitos ](#desc)
2. [ Algoritmo ](#alg)
3. [ Código ](#usage)
   1. [ ACO.m ](#aco)
   2.  [ nodes.m ](#nodes)
   3. [ nodeid.m ](#id)
   4.  [ neighbors.m ](#nei)
   5. [ tabu.m ](#tabu)
   6.  [ ant_decision.m ](#dec)
   7. [ rouletteWheel.m ](#rou)
   8. [ loop_remover.m ](#loop)
   9.  [ ACO_params_ev.m ](#aco2)


<a name="desc"></a>
## 1. Prerrequisitos

Para correr los programas de esta sección del repositorio es necesario tener instalada alguna versión de Matlab. Para hacer esta versión del código se utilizó Matlab R2017a, pero podría utilizar una diferente.

<a name="alg"></a>
## 2. Algoritmo

Primero se implementó el algoritmo Simple Ant Colony (SACO) con movimiento sin diagonales, pero el algoritmo final fue el Ant System de Marco Dorigo por tener más flexibilidad de parámetros. Este último algoritmo lo codifiqué en el mismo archivo de ACO.m, por lo que se sobreescribió el AS por el ACO y le agregué el movimiento diagonal. El algoritmo fue codificado según el pseudocódigo brindado por Andries P. Engelbrecht en su libro :blue_book: _Computational Intelligence An Introduction_, segunda edición, página 371 (algoritmo 17.3).

![alg](/git-images/alg17.3.PNG)

Básicamente el algoritmo consta de 3 distintas partes que se repiten :repeat: hasta que se haya encontrado una solución o se haya llegado a un máximo de iteraciones (t):
- **Construcción de camino por hormiga**

En esta etapa, **por cada hormiga** :ant:, hasta que el nodo destino se haya encontrado, se **selecciona el siguiente nodo** utilizando la ecuación de probabilidad definida para el algoritmo proporcional a la cantidad de feromona del link que relaciona a dichos nodos.
- **Evaporación de feromona**

Cada enlace entre los nodos tiene asociado un nivel de feromona que "con el tiempo se va evaporando". Esto se simula en esta etapa con una ecuación dada en el mismo libro :blue_book: del algoritmo.
- **Actualización de feromona**

Se deposita feromona en cada link entre cada nodo del path construido por cada hormiga, inversamente proporcional a la distancia de ese camino. De este modo, caminos grandes tendrán poca feromona y por ende, menos probabilidad de ser escogidos.

<a name="usage"></a>
## 3. Código
<a name="aco"></a>
### 3.1 ACO.m
El archivo main de la carpeta es ACO.m. Si se desea correr el resultado de una simulación de Ant System debe de tener todos los archivos mencionados en este documento en la misma carpeta o agregados al path :open_file_folder:. Luego de esto, presione el botón de Run :arrow_forward: en Matlab y la simulación debería de correr sin problemas.

<a name="nodes"></a>
### 3.2 nodes.m
Utilizado en la línea 15 de ACO.m. Su trabajo es generar los nodos a partir de un tamaño de espacio de trabajo. Para esta versión se utilizó una cuadrícula de 10x10 unidades. La función devuelve todos los puntos de la cuadrícula en forma de vectores fila:

x | y
-- | --
1 | 1
2 | 1
... | ...
9 | 10
10 | 10

<a name="id"></a>
### 3.3 nodeid.m
Utilizando en las líneas 82,124,132,146 y 171 de ACO.m. Esta función acepta como parámetros un nodo y la lista de todos los nodos (generada por nodes.m). Utilizando la función `ismember` de Matlab se regresa el índice del nodo con respecto a la lista de todos los nodos.

<a name="nei"></a>
### 3.4 neighbors.m
Utilizando en la línea 40 y 63 de ACO.m. Esta función acepta como parámetros: un nodo y los límites en x y y del grid. Devuelve a todos los vecinos del nodo (norte, sur, este, oeste y las diagonales) en el mismo formato de vector fila como lo devuelve nodes.m.

<a name="tabu"></a>
### 3.5 tabu.m
Utilizando en la línea 128 de ACO.m. Esta función devuelve la lista de vecinos a los que sí se puede viajar, la lista de nodos bloqueados (ya visitados) y una bandera binaria. Lo que se busca es no repetir nodos para no regresar y dar vueltas donde no es necesario.

<a name="dec"></a>
### 3.6 ant_decision.m
Utilizado en la línea 125 de ACO.m. Toma la decisión de a qué nodo debe de dirigirse la hormiga según la ecuación de probabilidad descrita en la imagen de abajo. La probabilidad se elige utilizando el algoritmo **Roulette Wheel** :ferris_wheel:, que se describe en la siguiente sección.

![prob](/git-images/probabilidad_AS.PNG)

<a name="rou"></a>
### 3.7 rouletteWheel.m
Utilizado en la línea 35 de ant_decision.m. Algoritmo utilizado en computación evolutiva para seleccionar de forma aleatoria un valor. El pseudocódigo fue extraído del libro :blue_book: antes mencionado (_Computational Intelligence An Introduction_).

![rou](/git-images/roullete.PNG)

<a name="loop"></a>
### 3.8 loop_remover.m
Utilizado en la línea 139 de ACO.m. En algunas ocasiones el algoritmo se encuentra con topes como el de la siguiente figura:

![fail](/git-images/fallo.PNG)

Por lo tanto, el algoritmo necesita regresar en el path que recorrió para salir del callejón. Esta función lo que hace es quitar los nodos a los que recorrió y que no le llevaron a ningún lugar útil, por lo que se hace más corto el camino. Este comportamiento está mejor explicado en el libro :orange_book: _Ant Colony Optimization_ de Marco Dorigo y Thomas Stützle.

<a name="aco2"></a>
### 3.9 ACO_params_ev.m
:no_entry: :construction: En construcción :construction: :no_entry:

Este código es básicamente ACO pero modificado para no tener simulación y correr el barrido de los parámetros rho, alpha y beta.

## License
