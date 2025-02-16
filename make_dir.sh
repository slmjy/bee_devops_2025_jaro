#!/bin/bash

echo "Skript pro vytváření adresáře"
echo "@Jiří Frýda"
echo "-----------------------------"
echo "Skript spuštěn!"

# Funkce pro zobrazení nápovědy
show_help() {
#   echo "HELP"
    echo "Použití: $0 -dirMake -path \"cesta/k/adresáři\""
    echo "    -dirMake   - povel pro vytvoření adresáře"
    echo "    -path      - cesta, kde má být adresář vytvořen"
    echo ""
    echo "Příklad:"
    echo "    $0 -dirMake -path \"/tmp/novy_adresar\""
    echo ""
    echo "Nápověda:"
    echo "    Tento skript vytvoří adresář na zadané cestě."
    echo "    Pokud není zadaná cesta nebo je zadaná nesprávně, skript zobrazí chybu."
    echo "    Pokud nemáte práva pro zápis do složky, skript vás o tom informuje."
}

# Ověření, zda byly zadány potřebné argumenty
if [ $# -lt 1 ]&[ $# -gt 3 ]; then
    echo "Chyba: Špatný počet argumentů!"
#    show_help
    exit 1
fi

# Zpracování argumentů
while [[ $# -gt 0 ]]; do
    case $1 in
        -dirMake)
            dirMake=true
            shift
            ;;
        -path)
            path=$2
            shift
            shift
            ;;
        -h|--help)
            echo "HELP na vyžádání:"
	    show_help
            exit 0
            ;;
        *)
            echo "Neznámý argument: $1"
            show_help
            exit 1
            ;;
    esac
done

# Ověření, zda je cesta zadána
if [ -z "$path" ]; then
    echo "Chyba: Není zadána cesta pro vytvoření adresáře!"
    show_help
    exit 1
fi

# Ověření, zda máme práva pro zápis do cílové cesty
if [ ! -w "$(dirname "$path")" ]; then
    echo "Chyba: Nemáte práva pro zápis do cílové složky $(dirname "$path")!"
    exit 2
fi

# Vytvoření adresáře
if [ "$dirMake" = true ]; then
    if mkdir -p "$path"; then
        echo "Adresář $path byl úspěšně vytvořen."
        exit 0
    else
        echo "Chyba: Nepodařilo se vytvořit adresář $path."
        exit 3
    fi
else
    echo "Chyba: Argument -dirMake není správně zadán."
    exit 1
fi

