% IE Diseño e Innovación 1
% Ant Colony Optimization - Ant System
% Gabriela Iriarte Colmenares
% 16009
% 5/04/2020 - 12/07/2020
% Descripción: Código y simulación simple de un Ant System. Se recomienda 
% primero leer el algoritmo 17.3 del libro Computational Intelligence

%% Detectar funciones lentas
% profile on % El profiler se utiliza para detectar funciones lentas
% Para que funcione hay que descomentarlo y descomentar el profile viewer
% de abajo (casi al final del código)
tic  % Para medir el tiempo que se tarda el algoritmo en correr.

%% Graph generation
% Se elige el tipo de grafo que se va a utilizar
graph_type = "rrt";

if strcmp(graph_type, "grid")
    % Creamos grid cuadrado con la cantidad de nodos indicada:
    grid_size = 10;
    cost_diag = 0.5;
    tau_0 = 0.1;  % Valor de tau inicial
    G = graph_grid(grid_size);
    nodo_dest = '56';
    nodo_init = "1";
    plot_obstacles = 0;
elseif strcmp(graph_type, "visibility")
    % Para cambiar de grafo hay que crear uno con la app
    load('vis_graph.mat')
    G = grafo2;
    nodo_dest = string(size(grafo2.Nodes, 1));
    nodo_init = string(size(grafo2.Nodes, 1)-1);
    plot_obstacles = 1;
    axis([1 obstacles(end-3, 1) 1 obstacles(end-3, 1)])
elseif strcmp(graph_type, "prm")
    % Para utilizar esta función instalar el toolbox
    % de robótica de Peter Corke
    % Está pensado para PRM sin obstáculos
    grid_size = 10;
    load('prm_test_graph'); % prm_generator(grid_size, 50);
    nodo_dest = '5';
    nodo_init = "27";
    plot_obstacles = 0;
elseif strcmp(graph_type, "rrt")
    % Para utilizar esta función instalar el toolbox
    % de robótica de Peter Corke
    % Está pensado para RRT sin obstáculos
    grid_size = 10;
    load('rrt_test_graph');
    % save('rrt_test_graph', 'G')
    % G = rrt_generator(grid_size);
    nodo_dest = '360';
    nodo_init = "445";
    plot_obstacles = 0;
end

%% ACO init
t_max = 150; 
hormigas = 60;

% Rate de evaporación (puede tomar valores entre 0 y 1)
rho = 0.6; 
% Le da más peso a la feromona en la probabilidad
alpha = 1;
% Le da más peso al costo del link en la probabilidad
beta = 1;
% cte. positiva que regula el depósito de feromona
Q = 2.1; 
% Porcentaje de hormigas que queremos siguiendo la misma solución
epsilon = 0.9; 

% Preallocation
path_k = cell(hormigas, 1);
L = zeros(hormigas, t_max); % Lenght del path por hormiga e iteración
all_path = cell(hormigas, t_max);
ants(1:hormigas) = struct('blocked_nodes', [], 'last_node', nodo_init, 'current_node', nodo_init, 'path', nodo_init, 'L', zeros(1, t_max));
mode_plot = zeros(t_max, 1);
mean_plot = zeros(t_max, 1);

%% ACO loop
t = 1;
stop = 1;
% Gradient Color para la animación
% Solo es para personalizar los colores de la animación
map = [255 255 255
    245 215 250
    255 166 216
    255 111 150
    255 61 61]/255;

