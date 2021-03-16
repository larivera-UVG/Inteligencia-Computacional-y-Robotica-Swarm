%% Diseño e Innovacion de Ingenieria
% Titulo: TrajectoryGraph.m
% Autor: Aldo Aguilar Nadalini 15170
% Fecha: 02 de junio de 2019
% Descripcion: Programa para graficar automaticamente resultados de
%              simulaciones

%% Recoleccion de muestras

% Lectura de archivos de resultados de E-Puck (escritos por Webots)
EPuck0 = readtable('epuck0.txt');
EPuck1 = readtable('epuck1.txt');
EPuck2 = readtable('epuck2.txt');
EPuck3 = readtable('epuck3.txt');
EPuck4 = readtable('epuck4.txt');
EPuck5 = readtable('epuck5.txt');
EPuck6 = readtable('epuck6.txt');
EPuck7 = readtable('epuck7.txt');
EPuck8 = readtable('epuck8.txt');
EPuck9 = readtable('epuck9.txt');

%% Separacion de datos de cada E-Puck

% Elegir E-Puck a analizar (0-9)
ID = 0;
MAX_TIME = 15000;
PSO_VECT_DIV = 20;
use_keane = 0;

% Trayectoria de robot ------------------------
h0 = figure;
str = ['ID: E-Puck (',num2str(ID),')'];
set(h0,'units','points','position',[60,95,520,420],'name',str);
set(h0,'color','w');
set(h0,'renderer','Painters');
ax = axes('Parent',h0,'Position',[0.083 0.085 0.894 0.884]);

if (use_keane == 1)
    f = @(x,y) -(sin((2*x) - y)^2 * sin((2*x) + y)^2)/(sqrt((2*x)^2 + y^2));
else
    f = @(x,y) x^2 + y^2;
    %f = @(x,y) (x^2 + y - 11)^2 + (x + y^2 - 7)^2;
    %f = @(x,y) 0.5 + (cos(sin(abs(x^2 - y^2)))^2 - 0.5)/(1 + 0.001*(x^2 + y^2))^2;
end
  
fcontour(f,'LevelStep',0.05);
hold on;

for ID = 0:9

if (ID == 0)
    EPuck = EPuck0;
elseif (ID == 1)
    EPuck = EPuck1;
elseif (ID == 2)
    EPuck = EPuck2;
elseif (ID == 3)
    EPuck = EPuck3;
elseif (ID == 4)
    EPuck = EPuck4;
elseif (ID == 5)
    EPuck = EPuck5;
elseif (ID == 6)
    EPuck = EPuck6;
elseif (ID == 7)
    EPuck = EPuck7;
elseif (ID == 8)
    EPuck = EPuck8;
elseif (ID == 9)
    EPuck = EPuck9;
end
    
headers = char(EPuck{:,1});                     % Recopilacion de headers para identificacion de tipo de datos
epuck_name = string(EPuck{1,2});                % Identificacion del E-Puck analizado
data = [EPuck{:,3},EPuck{:,4},EPuck{:,5},EPuck{:,6}];   % Datos de simulacion (Columnas 3-6)

PX = [];                                        % Datos de posicion en X de E-Puck(0)
PY = [];                                        % Datos de posicion en Y de E-Puck(0)
R = [];                                         % Datos de rotacion de E-Puck (restarle offset de 270° mas adelante)

BG_X = [];                                      % Coordenada X de best global
BG_Y = [];                                      % Coordenada Y de best global
FG = [];                                        % Fitness de Global Best

plottear = 0;
data_length = 1290;                              % DATO EXPERIMENTAL <<<<<<<<<<<<<<<<<<<<
matrix_PX = zeros(10,data_length);
matrix_PY = zeros(10,data_length);

% Separacion de datos segun su identificador en matriz de data
for i = 1:length(headers)
    if (headers(i) == 'P')
        PX(end + 1) = data(i,1);
        PY(end + 1) = data(i,2);
    elseif (headers(i) == 'R')
        R(end + 1) = data(i,1) - 180;           % Se le resta offset de 270° a dato
    elseif (headers(i) == 'F')
        FG(end + 1) = data(i,2);
        BG_X(end + 1) = data(i,3);
        BG_Y(end + 1) = data(i,4);
    end
end

% Plottear trayectoria
plot(PX,PY,'LineWidth',2,'Color',[.2 .5 .7]);
hold on;
scatter(PX(1),PY(1),100,'r','LineWidth',2);
hold on;
%scatter(BG_X,BG_Y,'g','filled');
hold on;

% Dato experimental para ajustar linea 67
length(PX)

if (plottear)
% Position Loggers
matrix_PX(ID + 1,:) = PX;
matrix_PY(ID + 1,:) = PY;
end

end

if (use_keane == 1)
    scatter([0.7],[0],50,'k','filled');
    hold on;
    scatter([-0.7],[0],50,'k','filled');
    hold on;
