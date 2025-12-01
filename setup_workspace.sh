#!/bin/bash

function setup_workspace() {
    local choice
    while true; do
        read -rp "¿Deseas crear un entorno de trabajo para el pentesting? (y/n): " choice
        case "$choice" in
            [Yy])
                local MACHINE_NAME
                read -rp "Introduce el nombre de la máquina: " MACHINE_NAME
                local BASE_DIR="./$MACHINE_NAME"

                # Crear estructura principal
                mkdir -p "$BASE_DIR"/{smb,poc,exploit,content,ftp,ssh,http-s,database,nmap}

                # Crear subdirectorios de nmap
                mkdir -p "$BASE_DIR/nmap"/{html,xml}

                printf "%b\n" "${GREEN}[+] Estructura de directorios creada en $BASE_DIR${END}"

                OUTPUT_PATH="$BASE_DIR/nmap"
                OUTPUT_PATH_HTML="$BASE_DIR/nmap/html"
                OUTPUT_PATH_XML="$BASE_DIR/nmap/xml"
                break
                ;;
            [Nn])
                # Solo mostrara el escaneo nmap tradicional y guardara el output en el directorio actual
                OUTPUT_PATH="."
                OUTPUT_PATH_HTML="."
                OUTPUT_PATH_XML="."
                break
                ;;
            *)
                printf "%b\n" "${RED}[!] Opción incorrecta. Por favor ingresa y o n.${END}"
                ;;
        esac
    done
}