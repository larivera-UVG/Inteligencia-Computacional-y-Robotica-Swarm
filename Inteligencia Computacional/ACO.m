% IE Diseño e Innovación
% Ant Colony Optimization
% Gabriela Iriarte Colmenares
% 16009
% 5/04/2020 - 3/05/2020
% Descripción:
%% Encoding grid in a graph 
% Primero hay que hacer la lista de los nodos que vamos a utilizar. Nuestra
% base será una cuadrícula rectangular de grid_x X grid_y:
grid_x = 8;
grid_y = 8;
% Nodos es una lista de las coordenadas [x y] de todos los nodos del grafo
% que representan a la cuadrícula
nodos = nodes(grid_x,grid_y);
%% ACO init
% Hay grid_x*grid_y nodos en el grafo
% La matriz de adyacencia es una matriz cuadrada de tamaño cantidad de
% nodos que hayan en el grafo.
cant_nodos = grid_x*grid_y;
tf = 100; % número de iteraciones máx
hormigas = 50;
rho = 0.8; % rate de evaporación (puede tomar valores entre 0 y 1)
alpha = 1.3;

nodo_dest = [6 6];

epsilon = 0.1;
%% Init de la matriz TAU
% Que contiene todas las feromonas en forma de una matriz de adyacencia
% pero con "pesos"

tau = zeros(cant_nodos);
for n = 1:cant_nodos % Por cada elemento de cada columna
    v = neighbors(nodos(n,:), grid_x, grid_y); % Encontrar sus vecinos
    columnasvecinos = v(:,2);
    [~,indx] = ismember(v(any(v,2),:),nodos,'rows');
    tau(indx,n) = ones(size(indx,1),1);
end

for n = 1:cant_nodos
    tau(n,n:end) = tau(n:end,n)';
end

edges = zeros(cant_nodos*cant_nodos,5);

%%
% Init de la celda que contiene todos los vecinos y tau de los nodos
vytau = cell(cant_nodos,2);
for k=1:cant_nodos
    v = neighbors(nodos(k,:), grid_x, grid_y);
    vytau{k,1} = v; % asignamos los vecinos
    s = size(v,1);
    vytau{k,2} = rand(s,1); % asignamos la tau init de todo a rand entre 0 y 1
end
% Init de feasable nodes (vecinos posibles)
feas_nodes = cell(hormigas,cant_nodos);
for k=1:hormigas
    for n=1:cant_nodos
       feas_nodes{k,n} = vytau{n,1}; 
    end
end
% Init de feasable nodes (vecinos posibles)

% Aquí guardamos el nodo anterior del visitado por las hormigas
last_node = cell(hormigas,cant_nodos);  

% colocamos a las hormigas en el nodo actual
nodo_actual = ones(hormigas,2);
id = nodeid(nodo_actual(1,:),nodos); % Número de nodo, del nodo actual

% Init de blocked nodes (vecinos posibles)
blocked_nodes = cell(hormigas,1);

path_k = cell(hormigas,1);
%blocked_nodes = cell(hormigas,cant_nodos);

L = zeros(hormigas,tf); % Se guardan todos los largos de cada path por hormiga y por unidad de tiempo t
all_path = cell(hormigas,tf);

for k = 1:hormigas
    path_k{k,1}(1,:) =  nodo_actual(1,:);
    last_node{k,id} = [0 0];
end

next_node = zeros(1,2);
% omitir los ceros de los vectores

