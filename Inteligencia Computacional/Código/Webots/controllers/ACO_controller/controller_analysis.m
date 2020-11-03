% Código basado en el de Aldo, pues se quería comparar sus gráficas del PSO
% con las gráficas del ACO.

load('analysis.mat')
t = 32*linspace(0, length(v_hist)-1, length(v_hist));

% Velocidad lineal de Robot ------------------------
h2 = figure(1);
ID = 1;
str = 'Velocidad lineal';
set(h2,'units','points','position',[60,95,620,420],'name',str);
set(h2,'color','w');
plot(t, v_hist, 'LineWidth', 2, 'Color', [.1 .4 .7]);
xlim([0, t(end)]);
grid on; grid minor;
xlabel('Tiempo (ms)', 'FontSize', 16); ylabel('Velocidad (m/s)', 'FontSize', 16);
lgd = legend('Velocidad lineal de robot', 'Location', 'best');
lgd.FontSize = 14;

%% Velocidad angular de Robot ------------------
h3 = figure(2);
str = 'Velocidad lineal';
set(h3, 'units', 'points', 'position', [60,95,620,420], 'name', str);
set(h3, 'color', 'w');
plot(t, w_hist, 'LineWidth', 2, 'Color', [.9 .8 .1]);
xlim([0, t(end)]);
grid on; grid minor;
xlabel('Tiempo (ms)','FontSize',16); ylabel('Velocidad (rad/s)','FontSize',16);
lgd = legend('Velocidad angular de robot','Location','best');
lgd.FontSize = 14;

%% Velocidades angulares de Robot -------------
h4 = figure(3);
str = 'Velocidad lineal';
set(h4,'units','points','position',[60,95,620,420],'name',str);
set(h4,'color','w');
ax = axes('Parent',h4,'Position',[0.0623716632443532 0.105031948881789 0.907765757474463 0.870952303086714]);
hold(ax,'on');
plot(t, rwheel_hist,'LineWidth',2,'Color',[.1 .7 .3]);
hold on;
plot(t, lwheel_hist,'LineWidth',2,'Color',[.6 .1 .4]);
hold on;
plot([0 t(end)],[6.28 6.28],'LineStyle','--','Color','k');
hold on;
plot([0 t(end)],[-6.28 -6.28],'LineStyle','--','Color','k');
xlim([0,t(end)]);
grid on; grid minor;
xlabel('Time (ms)','FontSize',16); ylabel('Velocity (rad/s)','FontSize',16);
lgd = legend('Right E-Puck motor velocity','Left E-Puck motor velocity','Location','best');
lgd.FontSize = 14;
box(ax,'on');
grid(ax,'on');
set(ax,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on');
% set(lgd,'Position',[0.0672128188013608 0.112952606873517 0.366543347512945 0.104832270655769],'FontSize',14);

%% Trayectoria con PSO -----------------
h5 = figure(4);
str = 'Velocidad lineal';
set(h5,'units','points','position',[60,95,520,420],'name',str);
plot(trajectory(:, 1), trajectory(:, 2), 'LineWidth', 2, 'Color', [.2 .5 .7]);
view(0, -90);
hold on;
scatter(goal(1), goal(2), 50, 'k', 'filled');
xlim([-1 1]); ylim([-1 1]);
grid on; 
grid minor;
xlabel('X (m)'); ylabel('Y (m)');
set(h5, 'color', 'w');

%% Guardando las plots

saveas(h2, ['c',num2str(controlador),'_v.png'])
saveas(h3, ['c',num2str(controlador),'_w.png']) 
saveas(h4, ['c',num2str(controlador),'_lr.png'])
saveas(h5, ['c',num2str(controlador),'_pos.png'])








