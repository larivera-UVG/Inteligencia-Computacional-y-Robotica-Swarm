1. Descargar los archivos .c y .wbt en una misma carpeta.
2. Descargar y abrir software de WEBOTS R2019b
3. En la barra de herramientas, hacer click en Wizards > New Robot Controller...
4. Click Next, seleccionar C y seleccionar Webots como IDE, nombrar controlador "e-puck_MPSO"
5. Ya creado el controlador, en la pantalla derecha de Webots se abre un script .c vacío.
   Copiar el código del archivo e-puck_MPSO.c a este archivo.
6. Click en el icono de Guardar que se encuentra sobre el script en Webots
7. En la barra de herramientas, hacer click en File > Open World y buscar el archivo 
   Simulacion1.wbt
8. Click F7 para compilar y cargar el controlador a los E-Puck.
9. Click en el icono de Play sobre la pantalla del mundo de Webots para comenzar simulacion.
10. Los robots convergen alrededor de los 10 segundos, y se puede pausar la simulacion.
11. Para reiniciar simuacion, click en el simbolo de Reload arriba de la pantalla del
    mundo de Webots.
12. Si se hace algún cambio a archivo .c del controlador, se debe presionar F7 cada vez
    y click en aceptar cuando Webots pregunte si se desea Recargar el mundo.

NOTA IMPORTANTE: El archivo e-puck_MPSO.c crea archivos de texto que almacenan resultados
de los E-Puck. Para guardarlos en localidad deseada hay que cambiarles el Path en la funcion
fopen("C:\\Users\\My User\\Documents ..."). Utilizar path deseado.