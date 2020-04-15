function [Utot] = casoC(gridsize,step,rounding,zeta,eta,dstar,choset,behaviour,showAPF)
%% Caso a resolver C
c_g = 500;
l_g = 3;
c_o = 500;
l_o = 0.2;
%Inicializacion de bordes de robotat
xw = [-gridsize/2;-gridsize/2;gridsize/2;gridsize/2;-gridsize/2];
yw = [-gridsize/2;gridsize/2;gridsize/2;-gridsize/2;-gridsize/2];
figure(1);hold on
plot(xw,yw,'r');
% Inicializacion de obstaculo grande
xrep = [-6;-6;-5;-5;-6; NaN;-6;-6;-5;-5;-6;NaN;-1;-1;0;0;-1];
yrep = [-5;-4;-4;-5;-5; NaN;5;4;4;5;5;NaN;-1;0;0;-1;-1];
plot(xrep,yrep,'r');
%plot(Xrep(in),Yrep(in),'b+') % points inside
%plot(Xrep(~in),Yrep(~in),'ro') % points outside

% Definicion de APF (Choset, 2005)
Qi = 5; %Threshold para ignorar obstaculos lejanos

% Definir los puntos del workspace
x = linspace(-gridsize/2,gridsize/2,step);
y = linspace(-gridsize/2,gridsize/2,step);

%Se realiza un grid de las coordenadas a evaluar en el campo de potencial
[Xrep,Yrep] = meshgrid(x,y);

%Se definen los puntos dentro y en el borde del obstaculo
[in,on]= inpolygon(round(Xrep,rounding),round(Yrep,rounding),xrep,yrep);
[inw,onw]= inpolygon(round(Xrep,rounding),round(Yrep,rounding),xw,yw);

on_total = on | onw;
%Se identifican en un grid los puntos sobre el borde del obstaculo
edges = [Xrep(on),Yrep(on)];
edgesw = [Xrep(onw),Yrep(onw)];
%plot(Xrep(on),Yrep(on),'bo')


%Se identifican en el grid de puntos reales los que no son obstaculo
X1 = Xrep.*(~in);
Y1 = Yrep.*(~in);

%Se obtiene la distancia minima de cada punto hasta el obstaculo 1
diX = zeros(size(X1));
diY = zeros(size(Y1));
% for i = 1:size(X1,1)
%     diX(:,i) = repmat(min(abs(repmat(Xrep(1,i), size(edges,1),1)-edges(:,1))),size(X1,1),1);
%     diY(i,:) = repmat(min(abs(repmat(Yrep(i,1), size(edges,1),1)-edges(:,2))),1,size(Y1,2));
% end

% Intentar usar reshape para optimizar
for j = 1:size(X1,1)
    for k = 1:size(X1,2)
        diq(j,k) = min(((repmat(Xrep(j,k),size(edges,1),1)-edges(:,1)).^2+(repmat(Yrep(j,k),size(edges,1),1)-edges(:,2)).^2).^(1/2));
    end
end

%Se calcular la distancia euclediana de todos los puntos al obstaculo
%diq = ((diX.^2)+(diY.^2)).^(1/2).*~in;
% Se da un valor 0.01 a los puntos que son obstaculo 
diq = diq + in*0.1;
% Se discriminan los puntos que son muy lejanos al obstaculo
maskLejano = (diq < Qi);


%Se obtiene la distancia minima de cada punto hasta los bordes
Xw = Xrep.*(~onw);
Yw = Yrep.*(~onw);
diXw = zeros(size(Xw));
diYw = zeros(size(Yw));
for i = 1:size(Xw,1)
    diXw(:,i) = repmat(min(abs(repmat(Xw(1,i), size(edgesw,1),1)-edgesw(:,1))),size(Xw,1),1);
    diYw(i,:) = repmat(min(abs(repmat(Yw(i,1), size(edgesw,1),1)-edgesw(:,2))),1,size(Yw,2));
end

%Se calcular la distancia euclediana de todos los puntos al obstaculo
diqw = ((diXw.^2)+(diYw.^2)).^(1/2).*onw;
% Se da un valor -0.01 a los puntos que son obstaculo 
diqw = diqw + ~onw*0.1;
% Se discriminan los puntos que son muy lejanos al obstaculo
maskLejanow = (diqw < Qi);

%Se obtiene la funcion de potencial para todos los puntos
if(choset == 1)
Urepw = 0.5*eta*(1./diqw-1/Qi).^2.*maskLejanow;
Urep = 0.5*eta*(1./diq-1/Qi).^2.*maskLejano;
else
Urepw = c_o*exp(-(diqw.^2)/l_o^2);
Urep = c_o*exp(-(diq.^2)/l_o^2);    
end

% Se obtiene la funcion de atraccion para una meta
Xgoal = [-4;0];
scatter(Xgoal(1),Xgoal(2),'go','filled')
if (choset ==1)
dq = ((Xrep-Xgoal(1)).^2+(Xrep-Xgoal(2)).^2).^(1/2);
maskGoal = (dq <= dstar);
Uatt1a = 0.5*zeta*((Xrep-Xgoal(1)).^2+(Yrep-Xgoal(2)).^2);
Uatt1b = dstar*zeta*((Xrep-Xgoal(1)).^2+(Yrep-Xgoal(2)).^2).^(1/2)-0.5*zeta*dstar^2;
Uatt1 = Uatt1a.*maskGoal + Uatt1b.*~maskGoal;
else
Uatt1 = c_g*(1-exp(-((Xrep-Xgoal(1)).^2+(Yrep-Xgoal(2)).^2)/l_g^2));    
end

%% Se obtiene el comportamiento deseado de la funcion
if (behaviour == 1)
    Utot = (Urep+Urepw)/c_g.*Uatt1+Uatt1;
    if (choset == 1)
        Utot = (Urep+Urepw).*Uatt1+Uatt1;
    end
else
    Utot = (Urep+Urepw)+Uatt1;
end
title('Caso C', 'Interpreter', 'latex', 'Fontsize', 16)
pause(5);
figure(1);hold on
contour(x,y,Utot);

if (showAPF==1)
    figure(2);clc;
    surf(x,y,Utot);
    title('APF Resultante', 'Interpreter', 'latex', 'Fontsize', 16)
    figure(3)
    surf(x,y,Uatt1);
    title('APF de Atraccion', 'Interpreter', 'latex', 'Fontsize', 16)
    figure(4);clc;
    surf(x,y,Urep+Urepw); 
    title('APF de Repulsion', 'Interpreter', 'latex', 'Fontsize', 16)
end

end

