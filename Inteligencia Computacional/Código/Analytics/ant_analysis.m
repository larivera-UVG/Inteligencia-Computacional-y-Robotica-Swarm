% Diseño e Innovación 2
% Gabriela Iriarte
% 3/10/2020 - 27/10/2020
% Este archivo analiza el parámetro hormigas del ACO
% rapidez:
% 1 - medio - rho = 0.6
% 2 - lento - rho = 0.4
% 3 - rápido - rho = 0.8
%% Importar las matrices
rapidez = 1;
if rapidez == 1
    load('sweep_data11.mat') % No tiene sentido estos datos, hice dos barridos al mismo tiempo
    ant_data = cell2table(ant_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','rapidez','path','ant'});
    valores = {'50','60','70','80','90','100'};
    [grupo, id] = findgroups(ant_data.ant);
    func = @(p, ant, r) [mean(p), mean(ant), sum(r==2.5), sum(r==0)];
    result = splitapply(func, ant_data.tiempo, ant_data.rapidez, ant_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'ant','tiempo','rapidez', 'costo', 'fallos'});

    tabla_1 = ant_data(grupo==1, :);
    tabla_2 = ant_data(grupo==2, :);
    tabla_3 = ant_data(grupo==3, :);
    tabla_4 = ant_data(grupo==4, :);
    tabla_5 = ant_data(grupo==5, :);
    tabla_6 = ant_data(grupo==6, :);

    h1 = figure(1);

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
    title('Tiempo por hormigas', 'Interpreter', 'Latex')
    xlabel('hormigas', 'Interpreter', 'Latex')
    ylabel('tiempo (s)')

    val1 = unique(tabla_1{:, 2});
    freant1 = hist(tabla_1{:, 2}, val1)';
    val2 = unique(tabla_2{:, 2});
    freant2= hist(tabla_2{:, 2}, val2)';
    val3 = unique(tabla_3{:, 2});
    freant3 = hist(tabla_3{:, 2}, val3)';
    val4 = unique(tabla_4{:, 2});
    freant4 = hist(tabla_4{:, 2}, val4)';
    val5 = unique(tabla_5{:, 2});
    freant5 = hist(tabla_5{:, 2}, val5)';
    val6 = unique(tabla_6{:, 2});
    freant6 = hist(tabla_6{:, 2}, val6)';
    
    h2 = figure(2);
    color = [187, 153, 255]/255;
    bw = 0.3;
    subplot(2, 2, 1)
    bar(val1, freant1, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - 50 hormigas', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freant2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - 60 hormigas', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freant3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - 70 hormigas', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freant4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - 80 hormigas', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    h3 = figure(3);
    subplot(2, 2, 1)
    bar(val5, freant5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - 90 hormigas', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freant6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - 100 hormigas', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    % Guardamos las imágenes en formato eps. El epsc indica que queremos la
    % imagen a colores.
%     saveas(h1, 'ant_box_m.eps','epsc')
%     saveas(h2, 'ant_bar1_m.eps','epsc') 
%     saveas(h3, 'ant_bar2_m.eps','epsc')

    % Creamos el archivo de latex con la tabla generada por Matlab
    % para darle copy-paste en Overleaf
    table2latex(agrupada, 'tabla_ant')
 
end






