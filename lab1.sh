#!/bin/bash
CALIDAD_MIN=0.0
while true #Bucle infinito que se ejecuta hasta que el usuario ingrese "q" para salir
do  
    #No se imprime un mensaje solicitando input para minimizar el numero de mensajes que se muetra al usuario
    read input argumento #lee el input del usuario y lo guarda en una variable
    if [ "$input" == "q" ] #evalua si el input es q, en cuyo caso se sale del programa
    then
        echo "Saliendo de la aplicacion de analisis de la Wikipedia.."
        exit 0  #Se sale del programa con un codigo de salida 0, indicando que no hubo errores

    elif [ "$input" == "ca" ] #evalua si el input es ca, en cuyo caso se busca el argumento en el archivo ca-net.csv
    then
        echo "$(grep -i "$argumento" ca-net.csv | wc -l) entradas" #Se imprime el numero de entradas que coinciden con el argumento
        grep -i "$argumento" ca-net.csv | head | column -t -s "," #Se imprime las primeras 10 entradas que coinciden con el argumento, formateadas en columnas y separadas por comas
    elif [ "$input" == "at" ] #Evalua si el input es at, en cuyo caso se busca el argumento en el archivo ca-net.csv, pero solo en los primero caracteres de la columna 2
    then
        echo "$(cut -d "," -f 2- ca-net.csv | grep -i "^$argumento" | wc -l) entradas" #Se imprime el numero de entradas que coinciden con el argumento
        cut -d "," -f 2- ca-net.csv | sort | grep -i "^$argumento" | head -n 5 | column -t -s "," #Se imprime las primeras 5 entradas que coinciden con el argumento, formateadas en columnas y separadas por comas
    
    elif [ "$input" == "top" ] #Evalua si el input es top, en cuyo caso se filtra de mayor a menor por la columna 3
    then 
        if [ "$argumento" == "" ] #Revisa si $argumento esta vacio, en cuyo caso se imprime el top 10 por defecto
        then 
            sort -nr -t, -k3 ca-net.csv| head | column -t -s ","
        else #Si $argumento no esta vacio, se imprime el top $argumento
            sort -nr -t, -k3 ca-net.csv  | head -n "$argumento" | column -t -s ","
        fi 
    elif [ "$input" == "sq" ]
    then
        if [[ "$argumento" == "" ]] || (( $(echo "$argumento > 100" | bc -l) )) || (( $(echo "$argumento < 0" | bc -l) ))
        then
            CALIDAD_MIN="$CALIDAD_MIN"
            echo "$CALIDAD_MIN"
        elif [[ $argumento =~ ^[0-9]+(\.[0-9]+)?$ ]]
        then
            CALIDAD_MIN="$argumento"
            echo "$CALIDAD_MIN"
        else
            CALIDAD_MIN="$CALIDAD_MIN"
            echo "$CALIDAD_MIN"
        fi
    elif [ "$input" == "lnq" ]
    then
        awk -F ',' -v calidad="$CALIDAD_MIN" 'NR > 1 && ($3+0) >= (calidad+0) {print $0}' ca-net.csv | sort -n -t, -k3 | head -n "$argumento" | column -t -s ","
    fi
done #Cierre del bucle infinito