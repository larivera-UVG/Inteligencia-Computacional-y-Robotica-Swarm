function [X,Y,Z] = DrawObstacles(Figura,Altura,ZOffset,varargin)
% DRAWOBSTACLES Función que permite decidir la forma de los obstáculos que
% se desplegarán sobre el escenario y en base a esto genera las coordenadas
% necesarias para graficar los mismos de forma bidimensional o
% tridimensional. 
%
%   - Gráficas bidimensionales: plot(X(:,1), Y(:,1))
%   - Gráficas tridimensionales: surf(X,Y,Z) para paredes 
%                                fill3(X(:,2),Y(:,2),Z(:,2)) para tapa 
%
% NOTA: La altura que retorna

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
        PosMin = varargin{1};
        PosMax = varargin{2};
        figure(); clf; grid on;
        axis([PosMin PosMax PosMin PosMax]);
        Dibujo = drawpolygon();
        X = Dibujo.Position(:,1);
        Y = Dibujo.Position(:,2); 

        X = [X ; X(1)];
        Y = [Y ; Y(1)];

        X = repmat(X,1,2);
        Y = repmat(Y,1,2);
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
        
end

