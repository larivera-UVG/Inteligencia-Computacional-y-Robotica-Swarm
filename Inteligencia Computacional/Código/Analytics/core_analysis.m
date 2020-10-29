% Diseño e Innovación 2
% Gabriela Iriarte
% 3/10/2020 -  27/10/2020
% Este archivo analiza el barrido de cores que se le hizo al ACO.
% En el caso de los cores, solo se realizaron 50 ejecuciones debido al
% tiempo que tardaba.
%% Importar las matrices
iteraciones = 1;
if iteraciones == 1
    load('sweep_data12.mat') % No tiene sentido estos datos, hice dos barridos al mismo tiempo
    core_data = cell2table(core_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','iteraciones','path','ant'});
    for sw = 1:1:44
       valores{1, sw} = num2str(sw); 
    end

    [grupo, id] = findgroups(core_data.ant);
    func = @(p, ant, r) [mean(p), std(ant), mean(ant), sum(r==2.5), sum(r==0)];
    result = splitapply(func, core_data.tiempo, core_data.iteraciones, core_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'cores','tiempo','stdt','iteraciones', 'costo', 'fallos'});
    tt = core_data(:, 1);
    t_total = sum(tt{:, 1})/3600; % Tiempo total del sweep en horas. Se tardó 9.9505h
    all_cores = agrupada(:, 1);
    t = agrupada(:, 2);
    desv_est = agrupada(:, 3);
    e = errorbar(all_cores{:, 1}, t{:, 1}, desv_est{:, 1});
    e.Color = [255 142 122]./255;
    e.LineWidth = 1.5;
    xlabel('núcleos')
    ylabel('t(s)')
    hold on
    plot(all_cores{:, 1}, t{:, 1}, 'r', 'LineWidth', 2)
    legend('$\sigma $', '$\mu $', 'Interpreter', 'Latex')
    
    % Creamos el archivo de latex con la tabla generada por Matlab
    % para darle copy-paste en Overleaf
    table2latex(agrupada(:, 1:4), 'tabla_cores')
       
end






