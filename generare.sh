#!/bin/bash

# Verificăm dacă s-a furnizat un director valid
if [ -z "$1" ]; then
    echo "Eroare: Nu ați furnizat niciun director!"
    echo "Utilizare: $0 <director>"
    exit 1
fi

# Directorul în care se vor crea linkurile simbolice și directoarele noi
target_dir="$1"

# Verificăm dacă directorul există
if [ ! -d "$target_dir" ]; then
    echo "Eroare: Directorul $target_dir nu există!"
    exit 1
fi

echo "Crearea directoarelor și linkurilor simbolice 'broken' în $target_dir..."

# Creăm 10 de directoare noi în target_dir
for i in {1..10}; do
    new_dir="$target_dir/new_directory_$i"
    mkdir -p "$new_dir"  # Creăm directoare noi
    echo "Director creat: $new_dir"
    
    # În fiecare director nou, vom crea 10 de linkuri simbolice "broken"
    for j in {1..10}; do
        # Definim un nume de fișier inexistent
        broken_file="$new_dir/broken_file_$j"
        # Creăm un link simbolic către fișierul inexistent
        # -f: rularea repetată nu mai eșuează cu "File exists"
        ln -sf "$broken_file" "$new_dir/link_to_broken_file_$j"
        
        # Creăm și un link simbolic care duce la un director inexistent
        broken_dir="$new_dir/broken_directory_$j"
        ln -sfn "$broken_dir" "$new_dir/link_to_broken_directory_$j"
    done
done

