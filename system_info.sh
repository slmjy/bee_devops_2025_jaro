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
    echo "  -n               Zobrazí informace o síťových rozhraních."
    echo "  -t               Provede test spojení s beeit.cz."
    echo "  --build-docker --name <image_name>  Sestaví Docker image z Dockerfile."
    echo "  --remove-image --image-name <image_name>  Odstraní Docker image."
    echo "  --remove-image --all  Odstraní všechny Docker images."
    echo "  --show-container  Zobrazí všechny Docker kontejnery."
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

# Funkce pro zobrazení informací o síťových rozhraních
netInfo() {
    echo "=== Informace o síťových rozhraních ==="
    separator
    echo "Síťová rozhraní:"
    ip -o link show | awk -F': ' '{print $2}'
    separator
    echo "IP adresy:"
    ip -o addr show | awk '{print $2, $4}'
    separator
    echo "MAC adresy:"
    ip -o link show | awk '{print $2, $17}'
    separator
}

# Funkce pro provedení jednoho ping na adresu beeit.cz
netTest() {
    echo "=== Testování spojení s beeit.cz ==="
    separator
    ping -c 1 beeit.cz
    separator
}

# Funkce pro build Docker image
build_docker() {
    local image_name=$1
    
    if [ ! -f "Dockerfile" ]; then
        echo "Chyba: Dockerfile nebyl nalezen v aktuálním adresáři." >&2
        exit 1
    fi
    
    echo "=== Sestavování Docker image ==="
    separator
    docker build -t "$image_name" .
    if [ $? -eq 0 ]; then
        echo "Docker image '$image_name' byl úspěšně sestaven."
    else
        echo "Chyba: Nepodařilo se sestavit Docker image." >&2
        exit 1
    fi
    separator
}

# Funkce pro odstranění Docker image
remove_image() {
    local image_name=$1
    
    echo "=== Odstraňování Docker image ==="
    separator
    
    if [ "$image_name" == "--all" ]; then
        echo "Odstraňuji všechny Docker images..."
        images=$(docker images -q)
        if [ -z "$images" ]; then
            echo "Žádné images k odstranění."
        else
            docker rmi -f $images 2>/dev/null || {
                echo "Varování: Některé images se nepodařilo odstranit (možná jsou používány kontejnery)" >&2
                echo "Pro smazání všech kontejnerů a images použijte: docker system prune -a" >&2
            }
        fi
    else
        echo "Odstraňuji image '$image_name'..."
        if ! docker image inspect "$image_name" &>/dev/null; then
            echo "Chyba: Image '$image_name' neexistuje." >&2
            exit 1
        fi
        docker rmi "$image_name" || {
            echo "Chyba: Nepodařilo se odstranit image '$image_name'." >&2
            echo "Možná je používán běžícím kontejnerem. Zkuste nejprve odstranit kontejnery." >&2
            exit 1
        }
    fi
    
    echo "Operace úspěšně dokončena."
    separator
}

# Funkce pro zobrazení kontejnerů
show_containers() {
    echo "=== Seznam Docker kontejnerů ==="
    separator
    echo "Běžící kontejnery:"
    docker ps
    separator
    echo "Všechny kontejnery (běžící i stopnuté):"
    docker ps -a
    separator
}

# Detekce, jestli máme argumenty
if [ $# -eq 0 ]; then
    show_help
fi

# První zpracujeme dlouhé argumenty
while [[ $# -gt 0 ]]; do
    case "$1" in
        --build-docker)
            if [[ $# -lt 3 || "$2" != "--name" ]]; then
                echo "Chyba: Chybí název image. Použijte: --build-docker --name <image_name>" >&2
                exit 1
            fi
            build_docker "$3"
            shift 3
            ;;
        --remove-image)
            if [[ $# -lt 2 ]]; then
                echo "Chyba: Neplatný argument pro --remove-image" >&2
                exit 1
            fi
            case "$2" in
                --image-name)
                    if [[ $# -lt 3 ]]; then
                        echo "Chyba: Chybí název image. Použijte: --remove-image --image-name <image_name>" >&2
                        exit 1
                    fi
                    remove_image "$3"
                    shift 3
                    ;;
                --all)
                    remove_image "--all"
                    shift 2
                    ;;
                *)
                    echo "Chyba: Neplatný argument pro --remove-image" >&2
                    exit 1
                    ;;
            esac
            ;;
        --show-container)
            show_containers
            shift
            ;;
        --help)
            show_help
            ;;
        -*) # Přepneme na zpracování krátkých argumentů
            # Zpracování krátkých argumentů pomocí getopts
            OPTIND=1  # Reset getopts
            while getopts ":d:f:s:h:int" opt; do
                case ${opt} in
                    d) create_directory "$OPTARG" ;;
                    f) create_file "$OPTARG" ;;
                    s) 
                       if [[ $# -lt 3 ]]; then
                           echo "Chyba: Argument pro -s chybí cíl" >&2 
                           show_help
                       fi
                       create_soft_link "$OPTARG" "$3"
                       shift 2
                       ;;  
                    h) 
                       if [[ $# -lt 3 ]]; then
                           echo "Chyba: Argument pro -h chybí cíl" >&2
                           show_help
                       fi
                       create_hard_link "$OPTARG" "$3" 
                       shift 2
                       ;;  
                    i) show_sys_info ;;
                    n) netInfo ;;
                    t) netTest ;;
                    \?) echo "Neznámý příkaz: -$OPTARG" >&2; show_help ;;
                    :) echo "Chyba: Argument pro -$OPTARG chybí" >&2; show_help ;;
                esac
            done
            shift $((OPTIND-1))
            ;;
        *)
            echo "Neznámý příkaz: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

exit 0