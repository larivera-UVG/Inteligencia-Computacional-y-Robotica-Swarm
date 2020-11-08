function [DistsEntrePart] = getDistsBetweenParticles(Posicion_Actual, FormaMatriz)
% GETDISTSBETWEENPARTICLES Funci�n que retorna todas las distancias
% existentes entre todas las combinaciones posibles de part�culas en la
% forma de una matriz cuadrada con dimensiones de "NoParticulas" x 
% "NoParticulas". El usuario puede especificar la forma que desea que tenga
% la matriz: Triangular superior (solo los elementos de la secci�n
% triangular superior) o full (con todos los elementos intactos).
% -------------------------------------------------------------------------
% Input: 
%   - Posicion_Actual: Posici�n actual de las part�culas. Cada columna de 
%     la matriz debe corresponder a las coords. (X,Y) de las part�culas. 
%     Dims = "NoParticulas" x 2
%   - FormaMatriz: Forma que tendr� la matriz de distancias retornada.
%     Existen dos opciones: "Triangular y "Full". Para "Triangular" se
%     retorna la matriz triangular superior sin distancias repetidas o 
%     distancias entre un punto y si mismo. En "Full" se retorna la matriz 
%     completa sin realizar el filtrado previamente especificado.
%
% Output: 
%   - DistsEntrePart: Distancias entre part�culas. Cada fila y columna con 
%     el mismo index corresponde a una part�cula. Por ejemplo: Fila = 
%     Columna = 1 corresponden a la part�cula 1, Fila = Columna = 2 
%     corresponden a la part�cula 2, etc. Entonces si se indexa la matriz 
%     como (1,2) o (2,1) se obtendr� la distancia entre la part�cula 1 y 2. 
%
% ------------------------------------------------------------------------- 
% Ejemplo: 
%   Con 3 part�culas, esta funci�n inicialmente obtiene
%
%   DistsEntrePart =        P1    P2    P3
%                    P1 |  d11   d12   d13  |
%                    P2 |  d21   d22   d23  |
%                    P3 |  d31   d32   d33  |
%
%   Debido a que la distancia entre una part�cula y si misma es 0, la
%   matriz se puede reexpresar de la siguiente manera
%
%   DistsEntrePart =        P1    P2    P3
%                    P1 |   0    d12   d13  |
%                    P2 |  d21    0    d23  |
%                    P3 |  d31   d32    0   |
%
%   Las distancias d21, d31 y d32 son r�plicas de d12, d13 y d23 entonces
%   si "FormaMatriz" = 'Triangular' se elimina la redundancia eliminando la 
%   secci�n triangular inferior de la matriz usando "triu()". De lo
%   contrario si se utiliza "FormaMatriz" = 'Full', se retorna la matriz
%   en el estado del ultimo paso descrito.
%
%   DistsEntrePart =        P1    P2    P3
%                    P1 |   0    d12   d13  |
%                    P2 |   0     0    d23  |
%                    P3 |   0     0     0   |
%
%   Finalmente, para evitar cualquier problema al momento de introducir la
%   matriz en la funci�n "SolveCollisions()" todos los ceros de la matriz
%   se convierten en NaN's.
%
%   DistsEntrePart =        P1    P2    P3
%                    P1 |  NaN    d12   d13  |
%                    P2 |  NaN    NaN   d23  |
%                    P3 |  NaN    NaN   NaN  |
%
% ------------------------------------------------------------------------- 

    NoParticulas = size(Posicion_Actual,1);

    MatrizPosX = repelem(Posicion_Actual(:,1), 1, NoParticulas);   	% Coordenadas X de posici�n se repiten "NoParticulas" veces a la derecha 
    MatrizPosY = repelem(Posicion_Actual(:,2), 1, NoParticulas);   	% Coordenadas Y de posici�n se repiten "NoParticulas" veces a la derecha 
    DifPosX = MatrizPosX - Posicion_Actual(:,1)';                 	% A cada fila de las coordenadas X/Y "repetidas" se le restan las posiciones X/Y actuales en fila.
    DifPosY = MatrizPosY - Posicion_Actual(:,2)';                	% Hecho para obtener la diferencia de posici�n X/Y entre todas las combinaciones posibles de part�culas
    
    DistsEntrePart = sqrt(DifPosX .^2 + DifPosY .^2);               % Todas las distancias existentes entre part�culas. Matriz de "NoParticulas" x "NoParticulas"
    
    switch FormaMatriz
        case "Triangular"
            DistsEntrePart = triu(DistsEntrePart);                  % La data por encima y debajo de la diagonal son duplicados de los mismos datos. Se elimina el "triangulo" inferior.
            Mascara = triu(ones(NoParticulas),1);                   % Matriz cuadrada de unos de NoParticulas x NoParticulas. La secci�n triangular inferior (Incluyendo la diagonal) se iguala a 0
            Mascara(Mascara == 0) = NaN;                        	% Los ceros de la matriz de m�scara se reemplazan por NaN's
            DistsEntrePart = Mascara .* DistsEntrePart;           	% Para ignorar las distancias entre una part�cula y si misma, y las distancias redundantes, se le aplica la m�scara a la matriz de distancias
    
        case "Full"
            % Se mantiene la matriz igual 
            
    end
end

