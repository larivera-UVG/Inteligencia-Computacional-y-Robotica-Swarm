function [XVerts,YVerts,ZVerts] = polyshape2fill3(CoordsX,CoordsY,CoordsZ)
% POLYSHAPE2FILL3 Función que cambia el formato de los vértices de un
% polígono destinado para ser utilizado en funciones como polyshape
% (Vértices en una sola columna separando con NaN cada objeto) a vértices
% que pueden ser utilizados en funciones como fill3 (Vértices donde los
% vértices correspondientes a diferentes objetos están en diferentes
% columnas). Soporta la conversión de múltiples polígonos con números
% diferentes de vértices.
% -------------------------------------------------------------------------
% Input
%   - XVerts: Vector columna con las coordenadas X de los vértices 
%     correspondientes a uno o más polígonos. En formato "polyshape()"
%   - YVerts: Vector columna con las coordenadas Y de los vértices 
%     correspondientes a uno o más polígonos. En formato "polyshape()"
%
% Output
%   - XVerts: Vector columna con las coordenadas X de los vértices 
%     correspondientes a uno o más polígonos. En formato "fill3()"
%   - YVerts: Vector columna con las coordenadas Y de los vértices 
%     correspondientes a uno o más polígonos. En formato "fill3()"
%   - ZVerts: Vector columna con las coordenadas Z de los vértices 
%     correspondientes a uno o más polígonos. En formato "fill3()"
%
% -------------------------------------------------------------------------

% Vértices convertidos a formato fill3. Inicia como un vector vacío.
XVerts = [];
YVerts = [];

Objeto = 1;     % Número de polígonos (objetos) diferentes a graficar
Punto = 1;      % Fila de las coordenadas en formato "polyshape" a analizar
Vert = 1;       % Número de vértice para el polígono actual

% Número máximo de vértices que tiene cada polígono. Utilizado para casos
% donde hay múltiples polígonos con diferente número de vértices.
NoMaxVertices = [];

% Mientras la fila analizada sea menor al número máximo de filas en
% "CoordsX" entonces se continúa el proceso.
while Punto <= size(CoordsX,1)
    
    % Si se encuentra un NaN en la fila "Punto"
    if isnan(CoordsX(Punto,1))
        NoMaxVertices(Objeto) = Vert - 1;           % Número vértices máximo del polígono "Objeto". Se resta 1 para compensar el Vert = Vert + 1 al final del else luego.
        Objeto = Objeto + 1;                        % Se pasa al siguiente objeto o polígono
        Vert = 1;                                   % Se inicia el número de vértice para el polígono
    
    % Si la fila no consiste de NaNs
    else
        XVerts(Vert,Objeto) = CoordsX(Punto,1);     % La fila "Punto" de CoordsX se coloca en la fila "Vert", columna "Objeto" de XVerts  
        YVerts(Vert,Objeto) = CoordsY(Punto,1);     % La fila "Punto" de CoordsY se coloca en la fila "Vert", columna "Objeto" de YVerts  
        Vert = Vert + 1;                            % Se pasa la siguiente vértice del polígono
    end
    
    % Se analiza la siguiente fila en "CoordsX"
    Punto = Punto + 1;

end

NoObjetos = size(XVerts,2);         % Número Objetos / Polígonos = Número de columnas de XVerts / YVerts
NoPuntos = size(XVerts,1);          % Número Puntos / Vértices = Número de filas de XVerts / YVerts

% Se "paddean" los vértices de cada objeto para que en caso de que
% contengan menos vértices que otros polígonos, estos no tengan ceros como
% padding, sino que el valor de la coordenada en su último vértice.
for i = 1:NoObjetos
    
    % Si el polígono actual (columna actual) tiene menos vértices que el
    % polígono con más vértices de la matriz (NoPuntos). 
    if NoMaxVertices(i) < NoPuntos
        
        % Se copia el valor del último vértice (en la última fila o 
        % "NoMaxVertices(i)") desde la siguiente fila luego del último
        % vértice (NoMaxVertices(i) + 1) hasta la última fila en la matriz
        % (NoPuntos).
        XVerts(NoMaxVertices(i)+1:NoPuntos,i) = XVerts(NoMaxVertices(i),i);
        YVerts(NoMaxVertices(i)+1:NoPuntos,i) = YVerts(NoMaxVertices(i),i);
        
    end
    
end

% Para un polígono, se van a tener dos caras: Una superior y una inferior.
% Cada cara consistirá de una columna diferente. Las coordenadas X y Y
% permanecerán inalteradas entre caras, la única que cambiará será la
% coordenada Z. Entonces, para crear ambas caras, se repiten todas las
% columnas de XVerts y YVerts.
XVerts = repmat(XVerts,1,2);
YVerts = repmat(YVerts,1,2);

AlturaBase = CoordsZ(1,1);          % Altura de cara inferior
AlturaTapa = CoordsZ(1,2);          % Altura de cara superior

% Las coordenadas Z van a tener la altura del número máximo de puntos y
% tantas parejas de columnas como número de objetos o polígonos. Por
% ejemplo, si se tienen 5 polígonos de 4 vértices, Z será una matriz de
% (4X10)
ZVerts = [repmat(AlturaBase*ones(NoPuntos,1),1,NoObjetos) ... 
          repmat(AlturaTapa*ones(NoPuntos,1),1,NoObjetos)];
    
end

