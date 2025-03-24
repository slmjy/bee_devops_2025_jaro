#!/bin/bash

# Funkce pro výpis nápovědy
help() {
    echo "Použití: $0 [možnosti]"
    echo "Možnosti:"
    echo "  -dirMake -path <cesta>   Vytvoří adresář na zadané cestě."
    echo "  -symlink -src <zdroj> -dest <cíl>  Vytvoří symbolický odkaz."
    echo "  -help                     Zobrazí tuto nápovědu."
    exit 0
}

# Funkce pro vytvoření adresáře
create_directory() {
    local path="$1"
    if [ -z "$path" ]; then
        echo "Chyba: Nebyla zadána cesta pro vytvoření adresáře." >&2
        exit 1
    fi
    mkdir -p "$path" && echo "Adresář '$path' byl úspěšně vytvořen." || { echo "Chyba: Nelze vytvořit adresář '$path'." >&2; exit 2; }
}

# Funkce pro vytvoření symbolického odkazu
create_symlink() {
    local src="$1"
    local dest="$2"
    if [ -z "$src" ] || [ -z "$dest" ]; then
        echo "Chyba: Musíte zadat zdroj a cíl symbolického odkazu." >&2
        exit 1
    fi
    ln -s "$src" "$dest" && echo "Symbolický odkaz '$dest' -> '$src' byl úspěšně vytvořen." || { echo "Chyba: Nelze vytvořit symbolický odkaz." >&2; exit 3; }
}

# Zpracování argumentů
while [[ $# -gt 0 ]]; do
    case "$1" in
        -help)
            help
            ;;
        -dirMake)
            shift
            if [[ "$1" == "-path" ]]; then
                shift
                create_directory "$1"
            else
                echo "Chyba: Chybí argument -path." >&2
                exit 1
            fi
            ;;
        -symlink)
            shift
            if [[ "$1" == "-src" ]]; then
                shift
                src="$1"
                shift
                if [[ "$1" == "-dest" ]]; then
                    shift
                    create_symlink "$src" "$1"
                else
                    echo "Chyba: Chybí argument -dest." >&2
                    exit 1
                fi
            else
                echo "Chyba: Chybí argument -src." >&2
                exit 1
            fi
            ;;
        *)
            echo "Neznámá volba: $1" >&2
            exit 1
            ;;
    esac
    shift
done

exit 0
