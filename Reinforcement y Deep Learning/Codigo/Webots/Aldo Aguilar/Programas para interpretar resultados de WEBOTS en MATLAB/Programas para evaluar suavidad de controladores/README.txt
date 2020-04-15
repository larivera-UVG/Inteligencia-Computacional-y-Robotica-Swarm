Para analizar la suavidad de las señales de control generadas por cada controlador
se debe realizar lo siguiente:

1. Descargue todos los archivos .m de esta carpeta dentro de una misma carpeta en su PC
2. Ejecutar simulacion en WEBOTS utilizando 1er. controlador a analizar
3. En MATLAB, ejecutar código Smoothness_Logger.m (si es primera vez que se ejecuta
   descomentar lineas 9-12 del código, y volverlas a comentar luego de haber ejecutado el
   programa. Esto permitirá crear el archivo de Excel utilizado como Data Logger)
4. Ejecutar simulacion en WEBOTS utilizando 2do. controlador a analizar
5. Volver a ejecutar Smoothness_Logger.m
.
.
.
6. Al haber realizado este proceso para todos los controladores analizados,
   ejecutar código Box_Plotter.m para graficar diagramas de caja y bigote
   que muestran la distribución de los resultados de suavidad del control
   para cada controlador (Box_Plotter_Paper.m devuelve graficas ajustadas para Paper)