#!/bin/bash

# Colores 
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
CYAN="\e[0;36m"
PURPLE="\e[0;35m"
# Reset (Obligatorio al final de cada eco para no pintar todo el terminal)
END="\e[0m"

# Sources
# Esto se rompe cuando intento definirlo en .zshrc

# Opcion 1
# Ahora la puedo llamar usando un alias y desde cualquier lugar (se debe guardar estos archivos de forma estática en una carpeta segura)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/enum_network_interfaces.sh"
source "${SCRIPT_DIR}/setup_workspace.sh"


function banner(){

echo -e "${RED}██ ███    ██ ██ ████████ ██   ██ ██     ██  ██████  ██████  ██   ██ ${NC}"
echo -e "${RED}██ ████   ██ ██    ██     ██ ██  ██     ██ ██    ██ ██   ██ ██  ██  ${NC}"
echo -e "${RED}██ ██ ██  ██ ██    ██      ███   ██  █  ██ ██    ██ ██████  █████   ${NC}"
echo -e "${PURPLE}██ ██  ██ ██ ██    ██     ██ ██  ██ ███ ██ ██    ██ ██   ██ ██  ██  ${NC}"
echo -e "${PURPLE}██ ██   ████ ██    ██    ██   ██  ███ ███   ██████  ██   ██ ██   ██ ${NC}" 

}


# Selección de tipo de escaneo
function choose_scan(){
    # ... (Bloque de selección de protocolo se mantiene igual) ...
    echo -e "\n${YELLOW}[?] Seleccione el protocolo a auditar en la fase de Footprinting:${END}"

    # Options array

    opciones_proto=(    "TCP" 
                        "UDP (Top 100 puertos)"    
                        "Ambos (TCP Completo + UDP Top 100)"
                    )
    
    # Menu de opciones interactivo
    select opt_proto in "${opciones_proto[@]}"; do
        case $REPLY in
            1|TCP|tcp) RUN_TCP=true; RUN_UDP=false; break;;
            2|UDP|udp) RUN_TCP=false; RUN_UDP=true; break;;
            3|AMBOS|ambos) RUN_TCP=true; RUN_UDP=true; break;;
            *) echo -e "${RED}[!] Opción inválida.${END}";;
        esac
    done

    echo -e "\n${YELLOW}[?] Seleccione el perfil de escaneo de Nmap:${END}"

    # Array
    opciones_perfil=(   "CTF SCAN (Agresivo)"  
                        "Standard Scan"        
                        "Secret Scan (Bypass IDS)" 
                    )
    
    # Menu interactivo interactivo
    select opt_perfil in "${opciones_perfil[@]}"; do
        case $REPLY in

        # Aqui puedes modificar los comandos de nmap para cada perfil, para personalizar el escaneo.
            1) 
                # Host Discovery & Port Discovery 

                # Aqui solo hacemos un escaneo muy rápido para detectar puertos abiertos, para no perder tiempo
                # detectando la version de todos los puertos y que vulnerabilidad tienen.
            
                echo -e "${CYAN}[i] Iniciando Fase 1: Descubrimiento de puertos abiertos...${END}"
                nmap -p- --open -sS -T5 --min-rate 5000 -Pn -n $IP_TARGET -oG fast_scan.gnmap > /dev/null
                

                # Extraemos los puertos: Buscamos la línea "Ports:", filtramos por "open" y limpiamos con cut/sed
                OPEN_PORTS=$(grep "Ports:" fast_scan.gnmap | cut -d':' -f3 | perl -lne 'print join ",", / (\d+)\/open/g')

                if [ -z "$OPEN_PORTS" ]; then
                    echo -e "${RED}[!] No se encontraron puertos abiertos. Abortando.${END}"
                    return
                fi
                rm fast_scan.gnmap
                echo -e "${GREEN}[+] Puertos detectados: $OPEN_PORTS${END}"

                # Ahora que tenemos los puertos abiertos, podemos hacer un escaneo más detallado solo sobre esos puertos
                # para ahorrar tiempo y recursos.
                echo -e "${CYAN}[i] Iniciando Fase 2: Enumeración detallada (-sCV) sobre puertos seleccionados...${END}"
                CMD_TCP="nmap -p$OPEN_PORTS -sCV -T5 --min-rate=4000 -Pn -n -vv"
                
                CMD_UDP="nmap --top-ports=700 --open -sU -T5 --min-rate=5000 -Pn -n -vv"
                break;;
            
            2) # Escaneo estándar 
                CMD_TCP="nmap -p- --open --min-rate 1700 -sV -n -Pn"
                CMD_UDP="nmap --top-ports 100 --open --max-retries 1 -sU -n -Pn"
                break;;


            3) 

               #  Rabbithole, Para que quieres ser sigoloso en un CTF? Si el objetivo es aprender y divertirte, no hay necesidad de ser sigiloso.
               #  Sin embargo, si quieres experimentar con técnicas de evasión, puedes usar opciones como --scan-delay, --randomize_hosts, o incluso técnicas de fragmentación de paquetes. 
               # Ten en cuenta que esto hará que el escaneo sea mucho más lento, y en un entorno de CTF puede no ser muy practico. 
               #
                echo "
                        ⠛⠛⣿⣿⣿⣿⣿⡷⢶⣦⣶⣶⣤⣤⣤⣀⠀⠀⠀
                        ⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀
                        ⠀⠀⠀⠉⠉⠉⠙⠻⣿⣿⠿⠿⠛⠛⠛⠻⣿⣿⣇⠀
                        ⠀⠀⢤⣀⣀⣀⠀⠀⢸⣷⡄⠀ ⣀⣤⣴⣿⣿⣿⣆
                        ⠀⠀⠀⠀⠹⠏⠀⠀⠀⣿⣧⠀⠹⣿⣿⣿⣿⣿⡿⣿
                        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠿⠇⢀⣼⣿⣿⠛⢯⡿⡟
                        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠦⠴⢿⢿⣿⡿⠷⠀⣿⠀
                        ⠀⠀⠀⠀⠀⠀⠀⠙⣷⣶⣶⣤⣤⣤⣤⣤⣶⣦⠃⠀
                        ⠀⠀⠀⠀⠀⠀⠀⢐⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
                        ⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀
                        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⠟
                "
            exit 1;;
            *) echo -e "${RED}[!] Opción inválida.${END}";;
        esac
    done
}

