function [ histPos, histPot ] = simulacion(gridsize,initsize,step,N,T,dt,w,alpha,beta,gamma,K,Utot)
%% Simulacion de PSO
pause(5);
t = 0; % inicialización de tiempo
% Inicialización de posición de agentes
%X = zeros(2,N);

histPos = zeros(T/dt,2,N);
histPot = zeros(T/dt,N);
artificial_best = [6;0];
% X(1,:) = 0.5*rand(1,N) - initsize/2+1;
% X(2,:) = 16*rand(1,N)-8;
X = 0.95*(initsize*rand(2,N) - initsize/2);
%  X(1,:) = X(1,:)*0.5-5;
%X(:,1)=[-9,0];
% Inicialización de velocidad de agentes
V = zeros(2,N);
V(1,:) = rand(1, N);
V(2,:) = rand(1, N)-0.5;

Pl = [X;zeros(1,N)]; %personal best position of a single particle, followed by potential

% Se grafica la posición inicial de los agentes
figure(1)
agents = scatter(X(1,:),X(2,:), 'k', 'filled');
grid minor;
xlim([-gridsize/2, gridsize/2]);
ylim([-gridsize/2, gridsize/2]);
hold on
pause(2);
Utot = Utot';
for i = 1:N
    Pl(3,i) = Utot(round((Pl(1,i)+gridsize/2).*(step/gridsize)),round((Pl(2,i)+gridsize/2).*(step/gridsize)));
end
if (1 == 1)
while(t<T-5)%%(t < T) %&& t>T-20)
    [~,pos_g] = min(Pl(3,:));
    for i = 1:N
        %mapped_pos = [round((Pl(1,i)+gridsize/2)*(step/gridsize)),round((Pl(2,i)+gridsize/2)*(step/gridsize))];
        mapped_pos = mapXtoN(Pl(1:2,i),gridsize,step);
        Pl(3,i) = Utot(mapped_pos(1),mapped_pos(2));
        [min_u,j] = min([Utot(mapped_pos(1)+1,mapped_pos(2)),Utot(mapped_pos(1)-1,mapped_pos(2)),...
            Utot(mapped_pos(1),mapped_pos(2)+1),Utot(mapped_pos(1),mapped_pos(2)-1),...
            Utot(mapped_pos(1)-1,mapped_pos(2)+1),Utot(mapped_pos(1)+1,mapped_pos(2)+1),...
            Utot(mapped_pos(1)-1,mapped_pos(2)-1),Utot(mapped_pos(1)+1,mapped_pos(2)-1)]);
        switch(j)
            case 1
                pos_l = [mapped_pos(1)+1;mapped_pos(2)];
            case 2
                pos_l = [mapped_pos(1)-1;mapped_pos(2)];
            case 3
                pos_l = [mapped_pos(1);mapped_pos(2)+1];
            case 4
                pos_l = [mapped_pos(1);mapped_pos(2)-1];
            case 5
                pos_l = [mapped_pos(1)-1;mapped_pos(2)+1];
            case 6
                pos_l = [mapped_pos(1)+1;mapped_pos(2)+1];
            case 7
                pos_l = [mapped_pos(1)-1;mapped_pos(2)-1];
            case 8
                pos_l = [mapped_pos(1)+1;mapped_pos(2)-1];
        end
        if (min_u<Pl(3,i))
            %x_loc = pos_l.*(gridsize/step)-gridsize/2;
            x_loc = mapNtoX(pos_l,gridsize,step);
            Pl(:,i) = [x_loc;min_u];
        else
            x_loc = Pl(1:2,i);
             V(:,i) = [0;0];
        end
        % actualización de velocidad (aquí se coloca el modelo)
        %V(:,i) = 0.5*sum(distancias.*mask,2);% - 0.5*(2*randn(2,1)-1);        
        V(:,i) = K*(w*V(:,i)+alpha*rand(2,1).*(x_loc-X(:,i))+...
            rand(2,1).*beta.*(Pl(1:2,pos_g)-X(:,i))+gamma*[(rand(1,1)-0.5)*1;(rand(1,1)-0.5)*1]); % actualización de velocidad (aquí se coloca el modelo)
        %V(:,i) = w*V(:,i)+alpha*rand(2,1).*(x_loc-X(:,i));
        possible_nextloc =  X(:,i) + V(:,i)*dt;
        possibleN = mapXtoN(possible_nextloc,gridsize,step);
        possible_gradient = Utot(possibleN(1),possibleN(2));
        actual_loc =  X(:,i);
        actualN = mapXtoN(actual_loc,gridsize,step);
        actual_gradient = Utot(actualN(1),actualN(2));
        if (possible_gradient>actual_gradient+100)
            V(:,i) = 0;
            %V(:,i) = -V(:,i)*200;
        end
        histPot(round(t/dt+1),i)= actual_gradient;
    end
    histPos(round(t/dt+1),:,:)= X;
    X = X + V*dt; % actualización de la posición de los agentes
    Pl(1:2,:)=X;
    % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    pause(dt);
    t = t + dt;
