/*
 * Titulo:          e-puck_MPSO.c
 * Fecha:           14 de julio de 2019
 * Descripcion:     Controlador para aplicacion de MPSO algorithm a E-Pucks
 * Autor:           Aldo Aguilar Nadalini 15170
 * Modificaciones:  Juan Pablo Cahueque 15396
 */

//Librerias
#include <webots/robot.h>
#include <webots/distance_sensor.h>
#include <webots/emitter.h>
#include <webots/gps.h>
#include <math.h>
#include <stdio.h> 
#include <stdlib.h> 
#include <time.h> 
#include <errno.h> 

// Variables de configuracion (0 - control desactivado; 1 - control activado)
// - PID_CONTROLLER: Controlador PID para velocidad angular
// - NKC_CONTROLLER_1: Controlador simple de Pose de robot (v = kp*ep; w = ka*a + kb*b)
// - NKC_CONTROLLER_2: Controlador Lyapunov de Pose de robot (v = kp*ep*cos(a); w = kp*sin(a)*cos(a) + ka*a)
// - NKC_CONTROLLER_3: Controlador Closed-loop steering (v = kp*ep*cos(a); w = -(v/ep)*(k2*(-a - atan(-k1*b)) 
//                                                                        + (1 + k1/(1 + (k1*b)^2))*sin(-a)))
// - HARDSTOP_FILTER: filtro de cambios bruscos de velocidades de actuadores
#define PID_CONTROLLER    1
#define NKC_CONTROLLER_1  0
#define NKC_CONTROLLER_2  0
#define NKC_CONTROLLER_3  0
#define LQR_CONTROLLER    0
#define HARDSTOP_FILTER   1

// Orientation parameter (0 - usar angulo normal; 1 - usar angulo de brujula) [Desactivar con NKC CONTROLLERS!!!]
#define USE_BEARING 1

// Variables globales
#define TIME_STEP 32
#define MAX_SPEED 6.28
#define COMMUNICATION_CHANNEL 1
#define ROBOT_RADIUS 35.5
#define WHEEL_RADIUS 20.5

// PSO Update Parameter (No. de iteraciones de controlador entre cada actualizacion de posicion PSO)
// - Nota: un aumento de este parametro significa menos vectores directores PSO para trayectoria
#define PSO_STEP 1

// Inertia Parameter (0 - cte, 1 - linear, 2 - chaotic, 3 - random, 4 - exponential)
#define INERTIA_TYPE 4

// Fitness Function (0 - Sphere, 1 - Rosenbrock, 2 - Booth, 3 - Himmelblau, 4 - APF (JPC))
#define BENCHMARK_TYPE 4

// PSO Parameters (Default: Constriction = 0.8, Local Weight = 2; Global Weight = 10)
#define CONSTRICTION_FACTOR 0.8
#define COGNITIVE_WEIGTH 2
#define SOCIAL_WEIGTH 10
#define TIME_DELTA 1

#define DIVERSITY_FACTOR 35

// Modified PSO with diversity vector
#define DIVERSITY 0

// PID Parameters
#define K_PROPORTIONAL 0.5
#define K_INTEGRAL     0.1
#define K_DERIVATIVE   0.001

// NKC Parameters (K_p > 0; K_b < 0; K_a > K_p)
#define K_DISTANCE     0.01
#define K_ALPHA        0.5
#define K_BETA         0.05

// HARDSTOP Filter Parameters
#define MAX_CHANGE 1.00

// Posiciones de robot y valores de Fitness Function ----------------------------------------------------
static const double *position_robot;            // Variable que recibe vector de posicion [X, Y, Z] retornado por GPS

// Posicion y velocidad nuevas del robot
static double new_position[] = {0,0};           // X_{i+1} de PSO
static double new_velocity[] = {0,0};           // V_{i+1} de PSO
static double theta_g = 0;                      // Orientacion de nueva posicion respecto a robot

// Posicion y velocidad actual del robot
static double actual_position[] = {0,0};        // X_{i} de PSO
static double old_velocity[] = {0,0};           // V_{i} de PSO
static double theta_o = 0;                      // Orientacion actual de robot
static double fitness_actual = 0;               // Costo de posicion actual

// Variables de mejor posicion local encontrada por particula
static double best_local[] = {0,0};
static double fitness_local = 0;

// Variables de mejor posicion global encontrada por particula
static double best_global[] = {0,0};
static double fitness_global = 0;

// Vector para recepcion de datos de otros robots
static double reception[] = {0,0};

