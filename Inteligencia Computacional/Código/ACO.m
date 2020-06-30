% IE Diseño e Innovación
% Ant Colony Optimization - Ant System
% Gabriela Iriarte Colmenares
% 16009
% 5/04/2020 - 28/06/2020
% Descripción: Código y simulación simple de un Ant System. Se recomienda 
% primero leer el algoritmo 17.3 del libro Computational Intelligence
%% Detectar funciones lentas
%profile on

%% Encoding grid in a graph 
% Primero hay que hacer la lista de los nodos que vamos a utilizar. Nuestra
% base será una cuadrícula rectangular de grid_x X grid_y:
tic % Para medir el tiempo que se tarda el algoritmo en correr.
grid_x = 10;
grid_y = 10;
% Nodos es una lista de las coordenadas [x y] de todos los nodos del grafo
% que representan a la cuadrícula
nodos = nodes(grid_x,grid_y);

%% ACO init
% Inicializamos los parámetros del Ant System:
% Hay grid_x*grid_y nodos en el grafo
cant_nodos = grid_x*grid_y;
tf = 70; % número de iteraciones máx
hormigas = 50; % Cantidad de hormigas
rho = 0.5; % rate de evaporación (puede tomar valores entre 0 y 1)
alpha = 1; % Le da más peso a la feromona en la probabilidad
beta = 1; % Le da más peso al costo del link en la probabilidad
Q = 1; % cte. positiva que regula el depósito de feromona
nodo_dest = '56'; % Nodo destino
epsilon = 0.9; % Porcentaje de hormigas siguiendo la misma solución

%% Init de la matriz TAU
% Que contiene todas las feromonas en forma de una matriz de adyacencia
% pero con "pesos"
% La matriz de adyacencia es una matriz cuadrada de tamaño cantidad de
% nodos que hallan en el grafo.

cost_diag = 0.5; % Costo por distancia de las diagonales
tau = zeros(cant_nodos); % Matriz de adyacencia con pesos (costos de feromona)
eta = ones(cant_nodos); % Eta inicial (1/d) (costo por distancia)
tau_0 = 0.1; % Valor de tau inicial

% Init de la celda que contiene todos los vecinos y tau de los nodos
vytau = cell(cant_nodos,2);

for n = 1:cant_nodos % Por cada elemento de cada columna
    % Encontrarle los vecinos a cada nodo
    v = neighbors(nodos(n,:), grid_x, grid_y); % Encontrar sus vecinos
    vytau{n,1} = v;
    s = size(v,1);
    vytau{n,2} = tau_0;
    diagonal = repmat(nodos(n,:),[4 1])+[1 1;-1 1;-1 -1;1 -1];
    % Probar si es vecino diagonal para ponerle un costo diferente en eta
    [~,indxdiag] = ismember(diagonal,v,'rows'); 
    nod_diag = v(indxdiag(any(indxdiag,2),:),:);
    [~,indxdiag2] = ismember(nod_diag,nodos,'rows');
    eta(indxdiag2,n) = 1/cost_diag; % Parametrizamos el costo de las diagonales
    columnasvecinos = v(:,2);
    [~,indx] = ismember(v(any(v,2),:),nodos,'rows');
    
    
    tau(indx,n) = ones(size(indx,1),1)*tau_0; % init con valores pequeños! si
    % no no funciona correctamente el algoritmo
    % Se hace en un for y no desde el principio porque no todos los nodos
    % son vecinos.
end


nodo_actual = ones(hormigas, 2);

path_k = cell(hormigas, 1);

L = zeros(hormigas, tf); % Se guardan todos los largos de cada path por hormiga y por unidad de tiempo t
all_path = cell(hormigas, tf);