%% ACO loop
t = 1;
stop = 1;
figure(); clf;
%hold on
%h = scatter(edges(1,[1,3]),edges(1,[2,4]));
%h.Color=[0,0,0,1];
colores = zeros(size(G.Edges.Weight,1),3);
%axis([1 8 1 8])
while (t<=tf & stop)
    nodo_actual = ones(hormigas,2);
    blocked_nodes = cell(hormigas,1);
    for k=1:hormigas
        for n=1:cant_nodos
            feas_nodes{k,n} = vytau{n,1};
        end
    end
    for k = 1:hormigas
        fila = 2;
        flag = 0;
        while (sum(nodo_actual(k,:) ~= nodo_dest)~=0) % Mientras no se haya llegado al destino
            % Sacamos el index del nodo actual
            id = nodeid(nodo_actual(k,:),nodos);
            % Colocamos el nodo actual en la lista tabu
            blocked_nodes{k,1}(size(blocked_nodes{k,1},1)+1,:) =  nodo_actual(k,:);
            % Calculamos qué nodos sí tenemos disponibles para viajar
            [feas_nodes{k,id},blocked_nodes{k,1},flag] = tabu(feas_nodes{k,id}, blocked_nodes{k,1}, last_node{k,id});
            % La hormiga toma la decisión de a donde ir
            next_node = ant_decision(feas_nodes{k,id},tau,alpha,nodos,id);
            % Calculamos el id del siguiente nodo
            id = nodeid(next_node,nodos);
            % En la lista del siguiente nodo tenemos que guardar que el nodo
            % anterior a este fue el nodo actual
            if (flag)
                last_node{k,id} = nodo_actual(k,:);
            end
            % Nos movemos al siguiente nodo
            nodo_actual(k,:) = next_node;
            % Guardamos el path
            path_k{k,1}(fila,:) = nodo_actual(k,:);
            fila = fila + 1;
        end
        path_k{k,1} = loop_remover(path_k{k,1});
        L(k,t) = size(path_k{k,1},1)-1; % Equivale a f(x_k(t))
        all_path{k,t} = path_k{k,1};  % Equivale a x_k(t)
        

    end
    
    %% Evaporación de Feromona
    % TAU_nm en vez de TAU_ij porque están reservadas en Matlab para los números
    % complejos
    for n = 1:cant_nodos % Por cada fila
        for m = 1:cant_nodos % Por cada columna
            tau(n,m) = (1-rho)*tau(n,m);
        end
    end
    %% Update de Feromona
    for k = 1:hormigas
        dtau = 1/L(k,t);
        id_path = nodeid(all_path{k,t},nodos);
        
        for f = 1:size(id_path,1)-1
            tau(id_path(f),id_path(f+1)) = tau(id_path(f),id_path(f+1)) + dtau;
            tau(id_path(f+1),id_path(f)) = tau(id_path(f),id_path(f+1));
        end
    end
    
    if (numel(unique(L(:,t)))/hormigas < epsilon)
        stop = 0;
    end
    
%     mtau = max(max(tau));
%     cont = 1;
%     for n = 1:cant_nodos % Por cada nodo
%         for m = 1:cant_nodos
%             edges(cont,:) = [nodos(m,:) nodos(n,:) tau(m,n)/mtau];
%             temp = edges(all(edges,2),:);
%             cont = cont + 1;
%         end
%     end

%     for cont = 1:length(edges)
%         h.XData(:,[cont,cont+2]) = edges(cont,[1,3])';
%         h.YData(:,[cont,cont+2]) = edges(cont,[2,4])';
%         %h.Color(4) = edges(cont,5);
%         drawnow limitrate
%     end
%     h.XData(:,[1,2]) = edges(9,[1,3])';
%     h.YData(:,[1,2]) = edges(9,[2,4])';
%     h.Color(4) = edges(9,5);
%     drawnow limitrate
    colores(:,3) = G.Edges.Weight./max(G.Edges.Weight);
    G = graph(tau);%
    h = plot(G,'LineWidth', G.Edges.Weight, 'NodeColor', 'none','EdgeColor',colores); %'EdgeLabel',G.Edges.Weight,
    view([-90 -90])
    drawnow limitrate
    t = t + 1;
end
%% Best Path Calculation
% valor_minimo_por_columna,filas_en_donde_estan_los_min
[minval_col,fil] =  min(L(:,t-1));
best_path = all_path{fil,t-1}; % L(k,t)
%% Gráfica
figure()
scatter(nodos(:,1),nodos(:,2),'filled','k')
grid on;
hold on;
nodos_especiales = [path_k{1,1}(1,:);nodo_dest];
scatter(nodos_especiales(:,1),nodos_especiales(:,2),'r','filled')
plot(best_path(:,1),best_path(:,2),'b')


%% Pruebas
disp("Sección de pruebas")

phi = [0.9;0.6;1]; % probabilidad
nextIndx = rouletteWheel(phi);
%phi(nextIndx)
%disp(phi(ind))