end
while (t>T-5 && t<T-2)
    for i = 1:N
        %mapped_pos = [round((Pl(1,i)+gridsize/2)*(step/gridsize)),round((Pl(2,i)+gridsize/2)*(step/gridsize))];
        mapped_pos = mapXtoN(Pl(1:2,i),gridsize,step);
        Pl(3,i) = Utot(mapped_pos(1),mapped_pos(2));
        [min_u,j] = min([Utot(mapped_pos(1)+1,mapped_pos(2)),Utot(mapped_pos(1)-1,mapped_pos(2)),...
            Utot(mapped_pos(1),mapped_pos(2)+1),Utot(mapped_pos(1),mapped_pos(2)-1),...
            Utot(mapped_pos(1)-1,mapped_pos(2)+1),Utot(mapped_pos(1)+1,mapped_pos(2)+1),...
            Utot(mapped_pos(1)-1,mapped_pos(2)-1),Utot(mapped_pos(1)+1,mapped_pos(2)-1)]);
        switch(j)
            case 1
                pos_l = [mapped_pos(1)+1;mapped_pos(2)];
            case 2
                pos_l = [mapped_pos(1)-1;mapped_pos(2)];
            case 3
                pos_l = [mapped_pos(1);mapped_pos(2)+1];
            case 4
                pos_l = [mapped_pos(1);mapped_pos(2)-1];
            case 5
                pos_l = [mapped_pos(1)-1;mapped_pos(2)+1];
            case 6
                pos_l = [mapped_pos(1)+1;mapped_pos(2)+1];
            case 7
                pos_l = [mapped_pos(1)-1;mapped_pos(2)-1];
            case 8
                pos_l = [mapped_pos(1)+1;mapped_pos(2)-1];
        end
        if (min_u<Pl(3,i))
            %x_loc = pos_l.*(gridsize/step)-gridsize/2;
            x_loc = mapNtoX(pos_l,gridsize,step);
            Pl(:,i) = [x_loc;min_u];
        else
            x_loc = Pl(1:2,i);
             %V(:,i) = [0;0];
        end
        if (artificial_best(1,1)>1)
           artificial_best(1,1)=artificial_best(1,1)-0.1; 
           artificial_best(2,1)=artificial_best(2,1)+0.19; 
        end
        V(:,i) = K*(w*V(:,i)+alpha*rand(2,1).*(x_loc-X(:,i))+...
            rand(2,1).*beta.*([-2;4]-X(:,i))+gamma*[(rand(1,1)-0.5)*1;(rand(1,1)-0.5)*1]); % actualización de velocidad (aquí se coloca el modelo)
        %V(:,i) = w*V(:,i)+alpha*rand(2,1).*(x_loc-X(:,i));
        possible_nextloc =  X(:,i) + V(:,i)*dt;
        possibleN = mapXtoN(possible_nextloc,gridsize,step);
        possible_gradient = Utot(possibleN(1),possibleN(2));
        actual_loc =  X(:,i);
        actualN = mapXtoN(actual_loc,gridsize,step);
        actual_gradient = Utot(actualN(1),actualN(2));
        if (possible_gradient>actual_gradient+100)
            V(:,i) = 0;
            %V(:,i) = -V(:,i)*200;
        end
        histPot(round(t/dt+1),i)= actual_gradient;
    end
    histPos(round(t/dt+1),:,:)= X;
    X = X + V*dt; % actualización de la posición de los agentes
    Pl(1:2,:)=X;
    % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    pause(dt);
    t = t + dt;
