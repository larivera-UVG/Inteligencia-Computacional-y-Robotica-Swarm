function [Path] = preventFileOverwrite(Path)
% PREVENTFILEOVERWRITE Función que toma el path de un archivo o folder,
% revisa si el archivo existe y si este es el caso, modifica el path del
% archivo agregándole un número para prevenir la sobre-escritura del mismo.
% -------------------------------------------------------------------------
% Input:
%   - Path: String describiendo el path completo que apunta hacia un
%     archivo o carpeta.
%
% Output: 
%   - Path: Path corregido con un número agregado para evitar
%     sobre-escritura. En caso el archivo / folder no exista, se retorna el
%     mismo path inalterado.
%
% -------------------------------------------------------------------------
% 
% Ejemplo:
%
%   Path = ".\Output Media\Video\APF.mp4"
%   
%   Contenidos Folder:
%   - APF.mp4
%   - APF1.mp4
%   
%   if (Archivo ya existe)
%       Path = ".\Output Media\Video\APF2.mp4"
%   end
%
% -------------------------------------------------------------------------

% Se extrae el path base y la extensión del path ingresado
[PathBase,NombreArchivo,Extension] = fileparts(Path);
PathArchivo = PathBase + "\" + NombreArchivo;

% Número a agregar al final del nombre del archivo en caso ya exista el
% archivo.
Numero = 0;

% Si la carpeta ya existe se le agrega un número para evitar
% sobre-escritura.
while exist(Path,'file')

   % Si lo tiene, se borra el número adjunto al nombre del archivo.
   PathArchivo = erase(PathArchivo, num2str(Numero));

   % Se incrementa la cuenta del archivo y luego se agrega el siguiente
   % número en la secuencia en caso se requiera.
   Numero = Numero + 1; 
   Path = PathArchivo + num2str(Numero) + Extension;
end

end

