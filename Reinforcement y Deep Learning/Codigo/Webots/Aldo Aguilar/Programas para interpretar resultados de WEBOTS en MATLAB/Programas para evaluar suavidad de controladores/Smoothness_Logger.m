%% Diseño e Innovacion de Ingenieria
% Titulo: Smoothness_Logger.m
% Autor: Aldo Aguilar Nadalini 15170
% Fecha: 31 de octubre de 2019
% Descripcion: Programa para loggear en Excel datos de smoothness

%% Inicializacion de file en Excel

% filename='Smoothness_Records.xlsx';
% fileExist = exist(filename,'file');
% header = {'1', '2','3','4','5','6', '7','8','9','10','11', '12','13','14','15','16','17','18','19','20'};
% xlswrite(filename,header);

%% Recoleccion de muestras

% Nombre de archivo
filename1='Smoothness_Records.xlsx';
filename2='Saturation_Records.xlsx';

% Lectura de archivos de resultados de E-Puck (escritos por Webots)
EPuck0 = readtable('epuck0.txt');
EPuck1 = readtable('epuck1.txt');
EPuck2 = readtable('epuck2.txt');
EPuck3 = readtable('epuck3.txt');
EPuck4 = readtable('epuck4.txt');
EPuck5 = readtable('epuck5.txt');
EPuck6 = readtable('epuck6.txt');
EPuck7 = readtable('epuck7.txt');
EPuck8 = readtable('epuck8.txt');
EPuck9 = readtable('epuck9.txt');

%% Separacion de datos de cada E-Puck

% Smoothness array
Ws = [];

% Saturation array
Wsat = [];

% Ejecucion para cada robot
for ID = 0:9

    if (ID == 0)
        EPuck = EPuck0;
    elseif (ID == 1)
        EPuck = EPuck1;
    elseif (ID == 2)
        EPuck = EPuck2;
    elseif (ID == 3)
        EPuck = EPuck3;
    elseif (ID == 4)
        EPuck = EPuck4;
    elseif (ID == 5)
        EPuck = EPuck5;
    elseif (ID == 6)
        EPuck = EPuck6;
    elseif (ID == 7)
        EPuck = EPuck7;
    elseif (ID == 8)
        EPuck = EPuck8;
    elseif (ID == 9)
        EPuck = EPuck9;
    end
    
    headers = char(EPuck{:,1});                     % Recopilacion de headers para identificacion de tipo de datos
    epuck_name = string(EPuck{1,2});                % Identificacion del E-Puck analizado
    data = [EPuck{:,3},EPuck{:,4},EPuck{:,5},EPuck{:,6}];   % Datos de simulacion (Columnas 3-6)

    PHI_R = [];                                     % Datos de velocidad de motor derecho de E-Puck
    PHI_L = [];                                     % Datos de velocidad de motor izquierdo de E-Puck

    % Separacion de datos segun su identificador en matriz de data
    for i = 1:length(headers)
        if (headers(i) == 'V') 
            PHI_R(end + 1) = data(i,3);
            PHI_L(end + 1) = data(i,4);
        end
    end

    % Calculo de suavidad de velocidad de motores
    W_R = Smoothness_Calculator(PHI_R, 3, 0);
    W_L = Smoothness_Calculator(PHI_L, 3, 0);
    
    % Agregar calculos de suavidad a array total
    Ws(end + 1) = W_R;
    Ws(end + 1) = W_L;
    
    % Calculo de saturacion de velocidad de motores -----------------------
    N = numel(PHI_R);
    saturated_values = 0;
    for i = 1:N
        if (abs(PHI_R(i)) >= 6.27)
            saturated_values = saturated_values + 1;
        end
    end
    right_saturation = saturated_values/N;
    
    N = numel(PHI_L);
    saturated_values = 0;
    for j = 1:N
        if (abs(PHI_L(j)) >= 6.27)
            saturated_values = saturated_values + 1;
        end
    end
    left_saturation = saturated_values/N;
    
    % Agregar calculos de suavidad a array total
    Wsat(end + 1) = right_saturation;
    Wsat(end + 1) = left_saturation;
end

% Agregar datos de smoothness de controlador a Logger
[~,~,input] = xlsread(filename1); % Read in your xls file to a cell array (input)
new_data = {Ws(1), Ws(2), Ws(3), Ws(4), Ws(5), Ws(6), Ws(7), Ws(8), Ws(9), Ws(10), Ws(11), Ws(12), Ws(13), Ws(14), Ws(15), Ws(16), Ws(17), Ws(18), Ws(19), Ws(20)}; % This is a cell array of the new line you want to add
output = cat(1,input,new_data);  % Concatinate your new data to the bottom of input
xlswrite(filename1,output);       % Write to the new excel file. 

% Agregar datos de saturacion de controlador a Logger
[~,~,input] = xlsread(filename2); % Read in your xls file to a cell array (input)
new_data = {Wsat(1), Wsat(2), Wsat(3), Wsat(4), Wsat(5), Wsat(6), Wsat(7), Wsat(8), Wsat(9), Wsat(10), Wsat(11), Wsat(12), Wsat(13), Wsat(14), Wsat(15), Wsat(16), Wsat(17), Wsat(18), Wsat(19), Wsat(20)}; % This is a cell array of the new line you want to add
output = cat(1,input,new_data);  % Concatinate your new data to the bottom of input
xlswrite(filename2,output);       % Write to the new excel file.