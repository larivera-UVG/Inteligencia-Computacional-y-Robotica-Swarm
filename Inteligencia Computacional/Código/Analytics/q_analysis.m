% Diseño e Innovación 2
% Gabriela Iriarte
% 3/10/2020 - 27/10/2020
% Este archivo analiza el parámetro rho del ACO
% rapidez:
% 1 - medio - rho = 0.6
% 2 - lento - rho = 0.4
% 3 - rápido - rho = 0.8
%% Importar las matrices
rapidez = 1;
if rapidez == 1
    % MEDIO
    load('sweep_data10.mat') 
    Q_data = cell2table(Q_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','rapidez','path','Q'});
    valores = {'1.2','1.3','1.4','1.5','1.6','1.7','1.8','1.9','2','2.1','2.2','2.3','2.4'};
    [grupo, id] = findgroups(Q_data.Q);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, Q_data.tiempo, Q_data.rapidez, Q_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'Q','tiempo','rapidez', 'costo', 'fallos'});

    tabla_1 = Q_data(grupo==1, :);
    tabla_2 = Q_data(grupo==2, :);
    tabla_3 = Q_data(grupo==3, :);
    tabla_4 = Q_data(grupo==4, :);
    tabla_5 = Q_data(grupo==5, :);
    tabla_6 = Q_data(grupo==6, :);
    tabla_7 = Q_data(grupo==7, :);
    tabla_8 = Q_data(grupo==8, :);
    tabla_9 = Q_data(grupo==9, :);
    tabla_10 = Q_data(grupo==10, :);
    tabla_11 = Q_data(grupo==11, :);
    tabla_12 = Q_data(grupo==12, :);
    tabla_13 = Q_data(grupo==13, :);

    h1 = figure(1);

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}, tabla_7{:, 1}, tabla_8{:, 1}, tabla_9{:, 1}, tabla_10{:, 1},tabla_11{:, 1}, tabla_12{:, 1}, tabla_13{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
%     title('Tiempo por $Q$', 'Interpreter', 'Latex')
    xlabel('$Q$', 'Interpreter', 'Latex')
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
    
    h2 = figure(2);
    color = [187, 153, 255]/255;
    bw = 0.3;
    subplot(2, 2, 1)
    bar(val1, freq1, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    h3 = figure(3);
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.6$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.7$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.8$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 4)
    bar(val8, freq8, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.9$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    h4 = figure(4);
    subplot(2, 2, 1)
    bar(val9, freq9, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val10, freq10, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val11, freq11, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 4)
    bar(val12, freq12, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    h5 = figure(5);
    bar(val13, freq13, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    % Creamos el archivo de latex con la tabla generada por Matlab
    % para darle copy-paste en Overleaf
    table2latex(agrupada, 'tabla_q_med')
    
    % Guardamos las imágenes en formato eps. El epsc indica que queremos la
    % imagen a colores.
%     saveas(h1, 'q_box_m.eps','epsc')
%     saveas(h2, 'q_bar1_m.eps','epsc') 
%     saveas(h3, 'q_bar2_m.eps','epsc')
%     saveas(h4, 'q_bar3_m.eps','epsc') 
%     saveas(h5, 'q_bar4_m.eps','epsc')

    
elseif rapidez == 2
    % LENTO
    load('sweep_data15.mat') 
    Q_data = cell2table(Q_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','rapidez','path','Q'});
    valores = {'1.2','1.3','1.4','1.5','1.6','1.7','1.8','1.9','2','2.1','2.2','2.3','2.4'};
    [grupo, id] = findgroups(Q_data.Q);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, Q_data.tiempo, Q_data.rapidez, Q_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'Q','tiempo','rapidez', 'costo', 'fallos'});

    tabla_1 = Q_data(grupo==1, :);
    tabla_2 = Q_data(grupo==2, :);
    tabla_3 = Q_data(grupo==3, :);
    tabla_4 = Q_data(grupo==4, :);
    tabla_5 = Q_data(grupo==5, :);
    tabla_6 = Q_data(grupo==6, :);
    tabla_7 = Q_data(grupo==7, :);
    tabla_8 = Q_data(grupo==8, :);
    tabla_9 = Q_data(grupo==9, :);
    tabla_10 = Q_data(grupo==10, :);
    tabla_11 = Q_data(grupo==11, :);
    tabla_12 = Q_data(grupo==12, :);
    tabla_13 = Q_data(grupo==13, :);

    h1 = figure(1);

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}, tabla_7{:, 1}, tabla_8{:, 1}, tabla_9{:, 1}, tabla_10{:, 1},tabla_11{:, 1}, tabla_12{:, 1}, tabla_13{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
%     title('Tiempo por $Q$', 'Interpreter', 'Latex')
    xlabel('$Q$', 'Interpreter', 'Latex')
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
    
    h2 = figure(2);
    color = [187, 153, 255]/255;
    bw = 0.3;
    subplot(2, 2, 1)
    bar(val1, freq1, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    h3 = figure(3);
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.6$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.7$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.8$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 4)
    bar(val8, freq8, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.9$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    h4 = figure(4);
    subplot(2, 2, 1)
    bar(val9, freq9, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val10, freq10, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val11, freq11, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 4)
    bar(val12, freq12, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    h5 = figure(5);
    bar(val13, freq13, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    % Creamos el archivo de latex con la tabla generada por Matlab
    % para darle copy-paste en Overleaf
    table2latex(agrupada, 'tabla_q_len')
%     saveas(h1, 'q_box_l.eps','epsc')
%     saveas(h2, 'q_bar1_l.eps','epsc') 
%     saveas(h3, 'q_bar2_l.eps','epsc')
%     saveas(h4, 'q_bar3_l.eps','epsc') 
%     saveas(h5, 'q_bar4_l.eps','epsc')
    
elseif rapidez == 3
    % RÁPIDO
    % Solo se pudo correr 120 rapidez
    load('sweep_data.mat') 
    Q_data = cell2table(Q_sweep_data(2:1574, :), 'VariableNames', {'tiempo','costo','rapidez','path','Q'});
    valores = {'1.2','1.3','1.4','1.5','1.6','1.7','1.8','1.9','2','2.1','2.2','2.3','2.4'};
    [grupo, id] = findgroups(Q_data.Q);
    func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
    result = splitapply(func, Q_data.tiempo, Q_data.rapidez, Q_data.costo, grupo);
    agrupada = array2table([id, result], 'VariableNames', {'Q','tiempo','rapidez', 'costo', 'fallos'});

    tabla_1 = Q_data(grupo==1, :);
    tabla_2 = Q_data(grupo==2, :);
    tabla_3 = Q_data(grupo==3, :);
    tabla_4 = Q_data(grupo==4, :);
    tabla_5 = Q_data(grupo==5, :);
    tabla_6 = Q_data(grupo==6, :);
    tabla_7 = Q_data(grupo==7, :);
    tabla_8 = Q_data(grupo==8, :);
    tabla_9 = Q_data(grupo==9, :);
    tabla_10 = Q_data(grupo==10, :);
    tabla_11 = Q_data(grupo==11, :);
    tabla_12 = Q_data(grupo==12, :);
    tabla_13 = Q_data(grupo==13, :);

    h1 = figure(1);

    x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}, tabla_7{:, 1}, tabla_8{:, 1}, tabla_9{:, 1}, tabla_10{:, 1},tabla_11{:, 1}, tabla_12{:, 1}, tabla_13{:, 1}];
    boxplot(x, 'Labels', valores, 'Symbol', 'kx')
%     title('Tiempo por $Q$', 'Interpreter', 'Latex')
    xlabel('$Q$', 'Interpreter', 'Latex')
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
    
    h2 = figure(2);
    color = [187, 153, 255]/255;
    bw = 0.3;
    subplot(2, 2, 1)
    bar(val1, freq1, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 2)
    bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 3)
    bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    subplot(2, 2, 4)
    bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.5$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')

    h3 = figure(3);
    subplot(2, 2, 1)
    bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.6$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.7$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.8$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 4)
    bar(val8, freq8, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 1.9$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    h4 = figure(4);
    subplot(2, 2, 1)
    bar(val9, freq9, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 2)
    bar(val10, freq10(1), 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.1$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 3)
    bar(val11, freq11, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.2$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    subplot(2, 2, 4)
    bar(val12, freq12, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.3$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')
    
    h5 = figure(5);
    bar(val13, freq13, 'FaceColor', color, 'BarWidth', bw)
    title('Costo - $Q = 2.4$', 'Interpreter', 'Latex')
    xlabel('costo', 'Interpreter', 'Latex')
    ylabel('frecuencia')    
    
    % Creamos el archivo de latex con la tabla generada por Matlab
    % para darle copy-paste en Overleaf
    table2latex(agrupada, 'tabla_q_rap')
%     saveas(h1, 'q_box_r.eps','epsc')
%     saveas(h2, 'q_bar1_r.eps','epsc') 
%     saveas(h3, 'q_bar2_r.eps','epsc')
%     saveas(h4, 'q_bar3_r.eps','epsc') 
%     saveas(h5, 'q_bar4_r.eps','epsc')
    
end







