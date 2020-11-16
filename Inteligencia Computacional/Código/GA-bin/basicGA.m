% Basado en el curso de cómputo evolutivo Coursera
% Universidad Nacional Autónoma de México
%% Definición de parámetros
tic
Nind = 100;  % Número de individuos en la población
Lind = 20;  % Longitud de los individuos 10 bits x, 10 bits y
Pc = 0.9;  % Probabilidad de cruzamiento de 60 a 100%
Pm = 0.01;  % Probabilidad de mutación pequeño, menor que 10%
Maxgen = 100;
Nvar = 2;
epsilon = 0.05;
tipo_funcion = "Booth";
if strcmp(tipo_funcion, "Banana")
    rango = [-5, -5;
        10, 10];
elseif strcmp(tipo_funcion, "Ackley")
    rango = [-32.768, -32.768;
        32.768, 32.768];
    Lind = 24;
    
elseif strcmp(tipo_funcion, "Rastrigin") % esta presenta problemas
    rango = [-5.12, -5.12;
        5.12, 5.12];
elseif strcmp(tipo_funcion, "Booth")
    rango = [-10, -10;
        10, 10];
end
Mejor = NaN*ones(Maxgen, 1);
Mejor_cromosoma = zeros(Nind, Lind); %*Nvar);  % Variables de decision codificadas
p_init = [-4, 4];
bin_p_init = [d2b(p_init(1), Lind/2,rango(:,1), tipo_funcion), d2b(p_init(2), Lind/2,rango(:,2),tipo_funcion)];
%% Algoritmo genético básico
fenotipo = repmat(p_init, [Nind, 1]);
genotipo = repmat(bin_p_init, [Nind, 1]);
%genotipo = creapob(Nind, Lind); % Se crean los 100 individuos en binario, con 20 dígitos cada uno
%fenotipo = decodifica(genotipo, rango); % ya en el dominio del problema
objv = objfun(fenotipo, tipo_funcion); % costo inicial
generaciones = 1;
% Para graficar la superficie y el contour
[X,Y,Z] = GA_contour(tipo_funcion);

figure(1);
contour(X,Y,Z,50)
hold on
h = scatter(fenotipo(1, 1), fenotipo(1, 2), 'k', 'filled');
h4 = scatter(fenotipo(1, 1), fenotipo(1, 2), 'g', 'filled');
h3 = plot(0,0,'k');
hold off

figure(2)
gbest = min(objv);
h2 = plot(gbest, 'r');
xlabel('generaciones');
ylabel('f(x)');

path = p_init;

valor = Inf;
stop = 1;
while (generaciones < Maxgen) && stop
    aptitud = rankeo(objv, 2);  % Ya todos los valores positivos
    nuevo_gen = ruleta(genotipo, fenotipo, aptitud);
    nuevo_gen = xunpunto(nuevo_gen, Pc);
    nuevo_gen = muta(nuevo_gen, Pm);
    nuevo_feno = decodifica(nuevo_gen, rango, tipo_funcion);
    nuevo_objv = objfun(nuevo_feno, tipo_funcion);
    genotipo = nuevo_gen;
    objv = nuevo_objv;
    [valor, idx] = min(objv);
    Mejor(generaciones) = valor;
    Mejor_cromosoma(generaciones, :) = genotipo(idx, :);
    path = [path; nuevo_feno(idx, :)];

    h3.XData = path(:, 1);
    h3.YData = path(:, 2);
    h.XData = nuevo_feno(idx, 1);
    h.YData = nuevo_feno(idx, 2);
    h2.YData = [gbest; Mejor];
    drawnow limitrate
    if (valor <= epsilon) % condición de paro
        stop = 0;
    end
    generaciones = generaciones + 1;
    
end

figure(2);
text(0.5, 0.95, ['Cost = ', num2str(valor)], 'Units', ...
        'normalized');

fin = toc;

formatSpec = 'iter: %d - t: %.2f seg - cost: %.2f \n';
fprintf(formatSpec, generaciones, fin, valor)















