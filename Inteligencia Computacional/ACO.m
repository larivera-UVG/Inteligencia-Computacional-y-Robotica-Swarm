% IE Diseño e Innovación
% Ant Colony Optimization
% Gabriela Iriarte Colmenares
% 16009
% 5/04/2020
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
tf = 1;
hormigas = 2;
nodo_actual = ones(hormigas,2);
nodo_dest = [4 2];
path_k = cell(hormigas,1);
blocked_nodes = cell(hormigas,cant_nodos);
alpha = 1;
L = zeros(hormigas,tf);
all_path = cell(hormigas,tf);
%% Init de la matriz TAU

tau = zeros(cant_nodos);
for n = 1:cant_nodos % Por cada columna
    v = neighbors(nodos(n,:), grid_x, grid_y);
    columnasvecinos = v(:,2);
    [~,indx] = ismember(v(any(v,2),:),nodos,'rows');
    tau(indx,n) = rand(size(indx,1),1);
end

for n = 1:cant_nodos
    tau(n,n:end) = tau(n:end,n)';
end

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
last_node = cell(hormigas,cant_nodos);
id = nodeid(nodo_actual(1,:),nodos);


% Init de blocked nodes (vecinos posibles)
blocked_nodes = cell(hormigas,1);

% FOR todos los k
for k = 1:hormigas
    path_k{k,1}(1,:) =  nodo_actual(1,:);
    last_node{k,id} = [0 0];
end

next_node = zeros(1,2);
% omitir los ceros de los vectores

%% ACO loop
t = 1;
for k = 1:hormigas
    fila = 2;
    flagc = 0;
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
    L(k,t) = size(path_k{k,1},1);
    all_path{k,t} = path_k{k,1};
    
end

%% Evaporación de Feromona


%% Gráfica
figure()
scatter(nodos(:,1),nodos(:,2),'filled','k')
grid on;
hold on;
nodos_especiales = [path_k{1,1}(1,:);nodo_dest];
scatter(nodos_especiales(:,1),nodos_especiales(:,2),'r','filled')
plot(path_k{1,1}(:,1),path_k{1,1}(:,2),'r')
figure()
scatter(nodos(:,1),nodos(:,2),'filled','k')
grid on;
hold on;
nodos_especiales = [path_k{1,1}(1,:);nodo_dest];
scatter(nodos_especiales(:,1),nodos_especiales(:,2),'r','filled')
plot(path_k{2,1}(:,1),path_k{2,1}(:,2),'b')


%% Pruebas
disp("Sección de pruebas")

