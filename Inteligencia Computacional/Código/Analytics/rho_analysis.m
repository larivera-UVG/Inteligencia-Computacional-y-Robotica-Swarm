% Diseño e Innovación 2
% Gabriela Iriarte
% 3/10/2020 - 27/10/2020
% Este archivo analiza el parámetro rho del ACO
% La primera vez se hizo con 70 iteraciones máximas, sin embargo esto
% ocasionaba que muchas veces el algoritmo no encontrara la solución. Por
% lo tanto, se aumentó el número de iteraciones máximas hasta 150. De este
% modo el número de fallos se minimizó.

%% Importar las matrices
iteraciones = 150;
if iteraciones == 70
    load('sweep_data1.mat')
    a = rho_sweep_data;
    aa = cell2table(a(2:end, :), 'VariableNames', {'tiempo','costo','iteraciones','path','rho'});
    load('sweep_data2.mat')
    b = rho_sweep_data;
    bb = cell2table(b(2:end, :), 'VariableNames', {'tiempo','costo','iteraciones','path','rho'});
    load('sweep_data3.mat')
    c = rho_sweep_data;
    cc = cell2table(c(2:end, :), 'VariableNames', {'tiempo','costo','iteraciones','path','rho'});
    load('sweep_data4.mat')
    d = rho_sweep_data;
    dd = cell2table(d(2:end, :), 'VariableNames', {'tiempo','costo','iteraciones','path','rho'});
    rho_data = [aa; bb; cc; dd];
elseif iteraciones == 150
    load('sweep_data5.mat')
    rho_data = cell2table(rho_sweep_data(2:end, :), 'VariableNames', {'tiempo','costo','iteraciones','path','rho'});
end

[grupo, id] = findgroups(rho_data.rho);
func = @(p, q, r) [mean(p), mean(q), sum(r==2.5), sum(r==0)];
result = splitapply(func, rho_data.tiempo, rho_data.iteraciones, rho_data.costo, grupo);
agrupada = array2table([id, result], 'VariableNames', {'rho','tiempo','iteraciones', 'costo', 'fallos'});

tabla_1 = rho_data(grupo==1, :);
tabla_2 = rho_data(grupo==2, :);
tabla_3 = rho_data(grupo==3, :);
tabla_4 = rho_data(grupo==4, :);
tabla_5 = rho_data(grupo==5, :);
tabla_6 = rho_data(grupo==6, :);
tabla_7 = rho_data(grupo==7, :);

figure(1)

x = [tabla_1{:, 1}, tabla_2{:, 1}, tabla_3{:, 1}, tabla_4{:, 1}, tabla_5{:, 1}, tabla_6{:, 1}, tabla_7{:, 1}];
boxplot(x, 'Labels', {'0.3','0.4','0.5','0.6','0.7','0.8','0.9'}, 'Symbol', 'kx')
% title('Tiempo por $\rho$', 'Interpreter', 'Latex')
xlabel('$\rho$', 'Interpreter', 'Latex')
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
title('Costo - $\rho = 0.3$', 'Interpreter', 'Latex')
xlabel('costo', 'Interpreter', 'Latex')
ylabel('frecuencia')

subplot(2, 2, 2)
bar(val2, freq2, 'FaceColor', color, 'BarWidth', bw)
title('Costo - $\rho = 0.4$', 'Interpreter', 'Latex')
xlabel('costo', 'Interpreter', 'Latex')
ylabel('frecuencia')

subplot(2, 2, 3)
bar(val3, freq3, 'FaceColor', color, 'BarWidth', bw)
title('Costo - $\rho = 0.5$', 'Interpreter', 'Latex')
xlabel('costo', 'Interpreter', 'Latex')
ylabel('frecuencia')

subplot(2, 2, 4)
bar(val4, freq4, 'FaceColor', color, 'BarWidth', bw)
title('Costo - $\rho = 0.6$', 'Interpreter', 'Latex')
xlabel('costo', 'Interpreter', 'Latex')
ylabel('frecuencia')

figure(3)
subplot(2, 2, 1)
bar(val5, freq5, 'FaceColor', color, 'BarWidth', bw)
title('Costo - $\rho = 0.7$', 'Interpreter', 'Latex')
xlabel('costo', 'Interpreter', 'Latex')
ylabel('frecuencia')

subplot(2, 2, 2)
bar(val6, freq6, 'FaceColor', color, 'BarWidth', bw)
title('Costo - $\rho = 0.8$', 'Interpreter', 'Latex')
xlabel('costo', 'Interpreter', 'Latex')
ylabel('frecuencia')

subplot(2, 2, 3)
bar(val7, freq7, 'FaceColor', color, 'BarWidth', bw)
title('Costo - $\rho = 0.9$', 'Interpreter', 'Latex')
xlabel('costo', 'Interpreter', 'Latex')
ylabel('frecuencia')

% Creamos el archivo de latex con la tabla generada por Matlab
% para darle copy-paste en Overleaf
table2latex(agrupada, 'tabla_rho')