// Parametros de PSO
static double epsilon = CONSTRICTION_FACTOR;      // Parametro PSO de constriccion
static double c1 = COGNITIVE_WEIGTH;              // Parametro PSO de escalamiento cognitivo
static double c2 = SOCIAL_WEIGTH;                 // Parametro PSO de escalamiento social
static double w = 0;                              // Parametro PSO de inercia
static double rho1 = 0;                           // Parametro PSO de uniformidad cognitiva
static double rho2 = 0;                           // Parametro PSO de uniformidad social
static double delta_t = TIME_DELTA;               // Parametro de tiempo para escalamiento de velocidad PSO
static double c3 = DIVERSITY_FACTOR;
static double rho3 = 0;

// Variables de calculo de Parametro PSO de Inercia
static double w_min = 0.5;                        // Limite minimo de valor de parametro PSO de inercia
static double w_max = 1.0;                        // Limite maximo de valor de parametro PSO de inercia
static int MAXiter = 10000;                       // Cantidad maxima de iteraciones
static int iter = 0;                              // Contador de iteraciones ejecutadas

// Variables de Proportional Integral Derivative controller (PID)
static double KP = K_PROPORTIONAL;                // Constante de control proporcional
static double KI = K_INTEGRAL;                    // Constante de control integral
static double KD = K_DERIVATIVE;                  // Constante de control derivativo
static double e_old = 0;                          // Error de PID anterior
static double E_old = 0;                          // Error anterior acumulado de PID
static double e_o = 0;                            // Error de PID actual
static double E_o = 0;                            // Error actual acumulado de PID
static double e_D = 0;                            // Error diferencial

// Variables de Non-lineal Kinematics controller (NKC)
static double alpha = 0;                          // Angulo entre vector de distancia robot-meta y vector frontal de robot
static double beta = 0;                           // Angulo de orientacion de meta respecto a marco inercial
static double rho_p = 0;                          // Distancia euclideana entre centroide de robot y meta
static double K_RHO = K_DISTANCE;                 // Constante de control de distancia
static double K_A = K_ALPHA;                      // Constante de control de orientacion
static double K_B = -K_BETA;                      // Constante de control de rotacion de meta

// Error de posicion entre robot y meta
static double e_x = 0;                            // Diferencial de posicion horizontal
static double e_y = 0;                            // Diferencial de posicion vertical
static double e_p = 0;                            // Distancia euclidiana entre robot y meta

// Variables de velocidades angulares pasadas de motores para Filtro de Picos
static double phi_r = 0;                          // Velocidad angular actual de motor derecho de robot
static double phi_l = 0;                          // Velocidad angular actual de motor izquierdo de robot
static double PhiR_old = 0;                       // Velocidad angular anterior de motor derecho de robot
static double PhiL_old = 0;                       // Velocidad angular anterior de motor izquierdo de robot

// Zero variable
static int zero = 0;
static int number_iteration = 0;

// Bandera de Inicializacion
bool state = false;


// Generador de numeros random 
double printRandoms(int lower, int upper, int count) { 
  int i;
  double num;
  for (i = 0; i < count; i++) { 
    num = (rand() % (upper - lower + 1)) + lower; 
  } 
  return num;
}


//Funcion para hallar distancia euclediana
double euclidean_distance(double x1, double y1, double x2, double y2){
  double distance = 0;
  distance =  pow(pow(x1-x2,2)+pow(y1-y2,2),0.5);
  return distance;
}

