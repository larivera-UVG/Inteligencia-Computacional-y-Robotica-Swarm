gridsize = 20; % tamaño del mundo
initsize = 20;
step = 150;
rounding = 0; %0, 1 o 2
N = 100; % número de agentes
dt = 0.01; % período de muestreo
T = 10; % tiempo final de simulación

zeta = 5; %Coeficiente de atraccion al goal
eta = 10; %Coeficiente de repulsion a los obstaculos
dstar = 2; %Distancia de threshold para cambiar de funcion conica

w = 1; %peso de inercia de los agentes
alpha = 400; %parametro cognitivo
beta = 50; %parametro social
gamma = 40; %Coeficiente de preservacion de diversidad

% Factor de ganancia creado para que ninguna iteracion sea invalida por
% lentitud y los parametros cumplan la misma relacion entre si
K =  0.5; 

behaviour = 0; %  1 multiplicativo, 0 aditivo
choset = 1;
showAPF = 0;
%Se elige el caso a implementar
Utot = casoC(gridsize,step,rounding,zeta,eta,dstar,choset,behaviour,showAPF);

%Se simula 
[histPos,histPot] = simulacion(gridsize,initsize,step,N,T,dt,w,alpha,beta,gamma,K,Utot);

for n = 1:N
figure(1);hold on;grid on
plot(histPos(:,1,n),histPos(:,2,n))
end
figure(5);hold on;grid on
plot(histPot(:,1:N))
title('Potencial por agente', 'Interpreter', 'latex', 'Fontsize', 14)
xlabel('iteración', 'Interpreter', 'latex', 'Fontsize', 12);
ylabel('Potencial', 'Interpreter', 'latex', 'Fontsize', 12);

