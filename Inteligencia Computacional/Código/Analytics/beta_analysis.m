% Diseño e Innovación 2
% Gabriela Iriarte
% 3/10/2020 -  
% Este archivo analiza el parámetro rho del ACO
%% Importar las matrices
iteraciones = 1;
if iteraciones == 1
    load('sweep_data9.mat') 
    beta_data = cell2table(beta_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','iteraciones','path','beta'});
    valores = {'0.9','1','1.1','1.2','1.3','1.4','1.5'};
    [grupo, id] = findgroups(beta_data.beta);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, beta_data.tiempo, beta_data.iteraciones, beta_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'beta','tiempo','iteraciones', 'costo', 'fallos'});

    tabla_1 = beta_data(grupo==1, :);
    tabla_2 = beta_data(grupo==2, :);
    tabla_3 = beta_data(grupo==3, :);
    tabla_4 = beta_data(grupo==4, :);
    tabla_5 = beta_data(grupo==5, :);
    tabla_6 = beta_data(grupo==6, :);
    tabla_7 = beta_data(grupo==7, :);

    figure(1)

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}, tabla_7{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
    title('Tiempo por $\beta$', 'Interpreter', 'Latex')
    xlabel('$\beta$', 'Interpreter', 'Latex')
    ylabel('tiempo (s)')

    val1 = unique(tabla_1{:, 2});
    freq1 = hist(tabla_1{:, 2}, val1)';
    val2 = unique(tabla_2{:, 2});
    freq2= hist(tabla_2{:, 2}, val2)';
    val3 = unique(tabla_3{:, 2});
    freq3 = hist(tabla_3{:, 2}, val3)';
    val4 = unique(tabla_4{:, 2});
    freq4 = hist(tabla_4{:, 2}, val4)';
    val5 = unique(tabla_5{:, 2});
    freq5 = hist(tabla_5{:, 2}, val5)';
    val6 = unique(tabla_6{:, 2});
    freq6 = hist(tabla_6{:, 2}, val6)';
    val7 = unique(tabla_7{:, 2});
    freq7 = hist(tabla_7{:, 2}, val7)';
    
    figure(2)
    color = [187, 153, 255]/255;
    bw = 0.3;
    subplot(2, 2, 1)
    bar(val1, freq1, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\rho = 1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\rho = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\rho = 2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\rho = 2.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    figure(3)
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\rho = 3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\beta = 1.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\beta = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
end






