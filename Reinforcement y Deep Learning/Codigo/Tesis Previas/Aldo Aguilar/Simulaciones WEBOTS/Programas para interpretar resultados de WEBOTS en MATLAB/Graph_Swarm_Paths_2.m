%% Diseño e Innovacion de Ingenieria
% Titulo: TrajectoryGraph_Paper.m
% Autor: Aldo Aguilar Nadalini 15170
% Fecha: 17 de septiembre de 2019
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
MAX_TIME = 17000;
PSO_VECT_DIV = 20;
use_keane = 0;

% Trayectoria de robot ------------------------
h0 = figure;
str = ['ID: E-Puck (',num2str(ID),')'];
set(h0,'units','points','position',[60,95,420,420],'name',str);
set(h0,'color','w');
ax = axes('Parent',h0,'Position',[0.1 0.095 0.877 0.877]);

if (use_keane == 1)
    f = @(x,y) -(sin((2*x) - y)^2 * sin((2*x) + y)^2)/(sqrt((2*x)^2 + y^2));
    fcontour(f,'LevelStep',0.05);
    hold on;
end

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

% Separacion de datos segun su identificador en matriz de data
for i = 1:length(headers)
    if (headers(i) == 'P')
        PX(end + 1) = data(i,1);
        PY(end + 1) = data(i,2);
    elseif (headers(i) == 'R')
        R(end + 1) = data(i,1) - 180;           % Se le resta offset de 270° a dato
    end
end

% Plottear trayectoria
plot(PX,PY,'LineWidth',2,'Color',[.2 .5 .7]);
hold on;
scatter(PX(1),PY(1),100,'r','LineWidth',2);

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
grid on; grid minor;
xlabel('X (m)','FontSize',14); ylabel('Y (m)','FontSize',14);
if (use_keane == 1)
    legend('Keane Function','E-Puck trajectories','E-Puck start locations');
    set(legend,'Position',[0.112839502234518 0.836828337462794 0.424814822691458 0.103509465978725],'FontSize',14);
else
    legend('E-Puck trajectories','E-Puck start locations');
    set(legend,'Position',[0.112839502234518 0.856828337462794 0.424814822691458 0.103509465978725],'FontSize',14);
end
box(ax,'on');
grid(ax,'on');
set(ax,'FontSize',12,'XMinorGrid','on','YMinorGrid','on','XTick',[-1 -0.5 0 0.5 1],'YTick',[-1 -0.5 0 0.5 1],'ZMinorGrid','on');
