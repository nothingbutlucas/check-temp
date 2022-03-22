#!/bin/bash

# Autor: nothingbutlucas

#Colores | Gracias S4vitar <3

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

TERM_COLS="$(tput cols)"
TERM_ROWS="$(tput lines)"
# Función para capturar el ctrl_c y devolverle un output al usuario.
# También uso el tput cnorm para volver a activar el cursor que saque previamente con tput civis

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[X] Cerrando monitor de temperatura, gracias, vuelva prontos!\n${endColour}"
	tput cnorm
	exit 0
}

# print-centered function provided by TrinityCoder
# https://gist.github.com/TrinityCoder/911059c83e5f7a351b785921cf7ecdaa

function print-centered {
     [[ $# == 0 ]] && return 1

     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
     [[ $str_len -ge $TERM_COLS ]] && {
          echo "$1";
          return 0;
     }

     declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
     [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
     filler=""
     for (( i = 0; i < filler_len; i++ )); do
          filler="${filler}${ch}"
     done

     printf "%s%s%s" "$filler" "$1" "$filler"
     [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
     printf "\n"

     return 0
}

function banner(){
    echo -e "${purpleColour}"
    print-centered " _  /_ _  _  /____/__  _ _  ______  _   _/____._   _"
    print-centered "/_ / //_'/_ /\   / /_'/ / //_/  /_|/ //_/    //_/_\ "
    print-centered "                          /                  /      "
    print-centered "hecho por nothingbutlucas"
}

# Función para chequear la temperatura y hacer el print al user
function check-temp(){
    cpu=$(($(</sys/class/thermal/thermal_zone0/temp)/100))

    echo -e "\n${yellowColour}"
    print-centered "$(date +"%c") - $(whoami)@$(hostname)"
    echo -e "${endColour}"
    for i in $(seq 1 $TERM_COLS); do echo -ne "${purpleColour}-${endColour}"; done
    
    echo -e "${yellowColour}"
    print-centered "GPU -> $(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*') C°"
    print-centered "CPU -> ${cpu::2}.${cpu:2} Cº"
    # Hay 3 tipos de estados
    # Por debajo de los 60º (recomendado)
    # Por arriba de los 60º y debajo de los 79º (medio jugado, mejor ponele un fan)
    # Por arriba de los 79º (Acá ya puede empezar a fallar el funcionamiento de la raspberry)

    if test $((cpu/10)) -lt 60; then
    echo -e "${turquoiseColour}"
    print-centered "Tamo re tranqui"
    elif test $((cpu/10)) -gt 60 && test $((cpu/10)) -lt 79; then
        echo -e "${yellowColour}"

        print-centered "[-] La cosa se esta calentando..."
    else
        echo -e "${redColour}"
        print-centered "[!!] Ta quenchi la cosa"
    fi

    for i in $(seq 1 $TERM_COLS); do echo -ne "${purpleColour}-${endColour}"; done
}

function scan_wifi(){
    cp scan.txt previousscan.txt
    sudo nmap -n -sn --max-parallelism 100 "10.10.10.0/24" > scan.txt
    scan="scan.txt"
    echo -e "${yellowColour}"
    while read -r line;do
        if [[ $line == *"Nmap scan"* ]];then
            format_line=${line:21}
            if [[ $format_line == *"10.10.10.1" ]];then
                print-centered "$format_line - Router"
            elif [[ $format_line == *"10.10.10.2" ]];then
                print-centered "$format_line - Device 1"
            elif [[ $format_line == *"10.10.10.3" ]];then
                print-centered "$format_line - Device 2"
            elif [[ $format_line == *"10.10.10.4" ]];then
                print-centered "$format_line - Device 3"
            elif [[ $format_line == *"10.10.10.5" ]];then
                print-centered "$format_line - Device 4"
            elif [[ $format_line == *"10.10.10.6" ]];then
                print-centered "$format_line - Device 5"
            elif [[ $format_line == *"10.10.10.7" ]];then
                print-centered "$format_line - Device 6"
            elif [[ $format_line == *"10.10.10.11" ]];then
                print-centered "$format_line - Device 7"
            else
                print-centered "$format_line"
            fi
        fi
    done <$scan
    diff previousscan.txt scan.txt | grep "10.10." > difference.txt
    computers="difference.txt"
    echo -e "${redColour}"
    if [ -s $computers ];then
        while read -r computer;do
            iostring="${computer:0:1}"
            if [ "$iostring" == \> ]; then
                print-centered "[ + ] ${computer:23:11} connected [ + ]"
            elif [ "$iostring" == \< ]; then
                print-centered "[ - ] ${computer:23:11} disconnected [ - ]"
            fi
        done <$computers
    else
        print-centered "[ ~ ] No new devices [ ~ ]"
    fi
    for i in $(seq 1 $TERM_COLS); do echo -ne "${purpleColour}-${endColour}"; done
}

# Main

# Si el usuario es root se ejecuta la función anterior sin problema. Caso contrario, se ejecuta la función, pero se le hace un print diciendole que necesita ejecutar la herramienta como root

if [ "$(id -u)" == "0" ]; then
	tput civis
    banner
    touch scan.txt
	while true; do
        check-temp
        scan_wifi
		sleep 1800
	done

else
    tput civis
    banner
    touch scan.txt
	while true; do
    check-temp
    scan_wifi
    echo -e "\n${redColour}"
    print-centered "[!] Necesitas ejecutar la herramienta como root para poder ver la temperatura del GPU"
    echo -e "${endColour}"
	sleep 1800
	done
fi
