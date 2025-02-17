#!/bin/bash

# Funkce pro oddělovač
separator() {
    echo "---------------------------------------------"
}

# Funkce pro zobrazení nápovědy
show_help() {
    echo "Použití: $0 [příkazy]"
    echo "Příkazy:"
    echo "  -d <cesta>       Vytvoří adresář na zadané cestě."
    echo "  -f <cesta>       Vytvoří soubor na zadané cestě (nepřepíše existující)."
    echo "  -s <zdroj> <cíl> Vytvoří soft link (zkontroluje existenci zdroje)."
    echo "  -h <zdroj> <cíl> Vytvoří hard link (zkontroluje existenci zdroje)."
    echo "  -i               Zobrazí informace o systému."
    exit 1
}

# Funkce pro zobrazení informací o systému
show_sys_info() {
    echo "=== Informace o systému ==="
    separator
    echo "Operační systém: $(lsb_release -d | cut -f2)"
    echo "Verze jádra: $(uname -r)"
    echo "Doba běhu systému: $(uptime -p | sed 's/up //')"
    separator
    echo "=== Informace o CPU ==="
    separator
    echo "Model CPU: $(grep -m 1 "model name" /proc/cpuinfo | cut -d':' -f2 | xargs)"
    separator
    echo "=== Informace o uživateli ==="
    separator
    echo "Přihlášený uživatel: $(whoami)"
    echo "Vytvořil: Tomáš Drenko"
    separator
}

# Funkce pro vytvoření adresáře
create_directory() {
    local path=$1
    if mkdir -p "$path"; then
        echo "Adresář byl úspěšně vytvořen: $path"
    else
        echo "Chyba: Nelze vytvořit adresář $path." >&2
        exit 1
    fi
}

# Funkce pro vytvoření souboru (nepřepíše existující)
create_file() {
    local path=$1
    if [[ -e "$path" ]]; then
        echo "❗ Soubor již existuje: $path"
    else
        if echo "Text vložený pomocí příkazu." > "$path"; then
            echo "Soubor byl úspěšně vytvořen: $path"
        else
            echo "Chyba: Nelze vytvořit soubor $path." >&2
            exit 1
        fi
    fi
}

# Funkce pro vytvoření soft linku
create_soft_link() {
    local source=$1
    local dest=$2
    if [[ ! -e "$source" ]]; then
        echo "Chyba: Zdrojový soubor/adresář neexistuje: $source" >&2
        exit 1
    fi
    if ln -s "$source" "$dest"; then
        echo "Soft link byl úspěšně vytvořen: $dest -> $source"
    else
        echo "Chyba: Nelze vytvořit soft link $dest -> $source." >&2
        exit 1
    fi
}

# Funkce pro vytvoření hard linku
create_hard_link() {
    local source=$1
    local dest=$2
    if [[ ! -f "$source" ]]; then
        echo "Chyba: Zdrojový soubor neexistuje nebo není regulérní soubor: $source" >&2
        exit 1
    fi
    if ln "$source" "$dest"; then
        echo "Hard link byl úspěšně vytvořen: $dest -> $source"
    else
        echo "Chyba: Nelze vytvořit hard link $dest -> $source." >&2
        exit 1
    fi
}

# Zpracování argumentů pomocí getopts
while getopts ":d:f:s:h:i" opt; do
    case ${opt} in
        d) create_directory "$OPTARG" ;;
        f) create_file "$OPTARG" ;;
        s) create_soft_link "$OPTARG" "${!OPTIND}"; shift ;;  
        h) create_hard_link "$OPTARG" "${!OPTIND}"; shift ;;  
        i) show_sys_info ;;
        \?) echo "Neznámý příkaz: -$OPTARG" >&2; show_help ;;
        :) echo "Chyba: Argument pro -$OPTARG chybí" >&2; show_help ;;
    esac
done

exit 0