// Funcion para hallar la distancia minima hacia 3 obstaculos
double min_distance3(double x1, double y1){
  double ysize = 0.2;
  double xsize = 0.2;
  double ybox1 = 0.85;
  double xbox1 = -0.253;
  double ybox2 = 0.512;
  double xbox2 = 0.0506;
  double ybox3 = 0.849;
  double xbox3 = 0.57;
  
  double h1, h2;
  
  double min1 = 0;
  double min2 = 0;
  double min3 = 0;
  
  double minTot = 0;
  
  //Caja 1
  
  double xcoord1 = xbox1+xsize;
  double xcoord2 = xbox1-xsize;
  double ycoord1 = ybox1+ysize;
  double ycoord2 = ybox1-ysize;

  if (x1 < (xcoord1) && x1 > (xcoord2)){
    if (y1 > (ycoord1)){
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord1));
    }
    else{
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord2));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord2));
    }
    double theta1 = acos(h1*h1-h2*h2-xsize*xsize+2*h2*xsize);
    min1 = h2*sin(theta1);
  }
  if (y1 < (ycoord1) && y1 > (ycoord2)){
    if (x1 > (xcoord1)){
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord1),(ycoord2));
    }
    else{
      h1 = euclidean_distance(x1,y1,(xcoord2),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord2));
    }
    double theta1 = acos(h1*h1-h2*h2-xsize*xsize+2*h2*xsize);
    min1 = h2*sin(theta1);
  }
  if (x1 > xcoord1){
    if (y1 > ycoord1){
      min1 = euclidean_distance(x1,y1,xcoord1,ycoord1);
    }
    else{
      min1 = euclidean_distance(x1,y1,xcoord1,ycoord2);
    } 
  }
  else{
    if (y1 > ycoord1){
      min1 = euclidean_distance(x1,y1,xcoord2,ycoord1);
    }
    else{
      min1 = euclidean_distance(x1,y1,xcoord2,ycoord2);
    } 
  }
  
  //Caja 2
  
  xcoord1 = xbox2+xsize;
  xcoord2 = xbox2-xsize;
  ycoord1 = ybox2+ysize;
  ycoord2 = ybox2-ysize;

  if (x1 < (xcoord1) && x1 > (xcoord2)){
    if (y1 > (ycoord1)){
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord1));
    }
    else{
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord2));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord2));
    }
    double theta1 = acos(h1*h1-h2*h2-xsize*xsize+2*h2*xsize);
    min2 = h2*sin(theta1);
  }
  if (y1 < (ycoord1) && y1 > (ycoord2)){
    if (x1 > (xcoord1)){
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord1),(ycoord2));
    }
    else{
      h1 = euclidean_distance(x1,y1,(xcoord2),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord2));
    }
    double theta1 = acos(h1*h1-h2*h2-xsize*xsize+2*h2*xsize);
    min2 = h2*sin(theta1);
  }
  if (x1 > xcoord1){
    if (y1 > ycoord1){
      min2 = euclidean_distance(x1,y1,xcoord1,ycoord1);
    }
    else{
      min2 = euclidean_distance(x1,y1,xcoord1,ycoord2);
    } 
  }
  else{
    if (y1 > ycoord1){
      min2 = euclidean_distance(x1,y1,xcoord2,ycoord1);
    }
    else{
      min2 = euclidean_distance(x1,y1,xcoord2,ycoord2);
    } 
  }
  
  //Caja 3
  
  xcoord1 = xbox3+xsize;
  xcoord2 = xbox3-xsize;
  ycoord1 = ybox3+ysize;
  ycoord2 = ybox3-ysize;

  if (x1 < (xcoord1) && x1 > (xcoord2)){
    if (y1 > (ycoord1)){
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord1));
    }
    else{
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord2));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord2));
    }
    double theta1 = acos(h1*h1-h2*h2-xsize*xsize+2*h2*xsize);
    min3 = h2*sin(theta1);
  }
  if (y1 < (ycoord1) && y1 > (ycoord2)){
    if (x1 > (xcoord1)){
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord1),(ycoord2));
    }
    else{
      h1 = euclidean_distance(x1,y1,(xcoord2),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord2));
    }
    double theta1 = acos(h1*h1-h2*h2-xsize*xsize+2*h2*xsize);
    min3 = h2*sin(theta1);
  }
  if (x1 > xcoord1){
    if (y1 > ycoord1){
      min3 = euclidean_distance(x1,y1,xcoord1,ycoord1);
    }
    else{
      min3 = euclidean_distance(x1,y1,xcoord1,ycoord2);
    } 
  }
  else{
    if (y1 > ycoord1){
      min3 = euclidean_distance(x1,y1,xcoord2,ycoord1);
    }
    else{
      min3 = euclidean_distance(x1,y1,xcoord2,ycoord2);
    } 
  }
  
  //Encontrar el minimo entre los tres
  if (min1 < min2){
    if(min1 < min3){
      minTot = min1;
    }
    else{
      minTot = min2;
    }
  }
  else{
    if(min2 < min3){
      minTot = min2;
    }
    else{
      minTot = min3;
    }
  }
  
  return minTot;
}

