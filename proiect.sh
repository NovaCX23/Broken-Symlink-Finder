#!/bin/bash

# Includem și fișierele ascunse; un director gol nu mai produce un "*" literal
shopt -s dotglob nullglob

# Funcția DFS pentru parcurgere
dfs() {
    local dir="$1"
    local real_dir
    real_dir=$(readlink -f "$dir")

    # Sărim peste directoarele deja vizitate (evităm buclele de linkuri și numărarea dublă)
    if [ -n "${visited[$real_dir]}" ]; then
        return
    fi
    visited["$real_dir"]=1

    echo "Analizăm directorul: $dir" >> output_directoare.txt

    # Parcurgem toate elementele din director
    local item
    for item in "$dir"/*; do
        # Verificăm dacă item-ul este un link simbolic
        if [ -L "$item" ]; then
            if [ ! -e "$item" ]; then
                echo "Broken symlink găsit: $item"
                ((broken_link_count++)) # Contorizăm link-urile broken
            elif [ "$follow_symlinks" -eq 1 ]; then
                # Obținem calea reală către directorul sau fișierul la care duce linkul simbolic
                local target
                target=$(readlink -f "$item")
                if [ -d "$target" ]; then
                    dfs "$target" # Continuăm recursiv dacă target-ul este director
                fi
            fi
        elif [ -d "$item" ]; then
            dfs "$item" # Apelăm recursiv pentru subdirectoare
        fi
    done
}

utilizare() {
    echo "Utilizare: $0 [--follow-symlinks] <director>"
}

# Verificăm dacă s-a dat un argument
if [ "$#" -lt 1 ]; then
    echo "Eroare: Nu ai furnizat niciun argument"
    utilizare
    exit 1
fi

# Inițializare variabile globale
follow_symlinks=0    # Flag pentru urmărirea linkurilor simbolice
start_dir=""         # Directorul de start
broken_link_count=0  # Contor pentru linkuri "broken"
declare -A visited   # Căile reale ale directoarelor deja vizitate

# Flag-ul --follow-symlinks poate apărea înainte sau după director
for arg in "$@"; do
    if [ "$arg" == "--follow-symlinks" ]; then
        follow_symlinks=1
    elif [ -z "$start_dir" ]; then
        start_dir="$arg"
    else
        echo "Eroare: Prea multe argumente"
        utilizare
        exit 1
    fi
done

# Debugging: afișăm valoarea directorului
echo "Directorul specificat: $start_dir"

# Verificăm dacă directorul a fost specificat și dacă este valid
if [ -z "$start_dir" ] || [ ! -d "$start_dir" ]; then
    echo "Eroare: Directorul specificat nu este valid!"
    utilizare
    exit 1
fi

# Suprascriem fișierul cu directoarele vizitate la fiecare rulare
: > output_directoare.txt

# Apelăm funcția DFS pe directorul de start
dfs "$start_dir"

# Afișăm numărul de linkuri simbolice "broken" găsite
echo "Număr total de linkuri simbolice broken găsite: $broken_link_count"

# Menționăm dacă a avut loc parcurgerea recursivă
if [ $follow_symlinks -eq 1 ]; then
    echo "S-a utilizat flag-ul --follow-symlinks pentru a analiza recursiv linkurile simbolice."
else
    echo "Nu s-a utilizat flag-ul --follow-symlinks. Linkurile simbolice nu au fost analizate recursiv."
fi

# Finalizare
echo "Verificare completă!"
