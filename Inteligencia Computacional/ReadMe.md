![version](https://img.shields.io/badge/version-v2.0-blueviolet)
![buil](https://img.shields.io/badge/build-success-brightgreen)
![Matlab](https://img.shields.io/badge/Matlab-R2017a-blue)
![Matlab](https://img.shields.io/badge/Matlab-R2018b-blue)
![Matlab](https://img.shields.io/badge/Matlab-R2020a-blue)
![Matlab](https://img.shields.io/badge/Webots-R2020aRev.1-red)
# Aprendizaje Automático, Computación Evolutiva e Inteligencia de Enjambre para Aplicaciones de Robótica
En este proyecto se implementa el algoritmo **Ant System** (AS) :ant: :ant: en Matlab para su posterior uso como planificador de trayectorias en robots similares a el robot E-Puck en aplicaciones de búsqueda y rescate. Además, también se tiene el código que implementa el **algoritmo genético** (GA) 🧬 con codificación binaria y entera.

Ok... si les da :egg: ...pereza leer pueden ver los videos:

[![prerrequisitos vid](https://img.youtube.com/vi/34Gk2Xek0RY/0.jpg)](https://youtu.be/34Gk2Xek0RY)

[![codigo vid](https://img.youtube.com/vi/tO1s2DIvKbU/0.jpg)](https://youtu.be/tO1s2DIvKbU)

...pero sí les recomendaría leer esto antes y luego seguir el tutorial para que tengan idea de qué está pasando.

## Tabla de contenido

1. [ Prerrequisitos ](#desc)
   1. [ Conexión Webots+Matlab ](#webmat)
   2.  [ Toolboxes adicionales ](#tool)
2. [ Generalidades del algoritmo ](#alg)
3. [ Uso del código ](#usage)
   1. [ Código ](#cod)
   2.  [ Documentos ](#docs)
   3. [ git-images ](#images)

<a name="desc"></a>
## 1. Prerrequisitos

![matlogo](https://github.com/larivera-UVG/Inteligencia-Computacional-y-Robotica-Swarm/blob/Gaby-dev/Inteligencia%20Computacional/git-images/Readme/Matlab-logo.png) ![welogo](https://github.com/larivera-UVG/Inteligencia-Computacional-y-Robotica-Swarm/blob/Gaby-dev/Inteligencia%20Computacional/git-images/Readme/webots-logo.png)

Para correr los programas de esta sección del repositorio es necesario tener instalada alguna versión de Matlab. Para elaborar el código en este repositorio se utilizó Matlab 2017 y 2018, sin embargo, parte del código también fue probado en la versión 2020. Además de Matlab, también se cuenta con código para Webots 2020 rev1, por lo que será necesario instalarlo.

<a name="webmat"></a>
### 1.1 Conexión Webots+Matlab
En la carpeta **Conexión Webots-Matlab** están todos los archivos necesarios y una guía extra para realizar la conexión. Es posible que no funciona, pues algunos de mis compañeros no pudieron hacer la conexión. La guía de conexión fue originalmente proporcionada por MSc. Miguel Zea en Robótica 2, ciclo 2 2020.
1. Colocar los archivos launcher.m y allincludes.h dentro de la carpeta :open_file_folder: *C:\Users\\<usuario>\AppData\Local\Programs\Webots\lib\controller\matlab* (Solo un / después de Users, no sé por qué aquí lo duplica). Esta carpeta debería de existir si se instaló Webots de manera estándar.
2. Abrir el archivo mingw.mpkginstall dentro de Matlab. Es decir, desde Matlab dirigirse a la carpeta donde está guardado el archivo y darle doble click o escribir su nombre en la consola.
3. Verificar que este archivo quedó bien instalado siguiendo la guía en el siguiente enlace: :link: https://la.mathworks.com/help/matlab/matlab_external/install-mingw-support-package.html
4. Verificar que Webots sí pueda comunicarse con MATLAB al abrir  y correr un ejemplo como el de *languages>matlab>e-puck_matlab.wbt* en *Open Sample World...*

<a name="tool"></a>
### 1.2 Toolboxes adicionales
1. **Instalación**: Aparte de lo mencionado anteriormente, también necesitamos descargar e instalar el Toolbox de robótica de Peter Corke. Dicho Toolbox puede ser descargado de: :link: https://petercorke.com/toolboxes/robotics-toolbox/ La instalación es la misma que para el archivo mingw.mpkginstall.
2. **Modificación**: Con las funciones de prm y rrt del toolbox de Peter Corke se utilizan funciones que él nombró igual que las *built in* de Matlab. Por tanto, es necesario mover algunas funciones hasta arriba en *HOME>Set Path*. Es decir, cuando ya se está en set path, esas funciones deben de ser arrastradas hasta arriba para que Matlab las encuentre antes que las *built in* de Matlab.

El problema de estas funciones se llama *shadowing*. Una de las funciones problemáticas es *angdiff*, por lo que se puede correr el comando:
```
which angdiff
```

para que salga en qué rutas se encuentra esa función. La que NO nos interesa que esté arriba es la siguiente, pues hay que usar la de Peter Corke:

```
>> C:\Program Files\MATLAB\R2018b\toolbox\robotics\robotcore\angdiff.m
```

<a name="alg"></a>
## 2. Generalidades del algoritmo

Primero se implementó el algoritmo Simple Ant Colony (SACO) con movimiento sin diagonales, pero el algoritmo final fue el Ant System de Marco Dorigo por tener más flexibilidad de parámetros. Este último algoritmo fue codificado en el mismo archivo de ACO.m, por lo que se sobreescribió el AS por el ACO y le agregué el movimiento diagonal. El algoritmo fue codificado según el pseudocódigo brindado por Andries P. Engelbrecht en su libro :blue_book: _Computational Intelligence An Introduction_, segunda edición, página 371 (algoritmo 17.3).

![alg](https://github.com/larivera-UVG/Inteligencia-Computacional-y-Robotica-Swarm/blob/Gaby-dev/Inteligencia%20Computacional/git-images/Marcoteorico/alg17.3.PNG)

Básicamente el algoritmo consta de 3 distintas partes que se repiten :repeat: hasta que se haya encontrado una solución o se haya llegado a un máximo de iteraciones (t):
- **Construcción de camino por hormiga**

En esta etapa, **por cada hormiga** :ant:, hasta que el nodo destino se haya encontrado, se **selecciona el siguiente nodo** utilizando la ecuación de probabilidad definida para el algoritmo proporcional a la cantidad de feromona del link que relaciona a dichos nodos.
- **Evaporación de feromona**

Cada enlace entre los nodos tiene asociado un nivel de feromona que "con el tiempo se va evaporando". Esto se simula en esta etapa con una ecuación dada en el mismo libro :blue_book: del algoritmo.
- **Actualización de feromona**

Se deposita feromona en cada link entre cada nodo del path construido por cada hormiga, inversamente proporcional a la distancia de ese camino. De este modo, caminos grandes tendrán poca feromona y por ende, menos probabilidad de ser escogidos.

<a name="usage"></a>
## 3. Uso del código
A continuación se presenta el resumen de lo que contienen las carpetas del repositorio. En la carpeta de Código se encuentra otro archivo ReadMe.md que explica más a detalle los scripts.
<a name="cod"></a>
### 3.1 Código
En esta carpeta se encuentran las carpetas siguientes:
* ACO
* Analytics
* GA-bin
* GA-int
* Webots

Donde se guarda el código actualizado de cada algoritmo (ACO/GA-bin/GA-int/Webots). En el caso de Analytics, se encuentra el código para analizar las ejecuciones del barrido de parámetros de ACO.

<a name="docs"></a>
### 3.2 Documentos
En esta carpeta se encuentra el cronograma, protocolo y tesis. También se encuentra un backup del LaTeX de la tesis por si algo malo pasaba con :leaves: Overleaf :leaves:.

<a name="images"></a>
### 3.3 git-images
Como el nombre lo dice, aquí se encuentran todas las imágenes que utilicé en la tesis y en los archivos ReadMe.

* **Controlador ACO v1**: ACO en Webots sin modificaciones (interpolación ni filtro)
* **Controlador ACO v2**: ACO en Webots con modificaciones
* **Controladores**: Controladores en Webots sin ACO
* **GA**: Algoritmo genético en Matlab para minimizar funciones de costo
* **Grid**: ACO en Matlab con grafo tipo cuadrícula
* **Marco teórico** (*): Imágenes tomadas de otros sitios o en general relevantes en el marco teórico de la tesis
* **PRM**: ACO en Matlab con grafo tipo PRM
* **RRT controller v1** (**): Intento fallido de ACO con RRT e interpolación
* **RRT**: ACO en Matlab con grafo tipo RRT
* **Readme**: Imágenes utilizadas solo en los archivos ReadMe de GitHub.
* **Visibility**: ACO con grafo de visibilidad

(*) Perdón que no tiene tilde porque no me deja meter imágenes :disappointed:

(**) No se puede interpolar cuando la trayectoria no sea una función. Esto sobre complicaba la tesis, sacándolo del alcance. Por tanto, no se continuó con ese trabajo.

***
Readme.md

Tesis: Aprendizaje Automático, Computación Evolutiva e Inteligencia de Enjambre para Aplicaciones de Robótica

Estudiante: Gabriela Iriarte

Asesor: Dr. Luis Alberto Rivera Estrada