double min_distance(double x1, double y1){
  double ysize = 0.2/2;
  double xsize = 0.8/2;
  double ybox1 = 0.2;
  double xbox1 = 0;
  
  double h1, h2;
  
  double min1 = 0;
  
  double minTot = 0;
  
  //Caja 1
  
  double xcoord1 = xbox1+xsize;
  double xcoord2 = xbox1-xsize;
  double ycoord1 = ybox1+ysize;
  double ycoord2 = ybox1-ysize;

  if (x1 < (xcoord1) && x1 > (xcoord2)){
    //printf("Position: %s - X: \"%lf\" Y: \"%lf\"Xcoord1:\"%lf\" \n", wb_robot_get_name(), position_robot[2], position_robot[0],xcoord2);
    if (y1 > (ycoord1)){
      //printf("Position: %s - X: \"%lf\" Y: \"%lf\"Xcoord1:\"%lf\" \n", wb_robot_get_name(), position_robot[2], position_robot[0],ycoord1);
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord1));
    }
    else{
      //printf("Position: %s - X: \"%lf\" Y: \"%lf\"Xcoord1:\"%lf\" \n", wb_robot_get_name(), position_robot[2], position_robot[0],ycoord2);
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord2));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord2));
    }
    double theta1 = acos(h1*h1-h2*h2-xsize*xsize+2*h2*xsize);
    min1 = h2*sin(theta1);
  }
  if (y1 < (ycoord1) && y1 > (ycoord2)){
    if (x1 > (xcoord1)){
      h1 = euclidean_distance(x1,y1,(xcoord1),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord1),(ycoord2));
    }
    else{
      h1 = euclidean_distance(x1,y1,(xcoord2),(ycoord1));
      h2 = euclidean_distance(x1,y1,(xcoord2),(ycoord2));
    }
    double theta1 = acos(h1*h1-h2*h2-xsize*xsize+2*h2*xsize);
    min1 = h2*sin(theta1);
  }
  if (x1 > xcoord1){
    if (y1 > ycoord1){
      min1 = euclidean_distance(x1,y1,xcoord1,ycoord1);
    }
    else{
      min1 = euclidean_distance(x1,y1,xcoord1,ycoord2);
    } 
  }
  else{
    if (y1 > ycoord1){
      min1 = euclidean_distance(x1,y1,xcoord2,ycoord1);
    }
    else{
      min1 = euclidean_distance(x1,y1,xcoord2,ycoord2);
    } 
  }
  
  return min1;
}

// Funcion para evaluar Fitness Function de espacio utilizando Benchmark Functions
double fitness(double x, double y){
  double r = 0;
  double Uatt, Urep, Utot, dist2goal, diq, Qi, dstar, eta, zeta;
  if (BENCHMARK_TYPE == 0){
    r = pow(x,2) + pow(y,2);                            // Sphere Benchmark Function
  } else if (BENCHMARK_TYPE == 1){
    r = pow(1 - x,2) + 100 * pow(y - pow(x,2),2);       // Rosenbrock Benchmark Function
  } else if (BENCHMARK_TYPE == 2){
    r = pow(x + 2*y - 7,2) + pow(2*x + y - 5,2);        // Booth Benchmark Function
  } else if (BENCHMARK_TYPE == 3){
    r = pow(x*x + y - 11,2) + pow(x + y*y - 7,2);       // Himmelblau Benchmark Function
  } else if (BENCHMARK_TYPE == 4){
    dstar = 0.7;
    Qi = 0.1;
    eta = 2;
    zeta = 10;
    dist2goal = euclidean_distance(x,y,0,0.7);
    if (dist2goal <= dstar){
      Uatt = 0.5*zeta*pow(dist2goal,2);
    }
    else {
      Uatt = dstar*zeta*dist2goal-0.5*zeta*dstar*dstar;
    }
    diq = min_distance(x,y);
    //printf(diq);
    if (diq < Qi){
      Urep = 0.5*eta*pow((1/diq)-(1/Qi),2); 
    }
    else {
      Urep = 0;
    }
    r = Urep*Uatt+Uatt;
    //printf("Position: %s - X: \"%lf\" Y: \"%lf\"-Urep: \"%lf\"-diq: \"%lf\" \n", wb_robot_get_name(), position_robot[2], position_robot[0], Urep,diq);
  }
  return r;
}


