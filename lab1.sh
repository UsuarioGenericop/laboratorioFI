#!/bin/bash
CALIDAD_MIN=0.0 #Declara la variable que servira para filtrar los articulos por calidad
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
            sort -nr -t, -k3 ca-net.csv| head | column -t -s "," #Se filtra con sort -n para ordenar por numeros -nr para ordenar numeros en orden inverso (de mayor a menor), -t, para indicar que el separador de las columnas es la coma, -k3 para indicar que se ordene por las entradas en la columna 3
        else #Si $argumento no esta vacio, se imprime el top $argumento
            sort -nr -t, -k3 ca-net.csv  | head -n "$argumento" | column -t -s "," #head -n "$argumento" para indicar que se imprima el top $argumento
        fi 
    elif [ "$input" == "sq" ] #evalua si el input es sq, en cuyo caso se modifica la variable CALIDAD_MIN
    then
        if [[ "$argumento" == "" ]] || (( $(echo "$argumento > 100" | bc -l) )) || (( $(echo "$argumento < 0" | bc -l) )) #si el argumento esta vacio es mayor a 100 o menor a 0
        # $ para evaluar el resultado del comando
        # bc -l evalua expresiones matematicas y devuelve 1 si es verdadero o 0 si es falso
        # si bc devuelve 1, entonces el argumento es invalido y se mantiene el valor de CALIDAD_MIN
        then
            CALIDAD_MIN="$CALIDAD_MIN" #se mantiene el valor de CALIDAD_MIN
            echo "$CALIDAD_MIN" #se imprime el valor de CALIDAD_MIN
        elif [[ $argumento =~ ^[0-9]+(\.[0-9]+)?$ ]] #evalua si el argumento es un numero, ya sea decimal o entero
        # [] permite definir un rango de caracteres y usar el =~
        # =~ permite evaluar si el argumento cumple con la expresion de la derecha retornando 0 si es verdadero y 1 si es falso
        # ^ indica que el argumento debe empezar con un numero
        # [0-9]+ indica que debe haber al menos un numero
        # + indica que debe aparecer el menos una vez
        # (\.[0-9]+)? indica que puede haber un punto seguido de al menos un numero, pero no es obligatorio
        # \. indica un punto el \ indica que debe ser un punto literal
        # ? indica que el grupo (\.[0-9]+) puede aparecer 0 o 1 veces
        # $ indica que el argumento debe terminar con un numero
        then
            CALIDAD_MIN="$argumento" #si el formato del argumento es correcto establece la variable CALIDAD_MIN con el valor del argumento
            echo "$CALIDAD_MIN"
        else
            CALIDAD_MIN="$CALIDAD_MIN" #en cualquier otro caso, se mantiene el valor de CALIDAD_MIN y se imprime
            echo "$CALIDAD_MIN"
        fi
    elif [ "$input" == "lnq" ] #evalua si el input es lnq, en cuyo caso se filtra por calidad con base a la variable CALIDAD_MIN
    then
        awk -F ',' -v calidad="$CALIDAD_MIN" 'NR > 1 && ($3+0) >= (calidad+0) {print $0}' ca-net.csv | sort -n -t, -k3 | head -n "$argumento" | column -t -s "," #se filtra con awk para que solo se impriman las entradas que cumplan con la condicion de calidad, luego se ordena de menor a mayor por la calidad y se imprime el top $argumento de entradas
        #awk invoca awk
        #-F ',' indica que el separador de columnas es la coma
        #-v calidad="$CALIDAD_MIN" pasa la variable CALIDAD_MIN a awk
        #'NR > 1 ' indica que se omita la primera linea del archivo (la cabecera)
        # && operador AND
        # ($3+0) >= (calidad+0) indica que se filtre por la columna 3 (calidad) y se compare con la variable calidad
        #se suma 0 para forzar una comparacion numerica esto evita una comparacion de texto donde 20.0 seria mayor que 100.0
    elif [ "$input" == "ea" ]
    then 
        awk -F ',' -v calidad="$CALIDAD_MIN" 'NR == 1 || ($3+0) >= (calidad+0)' ca-net.csv | sort -n -t, -k3 | column -t -s "," >> sup_"$CALIDAD_MIN".csv
        echo "sup_$CALIDAD_MIN.csv"
        echo "$(awk -F ',' -v calidad="$CALIDAD_MIN" 'NR > 1 && ($3+0) >= (calidad+0) {print $0}' ca-net.csv | wc -l) entradas"
    elif [ "$input" == "est" ]
    then
        awk -F ',' 'NR == 2 {min = max = $3 + 0} NR > 1 { total += 1; sum += $3; if (($3 + 0) >= 80.0) altaCalidad += 1; else if (($3 + 0) <= 20.0) bajaCalidad += 1; if ($3 + 0 < min) min = $3 + 0; if ($3 + 0 > max) max = $3 + 0 } {promedio = sum/total} END { print "=== ESTADÍSTICAS GENERALES DEL DATASET ==="; 
        print "Total de articulos procesados: " total; 
        print "Calidad minima: "min " || " "Calidad maxima: "max " || " "Calidad promedio: "promedio;
        print "Articulos de alta calidad (>= 80.0): "altaCalidad " || " altaCalidad/total*100 "%"; print "Articulos de baja calidad (<= 20.0): "bajaCalidad " || " bajaCalidad/total*100 "%"}' ca-net.csv
    elif [ "$input" == "web" ]
    then
        cut -d "," -f2 ca-net.csv | grep -qx -i -F "$argumento" && {
        titulo=$(echo "$argumento" | tr ' ' '_')
        codigo=$(curl -s -o "${titulo}.meta" -w "%{http_code}" "https://ca.wikipedia.org/api/rest_v1/page/summary/${titulo}")
        if [ "$codigo" = "404" ]; then
            echo "El artículo $argumento no existe."
        fi
        } || echo "No encontrado en el CSV."
        
    fi
done #Cierre del bucle infinito