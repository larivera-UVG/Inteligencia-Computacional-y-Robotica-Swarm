%% Diseño e Innovacion de Ingenieria
% Titulo: GraphSimulation.m
% Autor: Aldo Aguilar Nadalini 15170
% Fecha: 02 de junio de 2019
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

% Elegir E-Puck a analizar (0-9)
ID = 1;
MAX_TIME = 25000;
PSO_VECT_DIV = 40; %40
EPuck = EPuck{ID};
    
headers = char(EPuck{:,1});                     % Recopilacion de headers para identificacion de tipo de datos
epuck_name = string(EPuck{1,2});                % Identificacion del E-Puck analizado
data = [EPuck{:,3},EPuck{:,4},EPuck{:,5},EPuck{:,6}];   % Datos de simulacion (Columnas 3-6)

PX = [];                                        % Datos de posicion en X de E-Puck
PY = [];                                        % Datos de posicion en Y de E-Puck
R = [];                                         % Datos de rotacion de E-Puck (restarle offset de 270° mas adelante)
V = [];                                         % Datos de velocidad lineal de E-Puck
W = [];                                         % Datos de velocidad angular de E-Puck
PHI_R = [];                                     % Datos de velocidad de motor derecho de E-Puck
PHI_L = [];                                     % Datos de velocidad de motor izquierdo de E-Puck
NEW_X = [];
NEW_Y = [];
POS_X = [];
POS_Y = [];
RHOS = [];
ALPHAS = [];
BETAS = [];
XI_X = [];
XI_Y = [];

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
        %BETAS(end + 1) = data(i,3);
        XI_X(end + 1) = data(i,3);
        XI_Y(end + 1) = data(i,4);
    end
end

Elementos = {PX PY R V W PHI_R PHI_L NEW_X NEW_Y POS_X POS_Y RHOS ALPHAS XI_X XI_Y};
Largos = zeros(1, numel(Elementos));
for i = 1:numel(Elementos)
    Largos(i) = length(Elementos{i});
end
LargoMin = min(Largos);

% Estructurar vector de tiempo para que sea datos de abscisas para graficas
% de rotacion y velocidades de E-Puck
t = 32*linspace(0,LargoMin-1,LargoMin);