end
end
while(t<T)
    [~,pos_g] = min(Pl(3,:));
    for i = 1:N
        %mapped_pos = [round((Pl(1,i)+gridsize/2)*(step/gridsize)),round((Pl(2,i)+gridsize/2)*(step/gridsize))];
        mapped_pos = mapXtoN(Pl(1:2,i),gridsize,step);
        Pl(3,i) = Utot(mapped_pos(1),mapped_pos(2));
        [min_u,j] = min([Utot(mapped_pos(1)+1,mapped_pos(2)),Utot(mapped_pos(1)-1,mapped_pos(2)),...
            Utot(mapped_pos(1),mapped_pos(2)+1),Utot(mapped_pos(1),mapped_pos(2)-1),...
            Utot(mapped_pos(1)-1,mapped_pos(2)+1),Utot(mapped_pos(1)+1,mapped_pos(2)+1),...
            Utot(mapped_pos(1)-1,mapped_pos(2)-1),Utot(mapped_pos(1)+1,mapped_pos(2)-1)]);
        switch(j)
            case 1
                pos_l = [mapped_pos(1)+1;mapped_pos(2)];
            case 2
                pos_l = [mapped_pos(1)-1;mapped_pos(2)];
            case 3
                pos_l = [mapped_pos(1);mapped_pos(2)+1];
            case 4
                pos_l = [mapped_pos(1);mapped_pos(2)-1];
            case 5
                pos_l = [mapped_pos(1)-1;mapped_pos(2)+1];
            case 6
                pos_l = [mapped_pos(1)+1;mapped_pos(2)+1];
            case 7
                pos_l = [mapped_pos(1)-1;mapped_pos(2)-1];
            case 8
                pos_l = [mapped_pos(1)+1;mapped_pos(2)-1];
        end
        if (min_u<Pl(3,i))
            %x_loc = pos_l.*(gridsize/step)-gridsize/2;
            x_loc = mapNtoX(pos_l,gridsize,step);
            Pl(:,i) = [x_loc;min_u];
        else
            x_loc = Pl(1:2,i);
             %V(:,i) = [0;0];
        end
        % actualización de velocidad (aquí se coloca el modelo)
        %V(:,i) = 0.5*sum(distancias.*mask,2);% - 0.5*(2*randn(2,1)-1);        
        V(:,i) = K*(w*V(:,i)+alpha*rand(2,1).*(x_loc-X(:,i))+...
            rand(2,1).*beta.*(Pl(1:2,pos_g)-X(:,i))+gamma*[(rand(1,1)-0.5)*1;(rand(1,1)-0.5)*1]); % actualización de velocidad (aquí se coloca el modelo)
        %V(:,i) = w*V(:,i)+alpha*rand(2,1).*(x_loc-X(:,i));
        possible_nextloc =  X(:,i) + V(:,i)*dt;
        possibleN = mapXtoN(possible_nextloc,gridsize,step);
        possible_gradient = Utot(possibleN(1),possibleN(2));
        actual_loc =  X(:,i);
        actualN = mapXtoN(actual_loc,gridsize,step);
        actual_gradient = Utot(actualN(1),actualN(2));
        if (possible_gradient>actual_gradient+100)
            V(:,i) = 0;
            %V(:,i) = -V(:,i)*200;
        end
        histPot(round(t/dt+1),i)= actual_gradient;
    end
    histPos(round(t/dt+1),:,:)= X;
    X = X + V*dt; % actualización de la posición de los agentes
    Pl(1:2,:)=X;
    % Se actualiza la gráfica, se muestra el movimiento y se incrementa el
    % tiempo
    agents.XData = X(1,:);
    agents.YData = X(2,:);
    pause(dt);
    t = t + dt;
end

end