else
    scatter([0],[0],50,'k','filled');
end
xlim([-1 1]); ylim([-1 1]);
%xlim([-2 2]); ylim([-2 2]);
grid on; grid minor;
xlabel('X (m)','FontSize',14); ylabel('Y (m)','FontSize',14);
legend('Funcion de costo Sphere','Trayectoria (X,Y) de robots','Posicion inicial de robots','Location','southeast')


% ---------------- Calculo de Dispersion de Enjambre ----------------------
sigma_X = zeros(1,data_length);
sigma_Y = zeros(1,data_length);
mean_X = zeros(1,data_length);
mean_y =zeros(1,data_length);

for k = 1:size(matrix_PX,2)
    sigma_X(k) = std(matrix_PX(:,k));
    sigma_Y(k) = std(matrix_PY(:,k));
    mean_X(k) = mean(matrix_PX(:,k));
    mean_Y(k) = mean(matrix_PY(:,k));
end

t = linspace(0,length(sigma_X) - 1,length(sigma_X));

h1 = figure;
set(h1,'units','points','position',[60,95,520,420]);
set(h1,'color','w');
plot(t,sigma_X,'LineWidth',3,'Color',[.2 .4 .7]);
hold on;
plot(t,sigma_Y,'LineWidth',3,'Color',[.5 .9 .1]);
hold on;
xlim([0 data_length]); %ylim([-1 1]);
grid on; grid minor;
xlabel('No. de Iteraciones','FontSize',14); ylabel('Desviación Estándar','FontSize',14);
legend('Dispersión de particulas en eje X','Dispersión de particulas en eje Y','Location','northeast');

%% Graficacion de Evolucion de centro y dispersion de enjambre 

% Inicializacion de figura con dimensiones y render EPS adecuado
h2 = figure; clf;
set(h2,'units','points','position',[60,95,1020,420]);
set(h2,'color','w');
set(h2,'renderer','Painters');

subplot(1,2,1);
% Creacion de barras de error por cada medicion de desviacion estandar en X
xx = linspace(0, length(mean_X) - 1, length(mean_X));
f1 = fill([xx; flipud(xx)], [mean_X - sigma_X; flipud(mean_X + sigma_X)],[.2 .4 .7]);
set(f1,'EdgeColor',[.2 .4 .7]);
set(f1,'EdgeAlpha',.2);
hold on;
% Extra para lograr cambiar el color de la leyenda de dispersion en X
a1 = area([0.0001 0.0002],[0.0001 0.0002],'FaceColor',[.2 .4 .7],'FaceAlpha',.3,'EdgeAlpha',.3,'ShowBaseLine','off');
hold on;
% Graficacion de movimiento de centro de enjambre respecto al tiempo
p1 = plot(mean_X,'Color',[.2 .4 .7],'LineWidth',3);
hold on;
grid on; grid minor;
xlabel('No. de Iteraciones','FontSize',14); ylabel('Posición de enjambre en X (m)','FontSize',14);
xlim([0 data_length]);
legend([p1(1),a1(1)],'Media de coordenada X de todos los robots','Dispersión de robots sobre eje X');

subplot(1,2,2);
% Creacion de barras de error por cada medicion de desviacion estandar en Y
f2 = fill([xx; flipud(xx)], [mean_Y - sigma_Y; flipud(mean_Y + sigma_Y)],[.5 .9 .1]);
set(f2,'EdgeColor',[.5 .9 .1]);
set(f2,'EdgeAlpha',.2);
hold on;
% Extra para lograr cambiar el color de la leyenda de dispersion en Y
a2 = area([0.0001 0.0002],[0.0001 0.0002],'FaceColor',[.5 .9 .1],'FaceAlpha',.3,'EdgeAlpha',.3,'ShowBaseLine','off');
hold on;
% Graficacion de movimiento de centro de enjambre respecto al tiempo
p2 = plot(mean_Y,'Color',[.5 .9 .1],'LineWidth',3);
hold on;
grid on; grid minor;
xlabel('No. de Iteraciones','FontSize',14); ylabel('Posición de enjambre en Y (m)','FontSize',14);
xlim([0 data_length]);
legend([p2(1),a2(1)],'Media de coordenada Y de todos los robots','Dispersión de robots sobre eje Y','Location','northeast');

h10 = figure;
set(h10,'color','w');
set(h10,'units','points','position',[60,95,1020,420]);
subplot(1,3,1);
plot(BG_X,'b','Linewidth',1);
grid on; grid minor;
title('Coordenada X de GB');
subplot(1,3,2);
plot(BG_Y,'r','Linewidth',1);
grid on; grid minor;
title('Coordenada Y de GB');
subplot(1,3,3);
plot(FG,'k','Linewidth',1);
grid on; grid minor;
title('Costo de GB');