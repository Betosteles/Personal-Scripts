#!/usr/bin/env bash


function print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a <text>        Add text to find"
    echo "  -v <text>        Add text to avoid"
    echo "  -ra <regex>      Add regex to find"
    echo "  -rv <regex>      Add regex to avoid"
    return 1
}

function main() {
    
    local -a text_to_find 
    local -a text_to_avoid
    local -a regex_to_find 
    local -a regex_to_avoid

    while [[ $# -gt 0 ]]; do
        if [[ $1 == "-a" ]]; then
            text_to_find+=("$2")
            shift 2
        elif [[ $1 == "-v" ]]; then
            text_to_avoid+=("$2")
            shift 2
        elif [[ $1 == "-ra" ]]; then
            regex_to_find+=("$2")
            shift 2
        elif [[ $1 == "-rv" ]]; then
            regex_to_avoid+=("$2")
            shift 2
        elif [[ $1 == "--help" || $1 == "-h" ]]; then
            print_usage; return 1
        else
            print_usage; return 1
        fi
    done

    local line find avoid regex_find regex_avoid
   

    while read -r line; do
        local regex_history_cmd="^[[:space:]]*[0-9]+[[:space:]]+history"
        local regex_hk_cmd="^[[:space:]]*[0-9]+[[:space:]]+hk"

        if [[ $line =~ $regex_history_cmd || $line =~ $regex_hk_cmd ]]; then
            continue
        fi

        for find in "${text_to_find[@]}"; do
            if [[ $line != *"$find"* ]]; then
                continue 2
            fi
        done

        for avoid in "${text_to_avoid[@]}"; do
            if [[ $line == *"$avoid"* ]]; then
                continue 2
            fi
        done

        for regex_find in "${regex_to_find[@]}"; do
            if [[ ! $line =~ $regex_find ]]; then
                continue 2
            fi
        done

        for regex_avoid in "${regex_to_avoid[@]}"; do
            if [[ $line =~ $regex_avoid ]]; then
                continue 2
            fi
        done
        
        echo "$line"

    done < <(builtin history)
}

hk() { main "$@"; }