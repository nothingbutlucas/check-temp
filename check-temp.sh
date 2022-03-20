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

# Función para capturar el ctrl_c y devolverle un output al usuario.
# También uso el tput cnorm para volver a activar el cursor que saque previamente con tput civis

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[X] Cerrando monitor de temperatura, gracias, vuelva prontos!\n${endColour}"
	tput cnorm
	exit 0
}
function banner(){
    echo -e "\n${purpleColour}"
    echo -e " _  /_ _  _  /____/__  _ _  ______  _   _/____._   _"
    echo -e "/_ / //_'/_ /\   / /_'/ / //_/  /_|/ //_/    //_/_\ "
    echo -e "                          /                  /     hecho por nothingbutlucas"
    echo -e "${endColour}"
}
# Función para chequear la temperatura y hacer el print al user
function check-temp(){
    cpu=$(($(</sys/class/thermal/thermal_zone0/temp)/100))

    echo -e "\n${yellowColour}$(date) @ $(hostname)\n${endColour}"
    for i in $(seq 1 20); do echo -ne "${purpleColour}-${endColour}"; done
    echo -e "\n${greenColour}[+]${endColour} ${yellowColour}GPU -> $(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*') C°${endColour}"
    echo -e "\n${greenColour}[+]${endColour} ${yellowColour}CPU -> ${cpu::2}.${cpu:2} Cº"

    # Hay 3 tipos de estados
    # Por debajo de los 60º (recomendado)
    # Por arriba de los 60º y debajo de los 79º (medio jugado, mejor ponele un fan)
    # Por arriba de los 79º (Acá ya puede empezar a fallar el funcionamiento de la raspberry)

    if test $((cpu/10)) -lt 60; then
    echo -e "\n${turquoiseColour}[+] Tamo re tranqui${endColour}"
    elif test $((cpu/10)) -gt 60 && test $((cpu/10)) -lt 79; then
    echo -e "\n${yellowColour}[-] La cosa se esta calentando...${endColour}"
    else
    echo -e "\n${redColour}[!!] Ta quenchi la cosa${endColour}"
    fi

    for i in $(seq 1 20); do echo -ne "${purpleColour}-${endColour}"; done
}

function scan_wifi(){
    cp scan.txt previousscan.txt
    sudo nmap -n -sn "10.10.10.*" > scan.txt
    scan=$(<scan.txt)
    format_scan_1=$(cat scan.txt | grep 10.10 -A 2 | grep -v -E "Host|scanned")
    echo -e ${yellowColour} ${format_scan_1//"Nmap scan report for "/\\n[ ~ ]}${endColour}
    message=$(diff previousscan.txt scan.txt | grep 10.10)
    iostring="${message:0:1}"
    computer="${message:23:11}"
    if [ "$iostring" = \> ]; then
        echo -e ${redColour}[ + ]$computer connected${endColour}
    fi
    if [ "$iostring" = \< ]; then
        echo -e ${redColour}[ - ]$computer disconnected${endColour}
    fi
}

# Main

# Si el usuario es root se ejecuta la función anterior sin problema. Caso contrario, se ejecuta la función, pero se le hace un print diciendole que necesita ejecutar la herramienta como root

if [ "$(id -u)" == "0" ]; then
	tput civis
    touch scan.txt
	while true; do
        banner
        check-temp
        scan_wifi
		sleep 1800
	done

else
	while true; do
    touch scan.txt
    banner
    check-temp
    scan_wifi
	echo -e "\n${redColour}[!] Necesitas ejecutar la herramienta como root para poder ver la temperatura del GPU${endColour}"
	sleep 1800
	done
fi
