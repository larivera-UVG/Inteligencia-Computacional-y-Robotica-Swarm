% Diseño e Innovación 2
% Gabriela Iriarte
% 3/10/2020 - 27/10/2020
% Este archivo analiza el parámetro alpha del ACO
%% Importar las matrices
rapidez = 3;

% rapidez:
% ** 1 y 2 tienen 70 iteraciones como iteraciones max **
% ** El resto tiene 150 iteraciones como iteraciones max (que son las que 
% **                 se usaron en la tesis final)
% 1 - medio - rho = 0.6 - valores = {'1','1.5','2','2.5','3'}
% 2 - medio - rho = 0.6 - valores = {'0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1','1.1','1.2','1.3','1.4','1.5'};
% 3 - medio - rho = 0.6 - valores = {'0.9','1','1.1','1.2','1.3','1.4','1.5'}
% 4 - lento - rho = 0.4 - valores = {'0.9','1','1.1','1.2','1.3','1.4','1.5'}
% 5 - rápido - rho = 0.8 - valores = {'0.9','1','1.1','1.2','1.3','1.4','1.5'}

if rapidez == 1
    % MEDIO
    load('sweep_data6.mat') % sweep de 1-3 cada 0.5
    alpha_data = cell2table(alpha_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','rapidez','path','alpha'});
    valores = {'1','1.5','2','2.5','3'};
    [grupo, id] = findgroups(alpha_data.alpha);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, alpha_data.tiempo, alpha_data.rapidez, alpha_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'alpha','tiempo','rapidez', 'costo', 'fallos'});

    tabla_1 = alpha_data(grupo==1, :);
    tabla_2 = alpha_data(grupo==2, :);
    tabla_3 = alpha_data(grupo==3, :);
    tabla_4 = alpha_data(grupo==4, :);
    tabla_5 = alpha_data(grupo==5, :);

    figure(1)

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
%     title('Tiempo por $\alpha$', 'Interpreter', 'Latex')
    xlabel('$\alpha$', 'Interpreter', 'Latex')
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
    % val6 = unique(tabla_6{:, 2});
    % freq6 = hist(tabla_6{:, 2}, val6)';
    % val7 = unique(tabla_7{:, 2});
    % freq7 = hist(tabla_7{:, 2}, val7)';
    % 
    figure(2)
    color = [187, 153, 255]/255;
    bw = 0.3;
    subplot(2, 2, 1)
    bar(val1, freq1, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 2.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    figure(3)
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
elseif rapidez == 2
    % MEDIO
    load('sweep_data7.mat')
    valores = {'0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1','1.1','1.2','1.3','1.4','1.5'};
    alpha_data = cell2table(alpha_sweep_data(2:946, :), 'VariableNames', {'tiempo','costo','rapidez','path','alpha'});
    [grupo, id] = findgroups(alpha_data.alpha);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, alpha_data.tiempo, alpha_data.rapidez, alpha_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'alpha','tiempo','rapidez', 'costo', 'fallos'});
    
    tabla_1 = alpha_data(grupo==1, :);
    tabla_2 = alpha_data(grupo==2, :);
    tabla_3 = alpha_data(grupo==3, :);
    tabla_4 = alpha_data(grupo==4, :);
    tabla_5 = alpha_data(grupo==5, :);
    tabla_6 = alpha_data(grupo==6, :);
    tabla_7 = alpha_data(grupo==7, :);
    tabla_8 = alpha_data(grupo==8, :);
    tabla_9 = alpha_data(grupo==9, :);
    tabla_10 = alpha_data(grupo==10, :);
    tabla_11 = alpha_data(grupo==11, :);
    tabla_12 = alpha_data(grupo==12, :);
    tabla_13 = alpha_data(grupo==13, :);
    tabla_14 = alpha_data(grupo==14, :);
    tabla_15 = alpha_data(grupo==15, :);
    
    figure(1)
    
    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1},tabla_6{:, 1}, tabla_7{:, 1}, tabla_8{:, 1}, tabla_9{:, 1}, tabla_10{:, 1},tabla_11{:, 1}, tabla_12{:, 1}, tabla_13{:, 1}, tabla_14{:, 1}, tabla_15{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
%     title('Tiempo por $\alpha$', 'Interpreter', 'Latex')
    xlabel('$\alpha$', 'Interpreter', 'Latex')
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
    val8 = unique(tabla_8{:, 2});
    freq8 = hist(tabla_8{:, 2}, val8)';
    val9 = unique(tabla_9{:, 2});
    freq9= hist(tabla_9{:, 2}, val9)';
    val10 = unique(tabla_10{:, 2});
    freq10 = hist(tabla_10{:, 2}, val10)';
    val11 = unique(tabla_11{:, 2});
    freq11 = hist(tabla_11{:, 2}, val11)';
    val12 = unique(tabla_12{:, 2});
    freq12 = hist(tabla_12{:, 2}, val12)';
    val13 = unique(tabla_13{:, 2});
    freq13 = hist(tabla_13{:, 2}, val13)';
    val14 = unique(tabla_14{:, 2});
    freq14 = hist(tabla_14{:, 2}, val14)';
    val15 = unique(tabla_15{:, 2});
    freq15 = hist(tabla_15{:, 2}, val15)';
    
    figure(2)
    color = [187, 153, 255]/255;
    bw = 0.3;
    subplot(2, 2, 1)
    bar(val1, freq1, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 0.9$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    figure(3)
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
elseif rapidez == 3    
    % MEDIO
    load('sweep_data8.mat')
    alpha_data = cell2table(alpha_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','rapidez','path','alpha'});
    valores = {'0.9','1','1.1','1.2','1.3','1.4','1.5'};
    [grupo, id] = findgroups(alpha_data.alpha);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, alpha_data.tiempo, alpha_data.rapidez, alpha_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'alpha','tiempo','rapidez', 'costo', 'fallos'});

    tabla_1 = alpha_data(grupo==1, :);
    tabla_2 = alpha_data(grupo==2, :);
    tabla_3 = alpha_data(grupo==3, :);
    tabla_4 = alpha_data(grupo==4, :);
    tabla_5 = alpha_data(grupo==5, :);
    tabla_6 = alpha_data(grupo==6, :);
    tabla_7 = alpha_data(grupo==7, :);

    figure(1)

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}, tabla_7{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
%     title('Tiempo por $\alpha$', 'Interpreter', 'Latex')
    xlabel('$\alpha$', 'Interpreter', 'Latex')
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
    bar(val1, freq1(1), 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 0.9$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    figure(3)
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    % Creamos el archivo de latex con la tabla generada por Matlab
    % para darle copy-paste en Overleaf
    table2latex(agrupada, 'tabla_alpha_med')
    
elseif rapidez == 4
    % LENTO
    load('sweep_data13.mat') % sweep de 1-3 cada 0.5
    alpha_data = cell2table(alpha_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','rapidez','path','alpha'});
    valores = {'0.9','1','1.1','1.2','1.3','1.4','1.5'};
    [grupo, id] = findgroups(alpha_data.alpha);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, alpha_data.tiempo, alpha_data.rapidez, alpha_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'alpha','tiempo','rapidez', 'costo', 'fallos'});

    tabla_1 = alpha_data(grupo==1, :);
    tabla_2 = alpha_data(grupo==2, :);
    tabla_3 = alpha_data(grupo==3, :);
    tabla_4 = alpha_data(grupo==4, :);
    tabla_5 = alpha_data(grupo==5, :);
    tabla_6 = alpha_data(grupo==6, :);
    tabla_7 = alpha_data(grupo==7, :);

    figure(1)

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}, tabla_7{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
%     title('Tiempo por $\alpha$', 'Interpreter', 'Latex')
    xlabel('$\alpha$', 'Interpreter', 'Latex')
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
    bar(val1, freq1(1), 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 0.9$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    figure(3)
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    % Creamos el archivo de latex con la tabla generada por Matlab
    % para darle copy-paste en Overleaf
    table2latex(agrupada, 'tabla_alpha_len')
    
elseif rapidez == 5    
    % RÁPIDO
    load('sweep_data16.mat') % sweep de 1-3 cada 0.5
    alpha_data = cell2table(alpha_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','rapidez','path','alpha'});
    valores = {'0.9','1','1.1','1.2','1.3','1.4','1.5'};
    [grupo, id] = findgroups(alpha_data.alpha);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, alpha_data.tiempo, alpha_data.rapidez, alpha_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'alpha','tiempo','rapidez', 'costo', 'fallos'});

    tabla_1 = alpha_data(grupo==1, :);
    tabla_2 = alpha_data(grupo==2, :);
    tabla_3 = alpha_data(grupo==3, :);
    tabla_4 = alpha_data(grupo==4, :);
    tabla_5 = alpha_data(grupo==5, :);
    tabla_6 = alpha_data(grupo==6, :);
    tabla_7 = alpha_data(grupo==7, :);

    h1 = figure(1);

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}, tabla_7{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
%     title('Tiempo por $\alpha$', 'Interpreter', 'Latex')
    xlabel('$\alpha$', 'Interpreter', 'Latex')
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
    
    h2 = figure(2);
    color = [187, 153, 255]/255;
    bw = 0.3;
    subplot(2, 2, 1)
    bar(val1, freq1, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 0.9$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    h3 = figure(3);
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $\alpha = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
%     saveas(h1, 'alpha_box_r.eps','epsc')
%     saveas(h2, 'alpha_bar1_r.eps','epsc') 
%     saveas(h3, 'alpha_bar2_r.eps','epsc')
% Creamos el archivo de latex con la tabla generada por Matlab
% para darle copy-paste en Overleaf
table2latex(agrupada, 'tabla_alpha_rap')
    
end







