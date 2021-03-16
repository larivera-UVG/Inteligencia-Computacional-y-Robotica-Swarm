%% Diseño e Innovacion de Ingenieria
% Titulo: GraphSimulation_Paper.m
% Autor: Aldo Aguilar Nadalini 15170
% Fecha: 17 de septiembre de 2019
% Descripcion: Programa para graficar automaticamente resultados de
%              simulaciones

%% Recoleccion de muestras

% Lectura de archivos de resultados de E-Puck (escritos por Webots)
TotalPucks = 10;
EPuck = cell(TotalPucks);

for i = 1:TotalPucks
    Filename = strcat('epuck',num2str(i-1),'.txt');
    EPuck{i} = readtable(Filename);
end

%% Separacion de datos de cada E-Puck

% Elegir E-Puck a analizar (1-10)
ID = 1;
MAX_TIME = 20000;
PSO_VECT_DIV = 25;
EPuck = EPuck{ID};
    
headers = char(EPuck{:,1});                             % Recopilacion de headers para identificacion de tipo de datos
epuck_name = string(EPuck{1,2});                        % Identificacion del E-Puck analizado
data = [EPuck{:,3},EPuck{:,4},EPuck{:,5},EPuck{:,6}];   % Datos de simulacion (Columnas 3-6)

PX = [];                                                % Datos de posicion en X de E-Puck
PY = [];                                                % Datos de posicion en Y de E-Puck
R = [];                                                 % Datos de rotacion de E-Puck (restarle offset de 270° mas adelante)
V = [];                                                 % Datos de velocidad lineal de E-Puck
W = [];                                                 % Datos de velocidad angular de E-Puck
PHI_R = [];                                             % Datos de velocidad de motor derecho de E-Puck
PHI_L = [];                                             % Datos de velocidad de motor izquierdo de E-Puck
NEW_X = [];
NEW_Y = [];
POS_X = [];
POS_Y = [];
RHOS = [];
ALPHAS = [];
BETAS = [];

% Separacion de datos segun su identificador en matriz de data
for i = 1:length(headers)
    if (headers(i) == 'P')
        PX(end + 1) = data(i,1);
        PY(end + 1) = data(i,2);
    elseif (headers(i) == 'R')
        R(end + 1) = data(i,1) - 180;           % Se le resta offset de 270° a dato
    elseif (headers(i) == 'V') 
        V(end + 1) = data(i,1);
        W(end + 1) = data(i,2);
        PHI_R(end + 1) = data(i,3);
        PHI_L(end + 1) = data(i,4);
    elseif (headers(i) == 'U')
        NEW_X(end + 1) = data(i,1);
        NEW_Y(end + 1) = data(i,2);
        POS_X(end + 1) = data(i,3);
        POS_Y(end + 1) = data(i,4);
    elseif (headers(i) == 'Z')
        RHOS(end + 1) = data(i,1);
        ALPHAS(end + 1) = data(i,2);
        BETAS(end + 1) = data(i,3);
    end
end

Elementos = {PX PY R V W PHI_R PHI_L NEW_X NEW_Y POS_X POS_Y RHOS ALPHAS BETAS};
Largos = zeros(1, numel(Elementos));
for i = 1:numel(Elementos)
    Largos(i) = length(Elementos{i});
end
LargoMin = min(Largos);

% Estructurar vector de tiempo para que sea datos de abscisas para graficas
% de rotacion y velocidades de E-Puck
t = 32*linspace(0,LargoMin-1,LargoMin);

%% Velocidad lineal de Robot ------------------------
h2 = figure;
str = ['ID: E-Puck (',num2str(ID),')'];
set(h2,'units','points','position',[60,95,620,420],'name',str);
set(h2,'color','w');
plot(t,V,'LineWidth',2,'Color',[.1 .4 .7]);
xlim([0,MAX_TIME]);
grid on; grid minor;
xlabel('Tiempo (ms)','FontSize',16); ylabel('Velocidad (m/s)','FontSize',16);
lgd = legend('Velocidad lineal de robot','Location','northeast');
lgd.FontSize = 14;

%% Velocidad angular de Robot ------------------
h3 = figure;
str = ['ID: E-Puck (',num2str(ID),')'];
set(h3,'units','points','position',[60,95,620,420],'name',str);
set(h3,'color','w');
plot(t,W,'LineWidth',2,'Color',[.9 .8 .1]);
xlim([0,MAX_TIME]);
grid on; grid minor;
xlabel('Tiempo (ms)','FontSize',16); ylabel('Velocidad (rad/s)','FontSize',16);
lgd = legend('Velocidad angular de robot','Location','northeast');
lgd.FontSize = 14;

%% Velocidades angulares de Robot -------------
h4 = figure;
str = ['ID: E-Puck (',num2str(ID),')'];
set(h4,'units','points','position',[60,95,620,420],'name',str);
set(h4,'color','w');
ax = axes('Parent',h4,'Position',[0.0623716632443532 0.105031948881789 0.907765757474463 0.870952303086714]);
hold(ax,'on');
plot(t,PHI_R,'LineWidth',2,'Color',[.1 .7 .3]);
hold on;
plot(t,PHI_L,'LineWidth',2,'Color',[.6 .1 .4]);
hold on;
plot([0 MAX_TIME],[6.28 6.28],'LineStyle','--','Color','k');
hold on;
plot([0 MAX_TIME],[-6.28 -6.28],'LineStyle','--','Color','k');
xlim([0,MAX_TIME]);
grid on; grid minor;
xlabel('Time (ms)','FontSize',16); ylabel('Velocity (rad/s)','FontSize',16);
lgd = legend('Right E-Puck motor velocity','Left E-Puck motor velocity','Location','northeast');
lgd.FontSize = 14;
box(ax,'on');
grid(ax,'on');
set(ax,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on');
set(lgd,'Position',[0.0672128188013608 0.112952606873517 0.366543347512945 0.104832270655769],'FontSize',14);

%% Trayectoria con PSO -----------------
h2 = figure;                                            % Graficacion
str = ['ID: E-Puck (',num2str(ID),')'];
set(h2,'units','points','position',[60,95,520,420],'name',str);
plot(POS_X,POS_Y,'LineWidth',2,'Color',[.2 .5 .7]);
hold on;
for i = 1:size(NEW_X,2)
    if (mod(i,PSO_VECT_DIV) == 0)
        plot([POS_X(i) NEW_X(i)],[POS_Y(i) NEW_Y(i)],'LineStyle','--','Color','k');
    end
    hold on;
end
scatter([0],[0],50,'k','filled');
xlim([-1 1]); ylim([-1 1]);
grid on; grid minor; %title('E-Puck PSO Position');
xlabel('X (m)'); ylabel('Y (m)');
set(h2,'color','w');

% -------------------------------------------------------------------------
clear; clc;
