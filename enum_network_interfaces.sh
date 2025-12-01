#!/bin/bash

# Muestra todas las interfaces de la red y su estado
function show_interfaces(){
    echo -e "\n${ORANGE}[*] Analizando interfaces de red...${END}"
    
    # Definimos colores locales para awk
    ip -br addr show | awk -v p="\033[0;35m" -v g="\033[0;32m" -v c="\033[0;36m" -v e="\033[0m" \
    '{
        # Si el estado es DOWN, lo ponemos en rojo manualmente
        status_color = ($2 == "UP") ? g : "\033[0;31m";
        
        printf "  \033[1;30m»\033[0m Interfaz: %-10s | Estado: %s%-6s\033[0m | IP: %s%s\033[0m\n", p $1, status_color, $2, c, $3
    }'
}

# Selección de Interfaz y Segmento de Red (Host Discovery)
function select_target(){
    echo -e "\n${YELLOW}[?] Seleccione la interfaz de red para el escaneo:${END}"
    
    # Listamos dinámicamente los nombres de las interfaces disponibles
    mapfile -t INTERFACES < <(ip -br link show | awk '{print $1}')
    
    select IFACE in "${INTERFACES[@]}" ; do
        if [ -n "$IFACE" ]; then
            break
        else
            echo -e "${RED}[!] Opción inválida.${END}"
        fi
    done
    echo -e "${GREEN}[+] Interfaz seleccionada: $IFACE${END}"

    # Extraemos la IP asociada a la interfaz Perl regular expressions
    IFACE_IP=$(ip -4 addr show "$IFACE" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

    if [ -z "$IFACE_IP" ]; then
        echo -e "${RED}[!] No se detectó IP IPv4 en $IFACE. Se requiere entrada manual.${END}"
        read -rp "Ingrese la IP o rango objetivo completo (ej. 10.10.10.1-254): " IP_TARGET
    else
        # Extraemos los 3 primeros octetos (Porción de Red asumiendo máscara /24)
        #NETWORK_PREFIX=$(echo "$IFACE_IP" | cut -d'.' -f1-3)
        target_ip
    fi
}



function target_ip() {
        echo -e "[i] Tu IP actual en $IFACE es: ${BLUE}$IFACE_IP${END}"
        read -rp "[+] Enter IP TARGET: " HOST_INPUT
        # Acepta solo IP's, no va aceptar letras ejem;  hiIwanto,broke,Y0ur,Script
        IP_TARGET="$HOST_INPUT"
        # Expresión regular para una IPv4 válida (0-255 en cada octeto)
        RE_IPV4='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

        if [[ $HOST_INPUT =~ $RE_IPV4 ]]; then
            IP_TARGET="$HOST_INPUT"
            echo -e "${GREEN}[+] IP válida: $IP_TARGET${END}" 
            return 0
        else
            echo -e "${RED}[+] Error: '$HOST_INPUT' no es una dirección IPv4 válida.${END}"
            target_ip
            
        fi

    echo -e "\n${GREEN}[+] Objetivo configurado para el ataque: $IP_TARGET${END}"

}