// Main function
int main() {

  // Inicializar WeBots Controlled Library
  wb_robot_init();
  
  // Open log file according to E-Puck ID
  FILE * fp;
  if (strcmp(wb_robot_get_name(), "e-puck") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck0.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(1)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck1.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(2)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck2.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(3)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck3.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(4)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck4.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(5)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck5.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(6)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck6.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(7)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck7.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(8)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck8.txt", "w");
  } else if (strcmp(wb_robot_get_name(), "e-puck(9)") == 0){
   fp = fopen("C:\\Users\\JuanPablo\\Documents\\epuck\\epuck9.txt", "w");
  } else {
   fp = 0;
   printf("LINE 122: ERROR E-PUCK NAME\n");
  }

  if (fp == NULL){
   printf("CANNOT open the file\n");
  }
  
  // Obtener handle de GPS de robot
  WbNodeType gps = wb_robot_get_device("gps");
  wb_gps_enable(gps, TIME_STEP);
  
  // Obtener handle de brujula de robot
  WbNodeType compass = wb_robot_get_device("compass");
  wb_compass_enable(compass, TIME_STEP);
  
  // Obtener handle de motores de robot
  WbDeviceTag left_motor = wb_robot_get_device("left wheel motor");
  WbDeviceTag right_motor = wb_robot_get_device("right wheel motor");
  
  // Configurar rotacion perpetua
  wb_motor_set_position(left_motor, INFINITY);
  wb_motor_set_position(right_motor, INFINITY);
  
  // Configurar velocidades iniciales
  wb_motor_set_velocity(left_motor, 0.0);
  wb_motor_set_velocity(right_motor, 0.0);
  
  // Configurar funciones de Emitter-Receiver
  WbDeviceTag emitter = wb_robot_get_device("emitter");
  wb_emitter_set_channel(emitter, COMMUNICATION_CHANNEL);       // COMMUNICATION_CHANNEL 1
  WbDeviceTag receiver = wb_robot_get_device("receiver");
  wb_receiver_enable(receiver, TIME_STEP);                      // TIME_STEP 32

  // Main loop de control (pasos de 32 milisegundos)
  while (wb_robot_step(TIME_STEP) != -1) {
    number_iteration++;
  
    // ----------------------------- CONFIGURACION INICIAL ---------------------------------------
  
    // Configurar valores iniciales de PSO local y global (Ejecutar solo una vez)
    if (state == false){
      position_robot = wb_gps_get_values(gps);
      actual_position[0] = position_robot[2];   // Coordenada en eje Z de simulacion es coordenada X
      actual_position[1] = position_robot[0];   // Coordenada en eje X de simulacion es coordenada Y
      best_local[0] = actual_position[0];
      best_local[1] = actual_position[1];
      best_global[0] = actual_position[0];
      best_global[1] = actual_position[1];
      
      // Calcular Fitness Value
      fitness_local = fitness(actual_position[0], actual_position[1]);
      fitness_global = fitness(actual_position[0], actual_position[1]);
      state = true;
    }
    
    // ------------------- OBTENCION DE POSICION Y ORIENTACION DE ROBOT ---------------------
    
    /*
     * NOTA: Eje X (rojo) es el norte y es tratado como Y en simulacion
     *       Eje Z (azul) es el este y es tratado como X en simulacion
     *       Eje Y (verde) es el zenith y apunta hacia el cielo
     */
  
    // Obtener posicion del E-Puck
    position_robot = wb_gps_get_values(gps);                    // Devuelve [X,Y,Z] en vector, y aca ya se toma Z como X y X como Y
    
    // Obtener orientacion de E-Puck
    const double *north = wb_compass_get_values(compass);
    double rad = atan2(north[0], north[2]);
    
    // Orientacion obtenida como angulo de brujula
    double bearing = ((rad) / M_PI) * 180.0;
    theta_o = bearing + 180;
    
    // Orientacion obtenida como angulo normal
    double bearing2 = ((rad) / M_PI) * 180.0;
    if (bearing2 < 0){
      bearing2 = 360 + bearing2;           // Asegurar que angulo -> [0, 2*pi)
    }                                       
    double theta_o2 = 270 - bearing2;
    if (theta_o2 < 0){
      theta_o2 = theta_o2 + 360;           // Asegurar que angulo -> [0, 2*pi)
    }
    
    // Si Bearing angle desactivado, utilizar orientacion normal
    if (USE_BEARING == 0){
      theta_o = theta_o2;
    }                                                
    
    // Impresion de datos de Posicion y Orientacion
    //printf("Position: %s - X: \"%lf\" Y: \"%lf\"\n", wb_robot_get_name(), position_robot[2], position_robot[0]);
    //printf("Rotation: %s - Theta: \"%lf\" - Theta2: \"%lf\"\n", wb_robot_get_name(), theta_o, theta_o2);
    fprintf(fp,"P,%s,%lf,%lf,%lf,%lf\r\n", wb_robot_get_name(), position_robot[2], position_robot[0],zero,zero);
    fprintf(fp,"R,%s,%lf,%lf,%lf,%lf\r\n", wb_robot_get_name(), theta_o,zero,zero,zero);
        
    // ------------------------- ACTUALIZACION DE LOCAL AND GLOBAL BESTS -------------------------
    
    // Calcular Fitness Value de posicion actiaul
    actual_position[0] = position_robot[2];
    actual_position[1] = position_robot[0];
    fitness_actual = fitness(actual_position[0], actual_position[1]);
    
    // Actualizar local best si posicion actual posee un mejor fitness value
    if (fitness_actual < fitness_local){
      best_local[0] = actual_position[0];
      best_local[1] = actual_position[1];
      fitness_local = fitness_actual;
    }
    
    // Transmision de Local Best a otros robots para poleo de Global Best
    double transmission[3] = {best_local[0],best_local[1],fitness_local};
    wb_emitter_send(emitter, transmission, 3 * sizeof(double));
    
    // Recepcion de otros datos de robots para polear todos los local bests a propio global best
    while (wb_receiver_get_queue_length(receiver) > 0) {
      const double *buffer = wb_receiver_get_data(receiver);
      reception[0] = buffer[0];
      reception[1] = buffer[1];
      reception[2] = buffer[2];
      
      // Actualizar global best
      if (reception[2] < fitness_global){
        best_global[0] = reception[0];
        best_global[1] = reception[1];
        fitness_global = reception[2];
      }
      wb_receiver_next_packet(receiver);
    }
    
    // Actualizar global best (si propio local best es mejor que el mejor global)
    if (fitness_local < fitness_global){
      best_global[0] = best_local[0];
      best_global[1] = best_local[1];
      fitness_global = fitness_local;
    }
    
    //printf("Fitness:  %s - Local Best: \"%lf\" - Global Best: \"%lf\" \n", wb_robot_get_name(), fitness_local, fitness_global);
    fprintf(fp,"F,%s,%lf,%lf,%lf,%lf\r\n", wb_robot_get_name(), fitness_local, fitness_global,zero,zero);
    
    // ---------------------------------- MPSO ALGORITHM -----------------------------------

    // Generacion de valores de Parametros de Uniformidad (rho = [0,1])
    rho1 = printRandoms(0, 1, 1);
    rho2 = printRandoms(0, 1, 1);
    rho3 = printRandoms(0, 1, 1);
    
    // Calculos de Inercia variante en el tiempo -----------------------
    if (INERTIA_TYPE == 0){
      // Parametro de Inercia constante (Funcionalidad regular)
      w = 0.8;
    } else if (INERTIA_TYPE == 1){
      // Parametro de Inercia lineal decreciente (Funcionalidad mala)
      w = w_max - (w_max - w_min)*iter/MAXiter;
    } else if (INERTIA_TYPE == 2){
      // Parametro de inercia caotico (Funcionalidad regular mala)
      double zi = 0.2;
      double zii = 4*zi*(1 - zi);
      w = (w_max - w_min)*((MAXiter - iter)/MAXiter)*w_max*zii;
      iter = iter + 1;
    } else if (INERTIA_TYPE == 3){
      // Parametro de inercia random (Funcionalidad buena)
      w = 0.5 + printRandoms(0, 1, 1)/2;
    } else if (INERTIA_TYPE == 4){
      // Parametro de inercia exponencial (Funcionalidad excelente)
      w = w_min + (w_max - w_min)*exp((-1*iter)/(MAXiter/10));
      iter = iter + 1;
    }
    
    // Ecuacion de Velocidad PSO para calculo de nueva velocidad de agente
    old_velocity[0] = new_velocity[0];
    old_velocity[1] = new_velocity[1];
    new_velocity[0] = epsilon * (w*old_velocity[0]  + c1*rho1*(best_local[0] - actual_position[0]) + c2*rho2*(best_global[0] - actual_position[0]));
    new_velocity[1] = epsilon * (w*old_velocity[1]  + c1*rho1*(best_local[1] - actual_position[1]) + c2*rho2*(best_global[1] - actual_position[1]));
    if (DIVERSITY == 1){
      new_velocity[0] = epsilon * c3 *(rho3-0.5) + new_velocity[0];
      new_velocity[1] = epsilon * c3 *(rho3-0.5) + new_velocity[1];
    }
    
    // Ecuacion de Posicion PSO para calculo de nueva posicion de agente
    if (number_iteration % PSO_STEP == 0){
      new_position[0] = actual_position[0] + new_velocity[0] * delta_t;
      new_position[1] = actual_position[1] + new_velocity[1] * delta_t;
    }
    
    //printf("PSO-XY:  %s - X: \"%lf\" Y: \"%lf\"\n", wb_robot_get_name(), new_position[0], new_position[1]);
    fprintf(fp,"U,%s,%lf,%lf,%lf,%lf\r\n", wb_robot_get_name(), new_position[0],new_position[1],actual_position[0],actual_position[1]);
    
    // ---------------------------- VARIABLES DE CONTROLADORES ---------------------------------

    // Inicializacion de velocidad lineal y angular
    double v = 0;                                               // Velocidad lineal de robot
    double w = 0;                                               // Velocidad angular de robot
    
    // Calculo de error de distancias
    e_x = new_position[0] - actual_position[0];                 // Error en posicion X
    e_y = new_position[1] - actual_position[1];                 // Error en posicion Y
    e_p = sqrt(pow(e_y,2) + pow(e_x,2));                        // Magnitud de error vectorial
    
    // Dimensiones de E-Puck
    double l = ROBOT_RADIUS/1000;                               // Distancia de centro a llantas en metros
    double r = WHEEL_RADIUS/1000;                               // Radio de llantas en metros
    double a = ROBOT_RADIUS/1000;                               // Distancia entre centro y punto de disomorfismo (E-puck front)
    
    // ------------------------- CONTROL DE ECUACIONES CINEMATICAS -----------------------------

    // Constantes de ponderacion
    double K = 3.12*(1 - exp(-2*e_p))/e_p;                      // Ponderacion K en funcion de magnitud del error de posicion
    
    // Si Bearing angle desactivado (desde vertical +X), utilizar orientacion normal (desde horizontal +Z) 
    if (USE_BEARING == 0){
      // Velocidad Lineal (aplicada con matriz de disomorfismo y 2*tanh(x) para acotar velocidades a MAX_SPEED de E-Puck (6.28 rad/s)
      v = (2*tanh((K/MAX_SPEED)*e_x)) * cos((theta_o)*M_PI/180) + 
          (2*tanh((K/MAX_SPEED)*e_y)) * sin((theta_o)*M_PI/180);
              
      // Velocidad Angular (aplicada con matriz de disomorfismo y 2*tanh(x) para acotar velocidades a MAX_SPEED de E-Puck (6.28 rad/s)
      w  = (2*tanh((K/MAX_SPEED)*e_x)) * (-sin((theta_o)*M_PI/180)/a) +
          (2*tanh((K/MAX_SPEED)*e_y)) * (cos((theta_o)*M_PI/180)/a);
    } else {
      // Velocidad Lineal (aplicada con matriz de disomorfismo y 2*tanh(x) para acotar velocidades a MAX_SPEED de E-Puck (6.28 rad/s)
      v = (2*tanh((K/MAX_SPEED)*e_x)) * cos((90 - theta_o)*M_PI/180) + 
          (2*tanh((K/MAX_SPEED)*e_y)) * sin((90 - theta_o)*M_PI/180);
              
      // Velocidad Angular (aplicada con matriz de disomorfismo y 2*tanh(x) para acotar velocidades a MAX_SPEED de E-Puck (6.28 rad/s)
      w  = (2*tanh((K/MAX_SPEED)*e_x)) * (-sin((90 - theta_o)*M_PI/180)/a) +
          (2*tanh((K/MAX_SPEED)*e_y)) * (cos((90 - theta_o)*M_PI/180)/a);
    }

    // ------------------------- CONTROL PID DE VELOCIDAD ANGULAR ------------------------------

    // Si Bearing angle desactivado (desde vertical +X), utilizar orientacion normal (desde horizontal +Z)  
    if (USE_BEARING == 0){
      // Angulo de meta calculado en orientacion normal desde horizontal (+Z en simulacion)
      theta_g = atan2(new_position[1] - actual_position[1], new_position[0] - actual_position[0]);
    } else {
      // Angulo de meta calculado en orientacion de brujula desde vertical (+X en simulacion)
      theta_g = atan2(new_position[0] - actual_position[0], new_position[1] - actual_position[1]);
    }
    
    // Calculo de error de distancia angular (Diferencia entre eje -Z de robot y norte, y angulo de la meta respecto a robot y norte)
    e_o = atan2(sin(theta_g - (theta_o*M_PI/180)), cos(theta_g - (theta_o*M_PI/180)));
    
    // PID de velocidad angular
    e_D = e_o - e_old;
    E_o = E_old + e_o;
    if (PID_CONTROLLER){
      w = KP*e_o + KI*E_o + KD*e_D;
    }
    e_old = e_o;
    E_old = E_o;

    // ---------------------------- CONTROLES NO LINEALES DE ROBOT -----------------------------
    
    // Distancia entre centro de robot y punto de meta
    rho_p = e_p;
    
    // Limitar angulo entre eje frontal de robot (-Z_R) y vector hacia meta dentro de rango [-pi pi]
    alpha = - (theta_o*M_PI/180) + atan2(e_y, e_x);
    if (alpha < -M_PI){
      alpha = alpha + (2*M_PI);
    } else if (alpha > M_PI){
      alpha = alpha - (2*M_PI);
    }
    
    // Limitar angulo de orientacion de meta entre [-pi pi]
    beta = - (theta_o*M_PI/180) - alpha;
    if (beta < -M_PI){
      beta = beta + (2*M_PI);
    } else if (beta > M_PI){
      beta = beta - (2*M_PI);
    }
    
    // Controlador simple de pose de robot
    if (NKC_CONTROLLER_1){
      v = K_RHO * rho_p;
      w = K_A * alpha + K_B * beta;
      if ((alpha <= -M_PI/2) || (alpha > M_PI/2)){             // Si alpha se encuentra en cuadrantes izquierdos, se invierte velocidad lineal
        v = -v;
      }
    }
    
    // Controlador Lyapunov de pose de robot
    if (NKC_CONTROLLER_2){
      v = K_RHO * rho_p * cos(alpha);
      w = K_RHO * sin(alpha) * cos(alpha) + K_A * alpha;
      if ((alpha <= -M_PI/2) || (alpha > M_PI/2)){             // Si alpha se encuentra en cuadrantes izquierdos, se invierte velocidad lineal
        v = -v;
      }
    }
    
    // Controlador Closed-loop steering
    if (NKC_CONTROLLER_3){
      double k_1 = 1;
      double k_2 = 10;
      //v = K_RHO * rho_p * cos(alpha);                        // Minimiza tiempo y suaviza velocidades pero falla convergencia por 2
      w = -(v/rho_p)*(k_2*(-alpha - atan(-k_1*beta)) + (1 + k_1/(1 + pow(k_1*beta,2)))*sin(-alpha));
      
      // Linear Velocity Selector
      //double lambda = 2;
      //double b_parameter = 0.4;
      //double curve = 0;
      //curve = -(1/rho_p)*(k_2*(-alpha - atan(-k_1*beta)) + (1 + k_1/(1 + pow(k_1*beta,2)))*sin(-alpha));
      //v = 0.05/(1 + b_parameter*pow(abs(curve),2));
      //w = curve*v;
    }
    
    if (LQR_CONTROLLER){
      double K_x = 0.1;
      double K_y = 0.1;
      double u_1 = K_x*e_x;
      double u_2 = K_y*e_y;
      
      double nBar = 0.05;
      
      u_1 = nBar*new_position[0] - K_x*actual_position[0];
      u_2 = nBar*new_position[1] - K_y*actual_position[1];
      v = u_1*cos((theta_o)*M_PI/180) + u_2*sin((theta_o)*M_PI/180);
      w = (-u_1*sin((theta_o)*M_PI/180) + u_2*cos((theta_o)*M_PI/180))/1;
    }
    
    fprintf(fp,"Z,%s,%lf,%lf,%lf,%lf\r\n", wb_robot_get_name(), rho_p,alpha,beta,zero);

    // Terminacion de movimiento al estar cerca de la meta para evitar hard-switches o vibraciones de robots al llegar a la meta
    if (fabs(e_p) < 0.005){
      v = 0;
      w = 0;
    }

    // --------------- TRANSFORMACION DE VELOCIDADES CON MODELO DIFERENCIAL --------------------
              
    // Calculo de velocidades angulares de motores de E-Puck dependiendo la velocidad lineal y angular requeridas    
    phi_r = (v + w*l)/r;
    phi_l = (v - w*l)/r;
    
    // Truncar velocidades de rotacion de motor derecho a [-6.28, 6.28]
    if (phi_r > 0){
      if (phi_r > MAX_SPEED){
        phi_r = MAX_SPEED;
      }
    } else {
      if (phi_r < -MAX_SPEED){
        phi_r = -MAX_SPEED;
      }
    }
    
    // Truncar velocidades de rotacion de motor izquierdo a [-6.28, 6.28]
    if (phi_l > 0){
      if (phi_l > MAX_SPEED){
        phi_l = MAX_SPEED;
      }
    } else {
      if (phi_l < -MAX_SPEED){
        phi_l = -MAX_SPEED;
      }
    }
    
    // Limpieza de Picos
    if (HARDSTOP_FILTER){
      if(sqrt(pow(phi_r - PhiR_old,2)) > MAX_CHANGE){
        phi_r = (phi_r + 2*PhiR_old)/3;
      }
      PhiR_old = phi_r;
      if(sqrt(pow(phi_l - PhiL_old,2)) > MAX_CHANGE){
        phi_l = (phi_l + 2*PhiL_old)/3;
      }
      PhiL_old = phi_l;
    }
    
    // Actualizacion de velocidades de motores en simulacion
    wb_motor_set_velocity(left_motor, phi_l);
    wb_motor_set_velocity(right_motor, phi_r);
    
    // Impresion de telemetria de robots
    //printf("Velocity: %s - V: \"%lf\" W: \"%lf\" R: \"%lf\" L: \"%lf\"\n", wb_robot_get_name(), v, w, phi_r, phi_l);
    fprintf(fp,"V,%s,%lf,%lf,%lf,%lf\r\n", wb_robot_get_name(), v, w, phi_r, phi_l);
    
  }

  fclose(fp);
  wb_robot_cleanup();

  return 0;
}