# Escaneo
function run_scan(){
    echo -e "\n${BLUE}[!] Iniciando fase de Enumeración sobre $IP_TARGET...${END}"
    
    # --- ESCANEO TCP ---
    if [ "$RUN_TCP" = true ]; then
        echo -e "\n${YELLOW}[*] Ejecutando escaneo TCP...${END}"
        
        # TCP scan with two outputs: *.xml (parser to html), *.txt (view on console)
        sudo $CMD_TCP $IP_TARGET -oX "$OUTPUT_PATH_xml/xtcp_scan.xml" -oN "$OUTPUT_PATH/tcp_scan.txt" > /dev/null 2>&1
        
        if command -v xsltproc &> /dev/null; then
            xsltproc "$OUTPUT_PATH_xml/xtcp_scan.xml" -o "$OUTPUT_PATH_html/scan_parser_tcp.html" 2>/dev/null

        fi

        # Parseamos el XML para mostrar un pequeño resumen en consola de los puertos abiertos y servicios detectasdos.
        echo -e "\n${GREEN}[+] Puertos TCP Abiertos:${END}"
        grep -E '<port protocol="tcp" porktid="|<service name="' "$OUTPUT_PATH_xml/xtcp_scan.xml" | \
        awk -v c="\033[1;36m" -v g="\033[1;32m" -v d="\033[1;30m" -v e="\033[0m" -F '"' '
            /portid/ {port=$4} 
            /service name/ {
                if ($4 != "") {
                    printf "  %s%s/tcp%s \t %sabierto%s \t %-15s ", c, port, e, g, e, $4;
                    for(i=1; i<=NF; i++) {
                        if ($i == " product=") printf " %s[ %s", d, $(i+1);
                        if ($i == " version=") printf " %s", $(i+1);
                    }
                    if ($0 ~ /product=/) printf " ]%s", e;
                    print "";
                }
            }'
    fi

    # --- ESCANEO UDP ---
    if [ "$RUN_UDP" = true ]; then
        echo -e "\n${YELLOW}[*] Ejecutando escaneo UDP...${END}"
        sudo $CMD_UDP $IP_TARGET -oX "$OUTPUT_PATH_xml/xudp_scan.xml" -oN "$OUTPUT_PATH/udp_scan.txt" > /dev/null 2>&1
        
        if command -v xsltproc &> /dev/null; then
            xsltproc "$OUTPUT_PATH_xml/xudp_scan.xml" -o "$OUTPUT_PATH_html/scan_parser_udp.html" 2>/dev/null
        fi

        echo -e "\n${GREEN}[+] Puertos UDP Abiertos o Filtrados:${END}"
        grep -E '<port protocol="udp" portid="|<service name="' "$OUTPUT_PATH_xml/xudp_scan.xml" | \
        awk -v c="\033[1;35m" -v g="\033[1;33m" -v d="\033[1;30m" -v e="\033[0m" -F '"' '
            /portid/ {port=$4} 
            /service name/ {
                if ($4 != "") {
                    printf "  %s%s/udp%s \t %sdetectado%s \t %-15s ", c, port, e, g, e, $4;
                    for(i=1; i<=NF; i++) {
                        if ($i == " product=") printf " %s[ %s", d, $(i+1);
                        if ($i == " version=") printf " %s", $(i+1);
                    }
                    if ($0 ~ /product=/) printf " ]%s", e;
                    print "";
                }
            }'
    fi
    
    echo -e "\n${GREEN}[+] Auditoría de red finalizada. Reportes guardados en $OUTPUT_PATH ${END}"
}

clear # Clean the terminal

# Llamando a las funciones
banner
show_interfaces
select_target
choose_scan
setup_workspace
run_scan