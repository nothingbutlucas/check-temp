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
last_column=$(( ( $TERM_COLS / 4 ) * 2 ))
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

function print-first-column {
     [[ $# == 0 ]] && return 1

     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
     [[ $str_len -ge $TERM_COLS ]] && {
          echo "$1";
          return 0;
     }
     declare -i filler_len="$(( ( ( TERM_COLS / 3 ) - str_len) / 2 ))"
     [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
     filler=""
     for (( i = 0; i < filler_len; i++ )); do
          filler="${filler}${ch}"
     done

     printf "%s%s%s" "$filler" "$1" "$filler"
     [[ $(( ( ( TERM_COLS % 3 ) - str_len ) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
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
    tput cup 5 $last_column
    cpu=$(($(</sys/class/thermal/thermal_zone0/temp)/100))
    echo -e "${yellowColour}$(date +"%c") - $(whoami)@$(hostname)${endColour}"
    for i in $(seq 1 $TERM_COLS); do echo -ne "${purpleColour}-${endColour}"; done
    tput cup 7 $last_column
    echo -e "${yellowColour}  GPU -> $(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*') C°"
    tput cup 9 $last_column
    echo -e "CPU -> ${cpu::2}.${cpu:2} Cº"
    # Hay 3 tipos de estados
    # Por debajo de los 60º (recomendado)
    # Por arriba de los 60º y debajo de los 79º (medio jugado, mejor ponele un fan)
    # Por arriba de los 79º (Acá ya puede empezar a fallar el funcionamiento de la raspberry)
    tput cup 11 $last_column
    if test $((cpu/10)) -lt 60; then
        echo -e "${turquoiseColour}Tamo re tranqui"
    elif test $((cpu/10)) -gt 60 && test $((cpu/10)) -lt 79; then
        echo -e "${yellowColour}[ - ] La cosa se esta calentando..."
    else
        echo -e "${redColour}[ !! ] Ta quenchi la cosa"
    fi

    for i in $(seq 1 $TERM_COLS); do echo -ne "${purpleColour}-${endColour}"; done
}

function scan_wifi(){
    cp scan.txt previousscan.txt
    sudo nmap -n -sn --max-parallelism 100 "10.10.10.0/24" > scan.txt
    scan="scan.txt"
    while IFS= read -r line;do
        if [[ $line == *"Nmap scan"* ]];then
            format_line=${line:21}
            if [[ $format_line == *"10.10.10.1" ]];then
                echo -e "$format_line - Router - $(date +"%c")" > connected_devices.txt
            elif [[ $format_line == *"10.10.10.2" ]];then
                echo -e "$format_line - Device 1 - $(date +"%c")" >> connected_devices.txt
            elif [[ $format_line == *"10.10.10.3" ]];then
                echo -e "$format_line - Device 2 - $(date +"%c")" >> connected_devices.txt
            elif [[ $format_line == *"10.10.10.4" ]];then
                echo -e "$format_line - Device 3 - $(date +"%c")" >> connected_devices.txt
            elif [[ $format_line == *"10.10.10.5" ]];then
                echo -e "$format_line - Device 4 - $(date +"%c")" >> connected_devices.txt
            elif [[ $format_line == *"10.10.10.6" ]];then
                echo -e "$format_line - Device 5 - $(date +"%c")" >> connected_devices.txt
            elif [[ $format_line == *"10.10.10.7" ]];then
                echo -e "$format_line - Device 6 - $(date +"%c")" >> connected_devices.txt
            elif [[ $format_line == *"10.10.10.8" ]];then
                echo -e "$format_line - Device 7 - $(date +"%c")" >> connected_devices.txt
            elif [[ $format_line == *"10.10.10.11" ]];then
                echo -e "$format_line - Device 8 - $(date +"%c")" >> connected_devices.txt
            else
                echo -e "$format_line - $(date +"%c")" >> connected_devices.txt
            fi
        fi
    done <$scan
    diff previousscan.txt scan.txt | grep "10.10." > difference.txt
    computers="difference.txt"
    echo -e "${redColour}"
    if [ -s $computers ];then
        while IFS= read -r computer;do
            iostring="${computer:0:1}"
            if [ "$iostring" == \< ]; then
                if [ ! -z $(grep "${computer:23:12}" "disconnected_devices.txt") ];then
                    nothing="nothing"
                else
                    echo -e "${computer:23:12} - Miller - $(date +"%c")" >> disconnected_devices.txt
                fi
            fi
        done <$computers
    fi
}

function print_lines(){
    echo -e "${yellowColour}"
    disconnected_devices="disconnected_devices.txt"
    connected_devices="connected_devices.txt"
    echo -e " Disconnected Devices"
    while IFS= read -r line;do
        if [ ! -z $(grep "${line:0:11}" "connected_devices.txt") ];then
            nothing="nothing"
        else
            echo -e " $line"
        fi
    done <$disconnected_devices
    tput cup 14 $last_column
    echo -e "Connected Devices"
    row=15
    while IFS= read -r line;do
        tput cup $row $last_column
        echo -e "$line"
        ((row++))
    done <$connected_devices
    for i in $(seq 1 $TERM_COLS); do echo -ne "${purpleColour}-${endColour}"; done
}

# Main

# Si el usuario es root se ejecuta la función anterior sin problema. Caso contrario, se ejecuta la función, pero se le hace un print diciendole que necesita ejecutar la herramienta como root

if [ "$(id -u)" == "0" ]; then
	tput civis
    clear
    banner
    #touch scan.txt
    check-temp
    scan_wifi
    print_lines
	while true; do
        check-temp
        if [ "$(date +"%M%S")" == "4510" ]; then
            clear
            banner
            check-temp
            scan_wifi
            print_lines
        fi
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