figure(1); clf;
h2 = plot((1:t_max)', mean_plot, 'Color', [0.8, 0.05, 0], 'LineWidth', 1.5);
hold on
h3 = plot((1:t_max)', mode_plot, 'Color', [0, 0, 0.8], 'LineWidth', 1.5);
title('Global Cost', 'interpreter', 'latex', 'FontSize', 17)
xlabel('Generations', 'interpreter', 'latex', 'FontSize', 12)
ylabel('Path Lenght', 'interpreter', 'latex', 'FontSize', 12)
leg1 = legend('$\bar{x}$', '$\hat{x}$');
set(leg1, 'Interpreter', 'latex');
set(leg1, 'FontSize', 17);
figure(2); clf;
h = plot(G, 'XData', G.Nodes.X, 'YData', G.Nodes.Y, 'NodeColor', 'k'); 
hold on 
nodos_especiales = [G.Nodes.X(str2double(nodo_init)), G.Nodes.Y(str2double(nodo_init)); G.Nodes.X(str2double(nodo_dest)), G.Nodes.Y(str2double(nodo_dest))];
scatter(nodos_especiales(1, 1), nodos_especiales(1, 2), 'g','filled')
scatter(nodos_especiales(2, 1), nodos_especiales(2, 2), 'xr','LineWidth', 5)
if plot_obstacles
    hold on
    axis([1 obstacles(end-3, 1) 1 obstacles(end-3, 1)])
    for obst = 1:max(obstacles(end-6, 4))
        xy = obstacles(obstacles(:, 4) == obst, 1:2);
        plot(polyshape(xy(:, 1), xy(:, 2)), 'FaceAlpha', 0.9, 'FaceColor', 'k');
    end
    plot([obstacles(end-5:end-2, 1); 1], [obstacles(end-5:end-2, 2); 1], 'k', 'LineWidth', 5)
end
colormap(map);
while (t <= t_max && stop)
    
    parfor k = 1:hormigas
        while (not(strcmp(ants(k).current_node, nodo_dest))) % Mientras no se haya llegado al destino
            
            ants(k).blocked_nodes = [ants(k).blocked_nodes; convertCharsToStrings(ants(k).current_node)];
            
            vecinos = setdiff(convertCharsToStrings(neighbors(G, ants(k).current_node)),...
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
        L(k, t) = sum(G.Edges.Eta(findedge(G, ants(k).path(1:end-1), ants(k).path(2:end))).^-1);
        all_path{k, t} = ants(k).path;  % Equivale a x_k(t)
        
        % Regresamos la hormiga k al inicio
        ants(k).current_node = nodo_init;
        ants(k).blocked_nodes = [];
        ants(k).last_node = nodo_init;
        
    end
    
    %% Evaporación de Feromona
    G.Edges.Weight = G.Edges.Weight * (1 - rho);
    
    %% Update de Feromona
    for k = 1:hormigas
        dtau = Q/numel(ants(k).path);
        edge_index = findedge(G, ants(k).path(1:end - 1), ants(k).path(2:end));
        G.Edges.Weight(edge_index) = G.Edges.Weight(edge_index) + dtau;
        ants(k).path = nodo_init;
    end
    
    [mode_plot(t), F] = mode(L(:,t));
    mean_plot(t) = mean(L(:,t));
    
    if (F/hormigas >= epsilon) % condición de paro
        stop = 0;
    end
    
    % Animación
    G.Edges.NormWeight = G.Edges.Weight/sum(G.Edges.Weight);
    h2.YData(t) = mean_plot(t);
    h3.YData(t) = mode_plot(t);
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
    figure(2);
    hold on;
    plot(G.Nodes.X(best_path), G.Nodes.Y(best_path),'r')

end

% profile viewer % Es parte del profiler, descomentar para ver
tiempofinal = toc;
formatSpec = 'iter: %d - t: %.2f - cost: %.2f \n';
fprintf(formatSpec, t-1, tiempofinal, moda)
bpath = [G.Nodes.X(best_path), G.Nodes.Y(best_path)];
if graph_type == "grid"
    webots_path = (bpath - grid_size/2).*[1/5 -1/5];
else
    webots_path = bpath.*[1/grid_size -1/grid_size];
end
wb_pc_path = 'C:\Users\Gaby\Documents\UVG\Tesis\Inteligencia-Computacional-y-Robotica-Swarm\Inteligencia Computacional\Código\Webots\controllers\ACO_controller\';
% save(strcat(wb_pc_path, 'webots_test.mat'), 'bpath', 'webots_path', 'graph_type')
