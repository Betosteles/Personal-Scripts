#!/usr/bin/env bash

fetch=$(git fetch --prune 2>&1)

error_regex="^(fatal|error):"

if [[ $fetch =~ $error_regex ]]; then
    echo "Error: No se pudo obtener la información del repositorio remoto."
    echo "$fetch"
    exit 1
fi

mapfile -t ramas_locales < <(git branch --format='%(refname:short)')

select rama in "${ramas_locales[@]}"; do
    if [[ -n $rama ]]; then
        echo "Cambiando a la rama: $rama..."
        git checkout "$rama"
        git pull
        break
    else
        echo "Selección inválida. Por favor, elige una opción válida."
    fi
done

git fetch --prune

ramas_huerfanas=$(git branch -vv | awk '/: gone]/{print $1}')

if [[ -n $ramas_huerfanas ]]; then
    echo "Ramas huérfanas encontradas:"
    echo "$ramas_huerfanas" | xargs git branch -D
else
    echo "No se encontraron ramas huérfanas."
fi
