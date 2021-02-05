![version](https://img.shields.io/badge/version-v2.0-blueviolet)
![build](https://img.shields.io/badge/build-success-brightgreen)
![Matlab](https://img.shields.io/badge/Matlab-R2018b-blue)
![Matlab](https://img.shields.io/badge/Matlab-R2020a-blue)

# Reinforcement y Deep Learning en Aplicaciones de Robótica de Enjambre

<p align="center">
   <img src="./Media/Animación_PlanificadorTrayectorias.gif" width="49%" />
   <img src="./Media/Animación_PSOTuner.gif" width="49%" /> 
</p>

## Índice

1. [Estructura de Carpetas](#estructura-de-carpetas)
2. [Antecedentes](#antecedentes)
   - [Aldo Aguilar (2019)](#aldo-aguilar-2019)
   - [Juan Pablo Cahueque (2019)](#juan-pablo-cahueque-2019)
   - [Eduardo Santizo (2020)](#eduardo-santizo-2020)
3. [Guía de Uso](#guía-de-uso)
4. [Hardware y Software](#hardware-y-software)
5. [Swarm Robotics Toolbox](#swarm-robotics-toolbox)
6. [Pruebas PSO Tuner](#pruebas-pso-tuner)

## Video Explicativo

¿No quieres leer la tesis o la documentación? Este video ""corto"" explica las ideas principales de la tesis. Aquí se explica el planificador de trayectorias y el PSO Tuner. Desgraciadamente, no había suficiente tiempo para el SR Toolbox (ese lo tendrás que entender leyendo la documentación).

[![](http://img.youtube.com/vi/uOVFa47GldQ/0.jpg)](http://www.youtube.com/watch?v=uOVFa47GldQ "Tesis Video")

## Estructura de Carpetas

Estructura general de las carpetas existentes en el repositorio.

```json
Reinforcement y Deep Learning
│
└─── Código
│   │
│   └─── Matlab
|   |   |
│   |   └─── Aldo Aguilar:
|   |   |    Pruebas parámetros PSO
|   |   |
│   |   └─── Juan Cahueque:
|   |   |    Pruebas APF
|   |   |
│   |   └─── Eduardo Santizo:
|   |        PSO Toolbox y PSO Tuner
|   |
│   └─── Webots
|       |
│       └─── Aldo Aguilar:
|       |    Simulación controladores E-Pucks y scripts de análisis de resultados.
|       |
│       └─── Juan Cahueque:
|            Simulación caso A, B y C.
|
|
└─── Literatura
│   │
│   └─── Lectures:
|   |    Clases, presentaciones o lecciones
|   |
│   └─── Libros
|   |
│   └─── Papers
│   |   │
│   |   └─── Artificial Potential Fields
|   |   |
│   |   └─── Interpolaciones
|   |   |
│   |   └─── Machine Learning
|   |   |
│   |   └─── Robótica
|   |   |
│   |   └─── Swarm Intelligence
|   |
|   |
│   └─── Tesis Previas:
|   |    PDFs de trabajos de graduación y protocolos previos.
|   |
│   └─── Referencias Bibtex:
|        Archivo .bib con las referencias a toda la literatura.
|
|
└─── Notas:
|    Imágenes y documentos varios con notas sobre el proyecto.
|
|
└─── Reporte:
|    Documentos asociados con la redacción del reporte final de tesis y el protocolo.
|
|
└─── Media:
     Imágenes y GIFs utilizados en el Readme.
```

## Antecedentes

### Aldo Aguilar (2019)

<p align="center">
   <img src="./Media/Aldo.gif" width="40%" />
</p>

Tomó como base el algoritmo PSO y lo utilizó como un método de planificación de movimiento para robots diferenciales. Realizó  pruebas con 8 controladores diferentes y encontró que aquellos con mejor rendimiento eran el LQR y LQI. La única desventaja que notó era que los robots describían trayectorias muy rectas, lo cual evitaba que los robots esquivaran obstáculos.

### Juan Pablo Cahueque (2019)

<p align="center">
   <img src="./Media/JuanPablo.gif" width="40%"/>
</p>

Tomó los avances de Aldo y los utilizó en conjunto con "*Artificial Potential Fields*" para permitir que los robots esquivaran obstáculos presentes en el camino hacia la meta. En este caso, el controlador LQR resultó efectivo para esquivar obstáculos grandes, mientras que el PID con un filtro de "*Hard-Stops*" resultó efectivo para esquivar obstáculos pequeños y numerosos.

### Eduardo Santizo (2020)

<p align="center">
   <img src="./Media/Animación_PlanificadorTrayectorias.gif" width="49%" />
   <img src="./Media/Animación_PSOTuner.gif" width="49%" /> 
</p>

Las dos investigaciones previas fueron exitosas, pero requerían de la selección manual de los parámetros <img src="https://latex.codecogs.com/gif.latex?\inline&space;\phi_1"/>, <img src="https://latex.codecogs.com/gif.latex?\inline&space;\phi_2"/> y <img src="https://latex.codecogs.com/gif.latex?\inline&space;\omega"/> propios del algoritmo PSO. Para automatizar su selección se diseñó una red neuronal recurrente (RNN) capaz de tomar diferentes métricas del PSO y en base a estas generar valores para los parámetros del algoritmo. A la red neuronal se le denominó  *PSO Tuner* y permitió mejorar la velocidad y precisión del algoritmo estándar PSO significativamente (figura de la derecha).

Además, también se propuso una alternativa al método de esquivado de obstáculos de Juan Pablo, el cual emplea aprendizaje reforzado para generar trayectorias alrededor de una variedad de escenarios (figura de la izquierda).

## Guía de Uso

Como se mencionó [previamente](#eduardo-santizo-(2020)), se desarrollaron dos proyectos como parte de la tesis: El *PSO Tuner* y el planificador de trayectorias basado en Reinforcement Learning. Estos pueden probarse abriendo los livescripts `Pruebas_PSOTuner.mlx` y `SR_Toolbox.mlx` presentes en el path `.../Código/Matlab/Eduardo Santizo`.

Los pasos para la ejecución de ambos scripts son los siguientes:

- Bajar a la primera sección: "*Setup: Path*".

<p align="center">
   <img src="./Media/SetupPath.gif" width="70%" />
</p>

- De ser necesario, cambiar la raíz del path donde se encuentra actualmente el repositorio.

<p align="center">
   <img src="./Media/RaizPath.png" width="70%" />
</p>

- Hacer click en la sección y presionar el botón `Run Section` de Matlab. Esto cambiará automáticamente el directorio actual de Matlab, incluirá todas las subcarpetas necesarias para la operación de los scripts y comprobará que el archivo `functionSignatures.json` no contenga errores.

<p align="center">
   <img src="./Media/RunSection.PNG" width="30%" />
</p>

- Bajar a la sección "*Parámetros y Settings*". 
- Algunas propiedades en esta sección se cambian por medio de *dropdown menus*. Si es la primera vez que se utiliza alguno de los livescripts, Matlab ejecutará el script cada vez que se intente cambiar una opción en los menús. Para evitar esto, el usuario debe deshabilitar manualmente esta opción para cada *dropdown menu* de la siguiente forma:

<p align="center">
   <img src="./Media/DropdownAutorun.gif" width="40%" />
</p>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <sub> Nota: Una vez cambiado, no es necesario volver a repetir este proceso. </sub>

- El usuario puede alterar las diferentes propiedades de la simulación. Se provee una breve descripción de cada parámetro al lado de cada variable. La propiedad principal a alterar es la de `Metodo` (*SR Toolbox*) o `CostFunc` (*Pruebas PSO Tuner*). Para observar el generador de trayectorias, elegir la opción `Dynamic Programming` como método en `SR_Toolbox.mlx`.
- Presionar `Run Section`. El programa debería de desplegar una figura de simulación acorde al `Metodo` / `CostFunc` elegido. Si se desea generar una nueva simulación, presionar nuevamente `Run Section`.

<p align="center">
   <img src="./Media/CorriendoSimulacion.gif" width="80%" />
</p>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <sub>Nota: El GIF fue acelerado artificialmente. La inicialización del script toma más tiempo del mostrado.</sub>

## Hardware y Software

Los diferentes scripts del *SR Toolbox* se probaron en dos sistemas diferentes, cada uno con diferentes especificaciones de hardware y software.

| <center>Desktop PC</center> | <center>Laptop</center> |
|---------------------|--------------------------------|
| - CPU: i7-4790K (4.4GHz) <br/>- GPU: Nvidia GTX 780 <br/>- RAM: 16 GB DDR3 <br/> - Matlab: 2020a | - CPU: i7-5700HQ (2.70GHz) <br/>- GPU: Nvidia GTX 960M <br/>- RAM: 16 GB DDR3 <br/> - Matlab: 2018b |

En ambos sistemas los scripts corrían sin problemas, aunque en la laptop se observaba una ligera pérdida en desempeño (las animaciones corrían más lento y los tiempos de inicialización eran mayores).

## Swarm Robotics Toolbox

[Ver documentación](SR_Toolbox.md)

## Pruebas PSO Tuner

[Ver documentación](PSO_Tuner.md)
