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
2. [ Analytics ](#analytics)
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


<a name="sweep"></a>
### 1.2 Archivos para barrido de parámetros

<a name="mat"></a>
### 1.3 Archivos .mat

<a name="p"></a>
### 1.4 Archivos privados
Debido a que los barridos de parámetros duraban mucho tiempo (entre 3 y 24 horas), necesitaba una manera de avisarme cuando pasara algo importante con el código. Por lo tanto, se me ocurrió enviarme un correo electrónico cada vez que iniciara el código, terminara u ocurriera un error. Para esto se utilizan los archivos:
* end_mail.p
* enviar_correo.p
* error_mail.p

Si se utilizan esos archivos, se enviara un mensaje a mi correo. Por tanto, si desea cambiar la dirección de correo se pueden generar los archivos .p con el código mandar_mail.m. Para que su correo (asumiendo gmail) permita que se envíen correos desde Matlab es necesario configurar el *acceso a aplicaciones poco seguras*. Para acceder a dicha configuración en Gmail hacer click en:

**la imagen de su foto de perfil>configuraciones>seguridad>Acceso a aplicaciones poco seguras>Permitir**



<a name="analytics"></a>
## 2. Analytics


<a name="bin"></a>
## 3. GA-bin

<a name="int"></a>
## 4. GA-int

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


***
Readme.md

Tesis: Aprendizaje Automático, Computación Evolutiva e Inteligencia de Enjambre para Aplicaciones de Robótica

Estudiante: Gabriela Iriarte

Asesor: Dr. Luis Alberto Rivera Estrada
