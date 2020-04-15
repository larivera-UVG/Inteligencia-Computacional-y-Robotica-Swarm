#include <math.h>
#include <stdio.h> 
#include <stdlib.h> 
#include <time.h> 
#include <string.h>

char base_dir[300] = "E:\\Escritorio\\Temporal\\Documentos\\Tesis\\Codigo\\Tesis Previas\\Aldo Aguilar\\Simulaciones WEBOTS\\Programas para interpretar resultados de WEBOTS en MATLAB";
char dirs[10][300];
char base_txt[300] = "\\epuck0.txt";
char txts[10][300];
char stringnum[2];
int rob_number = 0;

FILE *fp;

int main(){
    /* for (rob_number = 0; rob_number < 10; rob_number++)
    {
        strcpy(dirs[rob_number], base_dir);
        strcpy(txts[rob_number], base_txt);
        
        if(rob_number == 0){
            strcat(dirs[rob_number], txts[rob_number]);
        } else{
            itoa(rob_number, stringnum, 10);
            txts[rob_number][6] = stringnum[0]; 
            strcat(dirs[rob_number], txts[rob_number]);
            
        }
        printf("%s \n", dirs[rob_number]);
    }
    
    fp = fopen(dirs[0], "w"); */
    //fp = fopen("E:\\Escritorio\\Temporal\\Documentos\\Hola.txt", "w");
    int i;
    for (i = 0; i < 10; i++)
    {
        printf("%f\n", (rand() % RAND_MAX) / (double)RAND_MAX);
    }
    
}
