% Titulo: Box_Plotter_Paper.m
% Autor: Aldo Aguilar Nadalini 15170
% Fecha: 21 de noviembre de 2019
% Descripcion: Programa que lee data logger Smoothness_Records.xlsx y
%              grafica diagrama de caja y bigotes de suavidad de curvas de
%              datos analizadas.

%% Ejecucion

[num1,~,~] = xlsread('Smoothness_Records.xlsx');
[num2,~,~] = xlsread('Saturation_Records.xlsx');

Ws = num1(2:end,:);
Wsat = num2(2:end,:);

% Graficacion de suavidad de curvas
BC = [Ws(1,:)',Ws(2,:)',Ws(3,:)',Ws(4,:)'];

g = ["TUC","LSPC","TUC-LQR","TUC-LQI"]';
h4 = figure;
set(h4,'color','w');
set(h4,'units','points','position',[60,95,620,420]);
set(h4,'renderer','Painters');
ax = axes('Parent',h4,'Position',[0.067 0.055 0.908 0.90]);
boxplot(BC,g,'DataLim',[0 120],'ExtremeMode','clip','OutlierSize',8,'MedianStyle','line');
hold on;
h = findobj(gca,'Tag','Box');
patch(get(h(1),'XData'),get(h(1),'YData'),[.9 0 0],'FaceAlpha',.5);
patch(get(h(2),'XData'),get(h(2),'YData'),[.4 .68 .34],'FaceAlpha',.5);
patch(get(h(3),'XData'),get(h(3),'YData'),[1 .85 0],'FaceAlpha',.5);
patch(get(h(4),'XData'),get(h(4),'YData'),[.1 .1 .9],'FaceAlpha',.5);
% patch(get(h(5),'XData'),get(h(5),'YData'),[1 .5 0],'FaceAlpha',.5);
% patch(get(h(6),'XData'),get(h(6),'YData'),[0 0 1],'FaceAlpha',.5);
% patch(get(h(7),'XData'),get(h(7),'YData'),[0 .3 1],'FaceAlpha',.5);
boxplot(BC,g,'DataLim',[0 120],'ExtremeMode','clip','OutlierSize',8,'MedianStyle','line');
hold on;
set(gca,'XTickMode','auto','XTickLabel',{"TUC","LSPC","TUC-LQR","TUC-LQI"},'XTick',[1 2 3 4]);
set(gca,'TickLabelInterpreter','latex');
ylabel('Bending Energy - W','FontSize',14);

%% Saturacion

% Graficacion de suavidad de curvas
BCsat = [Wsat(1,:)',Wsat(2,:)',Wsat(3,:)',Wsat(4,:)'];

g = ["TUC","LSPC","TUC-LQR","TUC-LQI"]';
h5 = figure;
set(h5,'color','w');
set(h5,'units','points','position',[60,95,620,420]);
set(h5,'renderer','Painters');
ax = axes('Parent',h5,'Position',[0.067 0.055 0.908 0.90]);
boxplot(BCsat,g,'DataLim',[0 350],'ExtremeMode','clip','OutlierSize',8,'MedianStyle','line');
hold on;
h = findobj(gca,'Tag','Box');
patch(get(h(1),'XData'),get(h(1),'YData'),[.9 0 0],'FaceAlpha',.5);
patch(get(h(2),'XData'),get(h(2),'YData'),[.4 .68 .34],'FaceAlpha',.5);
patch(get(h(3),'XData'),get(h(3),'YData'),[1 .85 0],'FaceAlpha',.5);
patch(get(h(4),'XData'),get(h(4),'YData'),[.1 .1 .9],'FaceAlpha',.5);
% patch(get(h(5),'XData'),get(h(5),'YData'),[1 .5 0],'FaceAlpha',.5);
% patch(get(h(6),'XData'),get(h(6),'YData'),[0 0 1],'FaceAlpha',.5);
% patch(get(h(7),'XData'),get(h(7),'YData'),[0 .3 1],'FaceAlpha',.5);
boxplot(BCsat,g,'DataLim',[0 350],'ExtremeMode','clip','OutlierSize',8,'MedianStyle','line');
hold on;
set(gca,'XTickMode','auto','XTickLabel',{"TUC","LSPC","TUC-LQR","TUC-LQI"},'XTick',[1 2 3 4]);
set(gca,'TickLabelInterpreter','latex');
ylabel('Saturation Percentage','FontSize',14);
