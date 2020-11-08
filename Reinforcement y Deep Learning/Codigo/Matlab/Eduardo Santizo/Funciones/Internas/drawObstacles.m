function [X,Y,Z] = drawObstacles(Figura,Altura,ZOffset,varargin)
% DRAWOBSTACLES Funci�n que permite decidir la forma de los obst�culos que
% se desplegar�n sobre el escenario y en base a esto genera las coordenadas
% necesarias para graficar los mismos en 2D o 3D.
% -------------------------------------------------------------------------
% Inputs: 
%   - Figura: Tipo de figura a graficar. Existen tres opciones: "Cilindro",
%     "Poligono", "Custom" e "Imagen".
%   - Altura: Altura de la geometr�a a graficar. Aunque la geometr�a sea 2D
%     la funci�n necesita de una altura para generar las coordenadas Z del
%     pol�gono.
%   - ZOffset: Altura de la cara inferior del pol�gono a crear. En otras
%     palabras, el nivel de Z sobre el que el pol�gono estar� "sentado".
%
% Inputs Adicionales: 
%   Figura = "Cilindro" 
%   1. Radio: Radio del cilindro.
%
%   Figura = "Poligono"
%   1. LimsX: L�mites de la mesa de trabajo en X.
%   2. LimsY: L�mites de la mesa de trabajo en Y.
%   3. Meta: Punto a alcanzar por los robots
%   4. PuntoPartida: Punto del que salen los robots.
%
%   Figura = "Custom"
%   1. X: V�rtices en X del pol�gono 2D
%   2. Y: V�rtices en Y del pol�gono 2D
%
%   Figura = "Imagen"
%   1. Path: Path o nombre de la imagen con el mapa que se desea importar.
%      El mapa debe ser en blanco y negro, con los obst�culos en negro.
%      Se aceptan tanto im�genes .jpg como .png. Ejemplo: "Pent�gono.jpg". 
%
% Outputs:
%   - X: Matriz de (NoVertices x 2). Cada fila consiste de las coords. X de
%     los v�rtices de los obst�culos. La columna 1 contiene los v�rtices de
%     la cara inferior de los obst�culos y la columna 2 los v�rtices de la 
%     cara superior del obst�culo en 3D. Ambas columnas ser�n iguales 
%     porque la cara superior e inferior tienen las mismas coords X. Cabe 
%     mencionar que la primera y �ltima fila de cada columna son iguales 
%     para que la figura "cierre" al momento de graficarla. 
%   - Y: Matriz de (NoVertices x 2). Cada fila consiste de las coords. Y de
%     los v�rtices de los obst�culos. La columna 1 contiene los v�rtices de
%     la cara inferior de los obst�culos y la columna 2 los v�rtices de la 
%     cara superior del obst�culo en 3D. Ambas columnas son iguales porque 
%     las dos caras tienen las mismas coords. Y. La primera y �ltima fila 
%     son replicas para asegurar el cierre del pol�gono.
%   - Z: Matriz de (NoVertices x 2). Coords Z de los v�rtices que conforman
%     la geometr�a del obst�culo. La primera y �ltima coordenada son
%     replicas. La columna 1 consiste de la altura de la cara inferior y la
%     columna 2 de la altura de la cara superior del obst�culo en 3D.
% -------------------------------------------------------------------------
% 
% Opciones "Figura"
%
%   - Cilindro: Cilindro centrado en el origen con un radio que debe ser
%     especificado por el usuario.
%   - Poligono: El usuario puede dibujar un pol�gono que desee colocar en
%     el escenario como un obst�culo. En la ventana abierta, se muestra el
%     punto de partida y la meta a alcanzar para as� evitar dibujar el
%     pol�gono sobre estas regiones.
%   - Custom: El usuario puede alimentarle directamente los v�rtices de un
%     pol�gono previamente creado y la funci�n los adapta para que sean
%     compatibles con la forma requerida (Misma coordenada al inicio y al
%     final. Con offset y altura en Z) para polyshape().
%   - Imagen: El usuario puede alimentar al programa una imagen en blanco y
%     negro del mapa que desea, y este lo convierte autom�ticamente en un 
%     grupo de pol�gonos que pueden ser utilizados por el simulador para
%     recrear el ambiente en la mesa de trabajo. La imagen puede tener
%     cualquier dimensi�n. 
% 
% Nota: Si se desean graficar m�ltiples obst�culos a la vez, los v�rtices
% de cada obst�culo distinto deben estar separados por una fila de "NaNs".
%
% -------------------------------------------------------------------------

