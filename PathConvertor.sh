#!/usr/bin/env bash

function convert_to_windows() {
    local input_file="$1"    

    # Si la ruta empieza con /mnt/ (ej: /mnt/c/...)
    if [[ "$input_file" =~ ^/mnt/[a-zA-Z] ]]; then
        echo "$input_file" | sed 's/\//\\/g' | sed -E 's/^(\\mnt\\)([a-z])/\U\2:/g'
    else
        # Si es una ruta nativa de Linux (ej: /home/kalva/...)
        local win_path
        win_path=$(echo "$input_file" | sed 's/\//\\/g')
        
        # Obtiene tu distribución actual de WSL automáticamente (ej: Ubuntu) o usa "Ubuntu" por defecto
        local distro="${WSL_DISTRO_NAME:-Ubuntu}"
        
        # Genera la ruta UNC de Windows para WSL
        echo "\\\\wsl.localhost\\$distro$win_path"
    fi

    exit 0
}

function convert_to_linux() {
    local input_file="$1"

    echo $1 | sed 's/\\/\//g' | sed -E 's/^([A-Za-z]):/\/mnt\/\L\1/g'
    exit 0
}

function explore_to_path() {

    local path="$1:-$PWD"

    if [[ -n "$path" && -d "$path" ]]; then
        explorer.exe .
        exit 0
    else
        echo "Directory not found: $path"
        exit 1
    fi
    
}

function print_usage() {
    echo "Usage: $(basename "$0") [-l | -w | -x] [path]"
    echo "  -l: Convert Windows path to Linux path"
    echo "  -w: Convert Linux path to Windows path"
    echo "  -x: Open the specified path in Windows Explorer"
    exit 1
}

function validations() {

    local param="$1"
    shift

    if [ -z $param ]; then
        convert_to_windows "$(pwd)"
        exit 0
    fi

    if [[ -n $1 && $# -gt 1 ]]; then
        echo "Error: Too many arguments provided."
        print_usage
        exit 1
    fi

}

function main() {
    
    validations "$@"

    local param="$1"
    shift

    case $param in
        -l)
            convert_to_linux "$1"
            ;;
        -w)
            convert_to_windows "$1"
            ;;
        -x)
            explore_to_path "$1"
            ;;
        -h|--help)
            print_usage
            ;;
        *)
            print_usage
            ;;
    esac
}

main "$@"

