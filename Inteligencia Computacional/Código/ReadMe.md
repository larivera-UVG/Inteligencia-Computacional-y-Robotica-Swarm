![version](https://img.shields.io/badge/version-v2.0-blueviolet)
![buil](https://img.shields.io/badge/build-success-brightgreen)
![Matlab](https://img.shields.io/badge/Matlab-R2017a-blue)
![Matlab](https://img.shields.io/badge/Matlab-R2018b-blue)
![Matlab](https://img.shields.io/badge/Matlab-R2020a-blue)
# Aprendizaje Automático, Computación Evolutiva e Inteligencia de Enjambre para Aplicaciones de Robótica
En este proyecto se implementa el algoritmo **Ant System** (AS) :ant: :ant: en Matlab para su posterior uso como planificador de trayectorias en robots similares a el robot E-Puck en aplicaciones de búsqueda y rescate. Además, también se tiene el código que implementa el **algoritmo genético** (GA) 🧬 con codificación binaria y entera. En esta carpeta (Código), se encuentran todos los *scripts* necesarios para ejecutar los algoritmos ACO y GA.

:warning: :warning: **Por favor leer y hacer los prerrequisitos del ReadMe de la carpeta de inteligencia computacional antes de continuar con este readMe.** :warning: :warning:

## Tabla de contenido

1. [ ACO ](#aco)
   1. [ Código principal y funciones ](#cod)
   2.  [ Archivos para barrido de parámetros ](#sweep)
   3.  [ Archivos .mat ](#mat)
   4.  [ Archivos privados ](#p)
2. [ Analytics ](#analysis)
   1. [ Analysis ](#cod)
   2. [ Sweep data ](#sweepdata)
   3. [ Tablas de LaTeX ](#tab)
3. [ GA-bin ](#bin)
4. [ GA-int ](#int)
5. [ Webots ](#webots)


<a name="aco"></a>
## 1. ACO
En esta carpeta se encuentran distintos tipos de código:
1. Código del ACO (main y funciones) con extensión .m.
2. Código para barrido de parámetros (..._sweep.m).
3. Archivos .mat con información que será utilizada en el main.
4. Funciones privadas .p que se mandan a llamar en los archivos de barrido.

<a name="cod"></a>
### 1.1 Código principal y funciones
* ACO.m

Es el archivo principal y el que debe ejecutarse.

* ant_decision.m

Función utilizada para implementar el algoritmo 17.1 Artificial Ant Decision Process del libro Computational Intelligence an Introduction.

* graph_grid.m

Esta función crea un grafo cuadrado con nodos de 1 al número que el usuario desee. Por ejemplo graph_grid(10) crea 10x10 nodos de 1 a 10 vertical y horizontalmente. Esta función también guarda en el grafo el peso de cada enlace entre nodos (tau y eta).

* loop_remover.m

Por ejemplo si tenemos los nodos: 1 2 3 8 5 6 3 4, loop_remover quita los números 8563 porque al inicio estaba en el nodo 3, luego se fue a nodos nada que ver y regresó al 3. De este modo tenemos la ruta corta 1 2 3 4.

* rouletteWheel.m

Esta función implementa la elección mediante rouletteWheel.

* mandar_mail.m

Con esta función creé los archivos p con el comando pcode(filename).

* poly_graph.mlapp

Para correrlo dar doble click en el archivo. Robot radius no funciona, pero world size sí. World size limita el tamaño del canvas. Primero se tiene que hacer click en Add Obstacle. Se dibuja el primer obstáculo. Luego si se desea agregar más obstáculos, hacer otro click en add obstacle y así hasta agregar todos los que desee. Finalmente haga click en add start point y agregue solo un punto. Después haga click en Add End Point y agregue solo un punto. Finalmente haga click en Visibility Graph para generar el grafo que se guardará en el archivo vis_graph.mat.

Para editar este archivo escribir en la consola de Matlab el siguiente comando:

~~~
>> appdesigner
~~~

Cuando abra la ventana, darle a open y buscar el archivo poly_graph.mlapp. En el design view se pueden editar los botones y gráficos en general, mientras que en code view se edita la funcionalidad de la aplicación.

* prm_generator.m

Funciona igual que graph_grid.m, pero con prm en vez de un grid.

* rrt_generator.m

Funciona igual que graph_grid.m, pero con rrt en vez de un grid.

<a name="sweep"></a>
### 1.2 Archivos para barrido de parámetros
* ACO_rho_sweep.m
* ACO_alpha_sweep.m
* ACO_beta_sweep.m
* ACO_Q_sweep.m
* ACO_ant_sweep.m
* ACO_core_sweep.m

Para correr estos archivos no es necesario nada más que las funciones utilizadas con el archivo ACO.m.

<a name="mat"></a>
### 1.3 Archivos .mat
* rrt_test_graph.mat
* prm_test_graph.mat
* vis_graph.mat
* sweep_data.mat

Los primeros 3 archivos tienen un grafo que se utilizará en el main. sweep_data.mat por el contraio, contiene datos de prueba generados con los archivos sweep. Es necesario que exista este archivo para que Matlab no de error al correrlo.

<a name="p"></a>
### 1.4 Archivos privados
Debido a que los barridos de parámetros duraban mucho tiempo (entre 3 y 24 horas), necesitaba una manera de avisarme cuando pasara algo importante con el código. Por lo tanto, se me ocurrió enviarme un correo electrónico cada vez que iniciara el código, terminara u ocurriera un error. Para esto se utilizan los archivos:
* end_mail.p
* enviar_correo.p
* error_mail.p

Si se utilizan esos archivos, se enviara un mensaje a mi correo. Por tanto, si desea cambiar la dirección de correo se pueden generar los archivos .p con el código mandar_mail.m. Para que su correo (asumiendo gmail) permita que se envíen correos desde Matlab es necesario configurar el *acceso a aplicaciones poco seguras*. Para acceder a dicha configuración en Gmail hacer click en:

![setup](https://github.com/larivera-UVG/Inteligencia-Computacional-y-Robotica-Swarm/blob/Gaby-dev/Inteligencia%20Computacional/git-images/mail-priv.gif)

<a name="analytics"></a>
## 2. Analytics
<a name="analysis"></a>
### 2.1 Analysis
Estos archivos se encargan de generar tablas, gráficas de barras, gráficas de cajas y bigotes, guardar las imágenes y exportar las tablas de LaTeX de los datos de las corridas.

<a name="sweepdata"></a>
### 2.2 Sweep data
Todos estos archivos .mat son los que guardan la información de los barridos de parámetros. Estos se utilizan en los archivos de análisis.

<a name="tab"></a>
### 2.3 Tablas de LaTeX
Para ahorrar energía (mía) y tiempo, dentro de los archivos de análisis generé las tablas en LaTeX para solo copiarlas y pegarlas en el Overleaf de la tesis. Estos archivos se generan con la función table2latex que saqué del foro de Mathworks y modifiqué un poco para que la tabla quedara como yo quería.

<a name="bin"></a>
## 3. GA-bin
En esta carpeta se encuentran todos los archivos para correr el algoritmo genético con codificación binaria. El archivo principal es basic GA. La explicación y base de este código se explica en el curso Algoritmos Evolutivos de la UNAM en Coursera. Se recomienda fuertemente hacer este curso antes de realizar el seguimiento de esta parte de la tesis. Con estos archivos se minimiza 4 funciones de costo con el algoritmo genético con codificación binaria (en el curso maximizan si no estoy mal). El problema aquí es que no se generan buenas trayectorias (lo cual tiene sentido). Por tanto, se recomendaría intentar de limitar el cambio de los bits cuando se combinan y mutan para que vaya "de forma más suave".

<a name="int"></a>
## 4. GA-int
En este caso, el código no está explicado del todo en el curso de la UNAM, sino que es parte de una tarea. Este código encuentra la solución de forma entera al problema del vendedor viajero (TSP - Traveling Salesman Problem). Lo que yo pensaba era adaptarlo para que buscara una solución al grafo sin la restricción que tiene el TSP de que pase por todos los nodos. Estos dos códigos (de algoritmos genéticos binario y entero) ya no me dio tiempo de probarlos porque se salían del alcance de mi tesis :cry:.

<a name="webots"></a>
## 5. Webots
En la carpeta de Webots se encuentran otras carpetas:
* controllers
* libraries
* plugins
* protos
* worlds

El verdadero código, y el que hay que modificar, se encuentra en la carpeta "ACO_controller". Además, el mundo que se utiliza está en la carpeta *worlds*, y se llama tesis. Las demás carpetas **no** deben de ser modificadas :warning:. El archivo del mundo se modifica únicamente en el programa de webots. El controlador puede editarse desde Webots o desde Matlab.

1. En Matlab, abrir ACO.m y correrlo en modo grid. Por el momento *no* es posible probar PRM, RRT y grafo de visibilidad con Webots.
~~~
graph_type = "grid";
~~~

2. Arrastrar el archivo *webots_test.mat* a la carpeta *ACO_controller*. Es posible modificar el archivo ACO.m para que se guarde en dicha carpeta si así usted lo desea. Este programa solo fue probado con la línea recta que genera el ACO. :warning: Si por alguna razón, la ruta generada por el ACO NO es recta, volver a correr el algoritmo hasta que salga una línea recta.

3. Abrir el mundo *tesis* en *file>open world*. Debería de verse el mundo como en la figura siguiente (sin la estrella). La estrella fue colocada en la imagen para marcar el punto a donde el robot debería de llegar.

![setup](https://github.com/larivera-UVG/Inteligencia-Computacional-y-Robotica-Swarm/blob/Gaby-dev/Inteligencia%20Computacional/git-images/Controladores/setup.png)

4. Darle al botón :arrow_forward: para correr la simulación o al botón :fast_forward: para correr la simulación más rápido.

5. Para analizar el movimiento del robot de Webots luego de que este llego a la meta, ejecutar en Matlab el código controller_analysis (en la carpeta ACO_controller). Este código automáticamente guardará las 4 imágenes .png en esta misma carpeta. Si se quisiera guardar las imágenes en otra carpeta puede modificarse en Matlab. Incluso si no desea guardar las imágenes también es posible comentar la línea donde se guardan. Principalmente las guardé automáticamente para colocarlas en la tesis y no hacerlo a mano.


(*) Si se quiere modificar la posición inicial en *ACO.m*, hay que modificar el vector pos en *ACO_controller*. En el siguiente ejemplo se muestran las coordenadas de Webots para la esquina inferior izquierda.
~~~
pos = [-0.94 0 0.94];
~~~

Para analizar los resultados se utiliza el código controller_analysis. Este desplegará y guardará las imágenes de la trayectoria y velocidades del robot.

Nota: En la carpeta hay un archivo gitignore para que git no agarre los archivos asv que Matlab crea cuando se tiene abierto un archivo. De esa manera evitamos llenar el repositorio de archivos inútiles.
***
Readme.md

Tesis: Aprendizaje Automático, Computación Evolutiva e Inteligencia de Enjambre para Aplicaciones de Robótica

Estudiante: Gabriela Iriarte

Asesor: Dr. Luis Alberto Rivera Estrada