switch Figura
    case "Cilindro"
        Radio = varargin{1};
        [X,Y,Z] = cylinder(Radio);
        Z = Z * Altura;
        Z = Z + ZOffset;
        
        X = X';
        Y = Y';
        Z = Z';
    
    case "Poligono"
        % Extracci�n de los par�metros requeridos del Varargin
        LimsX = varargin{1};
        LimsY = varargin{2};
        Meta = varargin{3};
        BordesRegionPartida = varargin{4};
        
        % Creaci�n de figura
        figure('Name',"Creaci�n de Obst�culos",'NumberTitle',"off"); clf; 
        grid minor; hold on; axis equal;
        axis([LimsX(1) LimsX(2) LimsY(1) LimsY(2)]);
        
        % Indicador de Meta
        scatter(Meta(1),Meta(2),'x','red','LineWidth',2);
        text(Meta(1),Meta(2),"Meta",'VerticalAlignment','cap','HorizontalAlignment','center','Fontsize',7);
        
        % Indicador de la regi�n de partida
        VertsRegionPartida = [BordesRegionPartida(1,1) BordesRegionPartida(1,1) BordesRegionPartida(2,1) BordesRegionPartida(2,1) BordesRegionPartida(1,1) 
                              BordesRegionPartida(1,2) BordesRegionPartida(2,2) BordesRegionPartida(2,2) BordesRegionPartida(1,2) BordesRegionPartida(1,2)]';
        RegionPartida = polyshape(VertsRegionPartida);
        plot(RegionPartida,'Facealpha',0.2,'Facecolor','blue');
        text(BordesRegionPartida(1,1),BordesRegionPartida(2,2),"Region de Partida",'VerticalAlignment','bottom','HorizontalAlignment','left','Fontsize',7);
        
        Dibujo = drawpolygon();
        X = Dibujo.Position(:,1);
        Y = Dibujo.Position(:,2); 
        
        % Se agrega la primera pareja de coordenadas al final de todas las
        % dem�s coordenadas para que las funciones de patch() o fill()
        % cierren el pol�gono al dibujarlo.
        X = [X ; X(1)];
        Y = [Y ; Y(1)];
        
        % Cuando los pol�gonos se grafican en 3D, estos consisten de
        % b�sicamente una extrusi�n del pol�gono 2D en la direcci�n Z+.
        % Entonces la cara base y la cara superior van a tener las mismas
        % coordenadas X y Y, pero diferentes Z's. Por eso, se agrega una
        % columna adicional a X y Y replicando los datos ya existentes.
        X = repmat(X,1,2);
        Y = repmat(Y,1,2);
        
        % La altura preliminar del s�lido extruido es de 1 (Z = 0 para la
        % cara inferior y Z = 1 para la cara superior). 
        %   - Al multiplicar por "Altura" la cara superior se extiende 
        %     hasta llegar a la altura deseada. 
        %   - Al sumar el offset, la altura de las dos caras se modifica, 
        %     desplazando al pol�gono sobre el eje Z.
        Z = [zeros(size(X,1),1) ones(size(X,1),1)];
        Z  = Z * Altura;
        Z = Z + ZOffset;
        close(gcf);
    
    case "Custom"
        
        X = varargin{1};
        Y = varargin{2};
        
        X = repmat(X,1,2);
        Y = repmat(Y,1,2);
        
        Z = [zeros(size(X,1),1) ones(size(X,1),1)];
        Z  = Z * Altura;
        Z = Z + ZOffset;
        
    case "Imagen"
        
        Path = varargin{1};
        
        % Para m�s informaci�n sobre esta rutina se puede escribir "help
        % ImportadorMapa" en consola o se puede acceder al importador m�s
        % manual presente en la ruta base del toolbox.
        Vertices = ImportarMapa(Path);
        
        X = repmat(Vertices(:,1),1,2);
        Y = repmat(Vertices(:,2),1,2);
        
        Z = [zeros(size(X,1),1) ones(size(X,1),1)];
        Z  = Z * Altura;
        Z = Z + ZOffset;
end
        
end

