% IE Diseño e Innovación
% Ant Colony Optimization - Ant System
% Gabriela Iriarte Colmenares
% 16009
% 5/04/2020 - 1/07/2020
% Descripción: Código y simulación simple de un Ant System. Se recomienda 
% primero leer el algoritmo 17.3 del libro Computational Intelligence


%% Detectar funciones lentas
% profile on
tic  % Para medir el tiempo que se tarda el algoritmo en correr.

%% Graph generation
graph_type = "visibility";

if strcmp(graph_type, "grid")
    % Creamos grid cuadrado con la cantidad de nodos indicada:
    grid_size = 10;
    cost_diag = 0.5;
    tau_0 = 0.1;  % Valor de tau inicial
    G = graph_grid(grid_size);
    nodo_dest = '56';
    nodo_init = "1";
elseif strcmp(graph_type, "visibility")
    load('vis_graph.mat')
    G = grafo2;
    nodo_dest = string(size(grafo2.Nodes, 1));
    nodo_init = string(size(grafo2.Nodes, 1)-1);
end


%% ACO init
t_max = 70; 
hormigas = 50;

% Rate de evaporación (puede tomar valores entre 0 y 1)
rho = 0.5; 
% Le da más peso a la feromona en la probabilidad
alpha = 1;
% Le da más peso al costo del link en la probabilidad
beta = 1;
% cte. positiva que regula el depósito de feromona
Q = 2; 
% Porcentaje de hormigas que queremos siguiendo la misma solución
epsilon = 0.9; 



% Preallocation
path_k = cell(hormigas, 1);
L = zeros(hormigas, t_max); % Lenght del path por hormiga e iteración
all_path = cell(hormigas, t_max);
ants(1:hormigas) = struct('blocked_nodes', [], 'last_node', nodo_init, 'current_node', nodo_init, 'path', nodo_init, 'L', zeros(1, t_max));


%% ACO loop
t = 1;
stop = 1;
figure(); clf;
% Gradient Color para la animación
map = [255 255 255
    245 215 250
    255 166 216
    255 111 150
    255 61 61]/255;
colormap(map);
h = plot(G, 'XData', G.Nodes.X, 'YData', G.Nodes.Y, 'NodeColor', 'k');

while (t <= t_max && stop)
    
    parfor k = 1:hormigas
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
            next_node = ant_decision(vecinos_updated, alpha, beta, G, ants(k).current_node);
            ants(k).last_node = [ants(k).last_node; ants(k).current_node];
            ants(k).current_node = next_node;
            ants(k).path = [ants(k).path; ants(k).current_node];
        end
        
        % Le quitamos los loops al path y ahora los índices son números y
        % no strings.
        
        ants(k).path = loop_remover(str2double(ants(k).path));
        L(k,t) = sum(G.Edges.Eta(findedge(G, ants(k).path(1:end-1), ants(k).path(2:end))).^-1);
        all_path{k, t} = ants(k).path;  % Equivale a x_k(t)
        
        % Regresamos la hormiga k al inicio
        ants(k).current_node = nodo_init;
        ants(k).blocked_nodes = [];
        ants(k).last_node = nodo_init;
        
    end
    
    %% Evaporación de Feromona
    G.Edges.Weight = G.Edges.Weight * (1-rho);
    
    %% Update de Feromona
    for k = 1:hormigas
        dtau = Q/numel(ants(k).path);
        edge_index = findedge(G, ants(k).path(1:end - 1), ants(k).path(2:end));
        G.Edges.Weight(edge_index) = G.Edges.Weight(edge_index) + dtau;
        ants(k).path = nodo_init;  % Borramos el path de la hormiga k
    end
    
    [~,F] = mode(L(:,t));
    
    if (F/hormigas >= epsilon) % condición de paro
        stop = 0;
    end
    
    % Animación
    G.Edges.NormWeight = G.Edges.Weight/sum(G.Edges.Weight);
    h.LineWidth = G.Edges.NormWeight * 50;
    h.EdgeCData = G.Edges.NormWeight;
    drawnow limitrate
    t = t + 1;
    
    
end
%% Best Path Calculation

if (t > t_max)
    disp("No hubo convergencia")
else
    
    % Con la MODA vemos qué largo es el que más se repite
    moda =  mode(L(:, t-1));
    % Tomamos los index de todos los largos que son iguales a la moda (en
    % la última iteración)
    len_indx = L(:, t-1).*(L(:,t-1) == moda);
    % Tomamos probabilidad random de qué camino tomar (si hubiese varios
    % casos con el mismo largo pero ruta diferente). Esta función nos
    % devuelve el index (la hormiga) que produjo el best path
    len_prob = rouletteWheel(len_indx);
    best_path = all_path{len_prob, t-1};
    
    % Gráfica
    hold on;
    nodos_especiales = [G.Nodes.X(str2double(nodo_init)), G.Nodes.Y(str2double(nodo_init)); G.Nodes.X(str2double(nodo_dest)), G.Nodes.Y(str2double(nodo_dest))];
    scatter(nodos_especiales(:,1), nodos_especiales(:,2), 'r','filled')
    plot(G.Nodes.X(best_path), G.Nodes.Y(best_path),'r')

end

% profile viewer
tiempofinal = toc;