Name = string((1:n)');
ants(1:hormigas) = struct('blocked_nodes',[],'last_node',"1",'current_node',"1",'path',"1");
for k = 1:hormigas
    path_k{k, 1}(1, :) =  nodo_actual(1, :);
end

%next_node = zeros(1, 2);

G = graph(tau, table(Name, nodos));


%% ACO loop
t = 1;
stop = 1;
figure(); clf;

while (t<=tf && stop)
    
    % Por cada hormiga
    parfor k = 1:hormigas
        fila = 2;
        flag = 0;
        while (not(strcmp(ants(k).current_node,nodo_dest))) % Mientras no se haya llegado al destino

            ants(k).blocked_nodes = [ants(k).blocked_nodes; convertCharsToStrings(ants(k).current_node)];

            vecinos = setdiff(convertCharsToStrings(neighbors(G,ants(k).current_node)),...
                ants(k).blocked_nodes, 'rows','stable'); 
         
            while (isempty(vecinos))
                ants(k).path = ants(k).path(1:end-1);
                ants(k).current_node = ants(k).path(end);
                vecinos = setdiff(convertCharsToStrings(neighbors(G,ants(k).current_node)),...
                    ants(k).blocked_nodes, 'rows','stable');
            end
            vecinos_updated = vecinos;

            % La hormiga toma la decisión de a donde ir eq.(17.6)
            next_node = ant_decision(vecinos_updated, alpha, eta, beta, G, ants(k).current_node);
            ants(k).last_node = [ants(k).last_node; ants(k).current_node];
            
            % Nos movemos al siguiente nodo
            ants(k).current_node = next_node;
            % Guardamos el path
            path_k{k,1}(fila,:) = G.Nodes.nodos(str2double(ants(k).current_node), :);
            ants(k).path = [ants(k).path; ants(k).current_node];
            fila = fila + 1;
        end
        
        % Le quitamos los loops al path y ahora los índices son números y
        % no strings.
        
        ants(k).path = loop_remover(str2double(ants(k).path));
        path_k{k,1} = loop_remover(path_k{k,1}); % Quitamos los loops del path
        
        id_path = nodeid(path_k{k,1}, nodos); % ID de todos los nodos en la solución parcial
        
        for f = 1:size(id_path, 1)-1
            L(k,t) = L(k,t) + 1/eta(id_path(f), id_path(f+1));
        end
        
        %L(k,t) = size(path_k{k,1},1)-1; % Equivale a f(x_k(t))
        all_path{k, t} = path_k{k, 1};  % Equivale a x_k(t)
        
        % Regresamos la hormiga k al inicio
        ants(k).current_node = '1'; 
        ants(k).blocked_nodes = [];
        ants(k).last_node = '1';

    end
    
    %% Evaporación de Feromona
    G.Edges.Weight = G.Edges.Weight * (1-rho);
    
    %% Update de Feromona
    for k = 1:hormigas
        dtau = Q/numel(ants(k).path);
        edge_index = findedge(G,ants(k).path(1:end - 1), ants(k).path(2:end));
        G.Edges.Weight(edge_index) = G.Edges.Weight(edge_index) + dtau;
        ants(k).path = "1";  % Borramos el path de la hormiga k
    end
    
    [~,F] = mode(L(:,t));
    
    if (F/hormigas >= epsilon) % condición de paro
        stop = 0;
    end
    
    G.Edges.NormWeight = G.Edges.Weight/sum(G.Edges.Weight);
    h = plot(G,'XData',G.Nodes.nodos(:, 1),'YData',G.Nodes.nodos(:, 2),'LineWidth', G.Edges.NormWeight); %'EdgeLabel',G.Edges.Weight,, 'NodeColor', 'none','EdgeColor',colores
    drawnow limitrate
    t = t + 1;
end
%% Best Path Calculation
% valor_minimo_por_columna,filas_en_donde_estan_los_min
%L(:,t-1);

if (t>=tf)
    disp("No hubo convergencia")
else
    % Con la MODA
    moda =  mode(L(:, t-1));
    khor = L(:, t-1).*(L(:,t-1) == moda);
    %khor = (1:hormigas)'.*(L(:,t-1)==moda);
    %khor(any(khor,2))
    nin = rouletteWheel(khor); % Se puede porque ignora a los número 0 (probabilidad nula)
    best_path = path_k{nin, 1}; % L(k,t)
    
    % Con el MIN
%     [minval_col,fil] =  min(L(:,t-1));
%     best_path = all_path{fil,t-1}; % L(k,t)
    %% Gráfica
    figure()
    scatter(nodos(:,1), nodos(:,2), 'filled', 'k')
    grid on;
    hold on; 
    nodos_especiales = [path_k{1,1}(1,:); [8 8]];
    scatter(nodos_especiales(:,1), nodos_especiales(:,2), 'r','filled')
    plot(best_path(:,1), best_path(:,2),'b')
end

%profile viewer
tiempofinal = toc;
%% Pruebas
%disp("Sección de pruebas")

%phi = [0.9;0.6;1]; % probabilidad
%nextIndx = rouletteWheel(phi);
%phi(nextIndx)
%disp(phi(ind))