plottear = 1;
if (plottear)

    % Velocidad lineal de Robot ------------------------
    h2 = figure;
    str = ['ID: E-Puck (',num2str(ID),')'];
    set(h2,'units','points','position',[60,95,620,420],'name',str,'color','w');
    ax = axes('Parent',h2,'Position',[0.064 0.099 0.902 0.864]);
    plot(t,V,'LineWidth',2,'Color',[.1 .4 .7]);
    xlim([0,MAX_TIME]);
    grid on; grid minor;
    xlabel('Tiempo (ms)','FontSize',16); ylabel('Velocidad (m/s)','FontSize',16);
    lgd = legend('Velocidad lineal de robot','Location','northeast');
    lgd.FontSize = 14;

    % Velocidad angular de Robot ------------------
    h3 = figure;
    str = ['ID: E-Puck (',num2str(ID),')'];
    set(h3,'units','points','position',[60,95,620,420],'name',str);
    set(h3,'color','w');
    ax = axes('Parent',h3,'Position',[0.064 0.099 0.902 0.864]);
    plot(t,W,'LineWidth',2,'Color',[.9 .8 .1]);
    xlim([0,MAX_TIME]);
    grid on; grid minor;
    xlabel('Tiempo (ms)','FontSize',16); ylabel('Velocidad (rad/s)','FontSize',16);
    lgd = legend('Velocidad angular de robot','Location','southeast');
    lgd.FontSize = 14;

    % Velocidades angulares de motores de Robot -------------
    h4 = figure;
    str = ['ID: E-Puck (',num2str(ID),')'];
    set(h4,'units','points','position',[60,95,620,420],'name',str);
    set(h4,'color','w');
    ax = axes('Parent',h4,'Position',[0.064 0.099 0.902 0.864]);
    plot(t,PHI_R,'LineWidth',2,'Color',[.1 .7 .3]);
    hold on;
    plot(t,PHI_L,'LineWidth',2,'Color',[.6 .1 .4]);
    hold on;
    plot([0 MAX_TIME],[6.28 6.28],'LineStyle','--','Color','k');
    hold on;
    plot([0 MAX_TIME],[-6.28 -6.28],'LineStyle','--','Color','k');
    xlim([0,MAX_TIME]);
    grid on; grid minor;
    xlabel('Tiempo (ms)','FontSize',16); ylabel('Velocidad de motor (rad/s)','FontSize',16);
    lgd = legend('Velocidad de motor derecho','Velocidad de motor izquierdo','Location','southeast');
    lgd.FontSize = 14;

    % Trayectoria con PSO -----------------
    h5 = figure;                                            % Graficacion
    str = ['ID: E-Puck (',num2str(ID),')'];
    set(h5,'units','points','position',[60,95,520,420],'name',str);
    set(h5,'color','w');
    set(h5,'renderer','Painters');
    ax = axes('Parent',h5,'Position',[0.083 0.085 0.894 0.884]);
    pt1 = plot(POS_X,POS_Y,'LineWidth',2,'Color',[.2 .5 .7]);
    hold on;
    for i = 1:size(NEW_X,2)
        if (mod(i,PSO_VECT_DIV) == 0)
            pt2 = plot([POS_X(i) NEW_X(i)],[POS_Y(i) NEW_Y(i)],'LineStyle','--','Color','k');
            sc1 = scatter([NEW_X(i)],[NEW_Y(i)],25,'r','filled');
        end
        hold on;
    end
    sc2 = scatter([0],[0],75,'k','filled');
    xlim([-1 1]); ylim([-1 1]);
    grid on; grid minor; 
    xlabel('X (m)'); ylabel('Y (m)');
    %lgd = legend([pt1(1),pt2(1),sc1(1),sc2(1)],'Trayectoria de robot','Velocidad PSO','Nueva posicion PSO','Meta','Location','northwest');
    lgd = legend([pt1(1),pt2(1),sc1(1),sc2(1)],'Robot trajectory','PSO velocity vectors','PSO Marker positions','Goal','Location','northeast');
    lgd.FontSize = 10;

    % Parametros polares ----------------------
    % h6 = figure;                                            % Graficacion
    % str = ['ID: E-Puck (',num2str(ID),')'];
    % set(h6,'units','points','position',[60,45,1020,540],'name',str);
    % set(h6,'color','w');
    % ax = axes('Parent',h6,'Position',[0.1 0.095 0.877 0.877]);
    % hold(ax,'on');
    % subplot(3,1,1);
    % plot(t,RHOS,'LineWidth',2,'Color',[.1 .4 .7]);
    % grid on; grid minor; xlim([0,MAX_TIME]); title('Distance to Goal');
    % xlabel('Time (ms)'); ylabel('Rho (mts)');
    % subplot(3,1,2);
    % plot(t,ALPHAS,'LineWidth',2,'Color',[.9 .8 .1]);
    % grid on; grid minor; xlim([0,MAX_TIME]); title('Deviation Angle');
    % yticks([-pi -pi/2 0 pi/2 pi]);
    % yticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'});
    % xlabel('Time (ms)'); ylabel('Alpha (rads)');
    % subplot(3,1,3);
    % plot(t,BETAS,'LineWidth',2,'Color',[.1 .7 .3]);
    % grid on; grid minor; xlim([0,MAX_TIME]); title('Goal Orientation');
    % xlabel('Time (ms)'); ylabel('Betas (rads)');
    % yticks([-pi -pi/2 0 pi/2 pi]);
    % yticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'});

    % Error integral de controlador LQI -------------
    h7 = figure;
    str = ['ID: E-Puck (',num2str(ID),')'];
    set(h7,'units','points','position',[60,95,620,420],'name',str);
    set(h7,'color','w');
    ax = axes('Parent',h7,'Position',[0.067 0.095 0.877 0.877]);
    plot(t,XI_X,'LineWidth',2,'Color',[.1 .2 .7]);
    hold on;
    plot(t,XI_Y,'LineWidth',2,'Color',[.6 .1 .1]);
    hold on;
    xlim([0,MAX_TIME]);
    grid on; grid minor;
    xlabel('Tiempo (ms)','FontSize',16); ylabel('Integral Error (m)','FontSize',16);
    lgd = legend('Error integral X','Error integral Y','Location','northeast');
    lgd.FontSize = 14;

end

%% Calculo de smoothness de controlador

% Parametros para calculo de suavidad de curva
n = 3;           % Cantidad de datos a ignorar para calculo para evitar inexactitud inicial de interpolacion
graph = 0;       % Graficas internas: 0 - no graficar; 1 - graficar

% Calculo de suavidad de velocidad de motor derecho
W_R = Smoothness_Calculator(PHI_R, n, graph)

% Calculo de suavidad de velocidad de motor izquierdo
W_L = Smoothness_Calculator(PHI_L, n, graph)

%% Calculo de saturacion de controlador

N = numel(PHI_R);
saturated_values = 0;
for i = 1:N
    if (abs(PHI_R(i)) >= 6.27)
        saturated_values = saturated_values + 1;
    end
end
right_saturation = saturated_values/N

N = numel(PHI_L);
saturated_values = 0;
for j = 1:N
    if (abs(PHI_L(j)) >= 6.27)
        saturated_values = saturated_values + 1;
    end
end
left_saturation = saturated_values/N

