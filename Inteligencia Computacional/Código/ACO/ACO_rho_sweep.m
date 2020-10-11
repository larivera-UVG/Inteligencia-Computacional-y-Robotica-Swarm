% IE Diseño e Innovación
% Ant Colony Optimization - Ant System
% Gabriela Iriarte Colmenares
% 16009
% 11/07/2020
% Descripción: Barrido para encontrar mejores parámetros para rho.
% Rho es el rate de evaporación (puede tomar valores entre 0 y 1)
%% Graph generation
start_mail();
try
graph_type = "grid";

if strcmp(graph_type, "grid")
    % Creamos grid cuadrado con la cantidad de nodos indicada:
    grid_size = 10;
    cost_diag = 0.5;
    tau_0 = 0.1;  % Valor de tau inicial
    G = graph_grid(grid_size);
    G_cpy = G;
    nodo_dest = '56';
    nodo_init = "1";
    plot_obstacles = 0;
elseif strcmp(graph_type, "visibility")
    load('vis_graph.mat')
    G = grafo2;
    nodo_dest = string(size(grafo2.Nodes, 1));
    nodo_init = string(size(grafo2.Nodes, 1)-1);
    plot_obstacles = 1;
    axis([1 obstacles(end-3, 1) 1 obstacles(end-3, 1)])
elseif strcmp(graph_type, "PRM")
    % Para utilizar esta función instalar el toolbox
    % de robótica de Peter Corke
    % Está pensado para PRM sin obstáculos
    grid_size = 10;
    load('prm_test_graph'); % prm_generator(grid_size, 50);
    nodo_dest = '47';
    nodo_init = "31";
    plot_obstacles = 0;
end


%% ACO init
t_max = 150;
hormigas = 50;
Q = 2;  % cte. positiva que regula el depósito de feromona
epsilon = 0.9;  % Porcentaje de hormigas que queremos siguiendo la misma solución

% Le da más peso a la feromona en la probabilidad
alpha = 1;
% Le da más peso al costo del link en la probabilidad
beta = 1;

% Preallocation
ants(1:hormigas) = struct('blocked_nodes', [], 'last_node', nodo_init, 'current_node', nodo_init, 'path', nodo_init, 'L', zeros(1, t_max));
rho_sweep = 0.3:0.1:0.9;
repetitions = 10;
rho_sweep_data = cell(numel(rho_sweep) * repetitions + 1, 5);
rho_sweep_data(1, :) = {'tiempo', 'costo', 'iteraciones', 'path', 'rho'};
sweep_count = 1;
t_acumulado = 0;

for rep = 1:1:repetitions
    for rho = rho_sweep
        %% ACO loop
        timer = tic;
        G = G_cpy;
        all_path = cell(hormigas, t_max);
        L = zeros(hormigas, t_max); % Lenght del path por hormiga e iteración
        t = 1;
        stop = 1;
        
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
            
            t = t + 1;
            
            
        end
        %% Best Path Calculation
        
        if (t > t_max)
            best_path = "No hubo convergencia";
            tiempofinal = toc(timer);
            rho_sweep_data(sweep_count + 1, :) = {tiempofinal, 0, t - 1, best_path, rho};
        else
            moda =  mode(L(:, t-1));
            len_indx = L(:, t-1).*(L(:,t-1) == moda);
            len_prob = rouletteWheel(len_indx);
            best_path = all_path{len_prob, t-1};
            tiempofinal = toc(timer);
            rho_sweep_data(sweep_count + 1, :) = {tiempofinal, L(len_prob, t-1), t - 1, best_path, rho};
        end
        t_acumulado = t_acumulado + tiempofinal;
        if t_acumulado >= 60
            disp("Guardando...")
            save('sweep_data', 'rho_sweep_data')
            t_acumulado = 0;
        end
        sweep_count = sweep_count + 1;
    end
    
end
% Guardado final
save('sweep_data', 'rho_sweep_data')
disp("Done.")
end_mail();

catch
    disp("Oh rayos....\n")
    error_mail();
end

% sum(cell2mat(rho_sweep_data(2:end, 1))) % Tiempo total de operación de la
% prueba (barrido)




