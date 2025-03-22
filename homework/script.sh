#!/bin/bash

echo
echo "============================================================================================================================================="
echo "                                                     Informace o tvém síťovém rozhraní                                                       "
echo "============================================================================================================================================="
echo

ETH="$(ifconfig | grep -i -m 1 "eth0")"
echo $ETH
echo
echo -e "$(ifconfig | grep -oP 'mtu \K\d+' | awk '{print "mtu:\t\t" $0}')"
echo
echo -e "$(ifconfig | grep -oP 'inet \K\d+\.\d+\.\d+\.\d+' | awk '{print "IP4v:\t\t" $0}')"
echo
echo -e "$(ifconfig | grep -oP 'netmask \K\d+\.\d+\.\d+\.\d+' | awk '{print "Netmask:\t" $0}')"
echo
echo -e "$(ifconfig | grep -oP 'broadcast \K\d+\.\d+\.\d+\.\d+' | awk '{print "Broadcast:\t" $0}')"
echo
echo -e "$(ifconfig | grep -m 1 -oP 'inet6 \K([0-9A-Fa-f:]+)' | awk '{print "IP6v:\t\t" $0}')"
echo
echo -e "$(ip route show default | awk '{print "Default gateway: "$3}')"
echo 
cat -e /etc/resolv.conf | grep "nameserver" | awk '{print "nameserver:\t" $2}'


# -oP = vrátí pouze nalezené odpovídající části řádku (ne celý ř) a P umožní \K
# \K = zahodí vše co je před ether
# [0-9A-Fa-f] = regulární výraz, který odpovídá hexadecimalnimu znaku
# {2} = přesně 2 znaky
# [:-] = bude oddělený dvojtečkou nebo pomlčkou
# {5} = najde prvních 5 bloků
# na konci přidám ještě jednou regularni vyraz kdyby byla mac adresa delsi nez 5 hegadecimalnich znaku
# {0} = u printu pouzijeme prvni vyraz (je prvni protoze jsme pouzili \K ktery zahodil ether)
echo -e "$(ifconfig | grep -oP 'ether \K([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}' | awk '{print "MAC adresa:\t" $0}')"
echo
#echo "======================================================================================="
#echo "======================================================================================="
#echo
# timeout -s SIGINT 10 ping google.com
echo
echo "============================================================================================================================================="
echo "                                                        Výsledky spuštění skriptu                                                            "
echo "============================================================================================================================================="
echo


### FUNKCE - Nápověda ###

show_help () {
    echo "========================================================================================================================================="
	echo -e "\nSpuštění souboru: \t$0"
    echo -e "\nZvolení operace: \tdirMake"
    echo -e "\nCesta adresáře: \ttmp/nazev_slozky"
    echo -e "\nPojmenování souboru: \tnazev.sh"
    echo -e "\nVzorový příkaz: \t$0 dirMake /tmp/nova_slozka nazev_souboru"
	echo
}


### FUNKCE - Chceš nápovědu ? ###

answer () {
    echo -e "\nAhoj, pro správné chování skriptu musíš postupovat podle jasného zadání.\nChceš získat více informací? [y/n]"
    read -s -n 1 ANSWER
    echo
        if [[ "$ANSWER" == "y" || "$ANSWER" == "Y" ]]; then
            show_help
        elif [[ "$ANSWER" == "n" || "$ANSWER" == "N" ]]; then
            echo
            exit 1
        else
            echo -e "\nPříkaz "$ANSWER" bohužel neznám, zkus to znovu."
            echo
        fi
} 


### Vytvoření souboru pro ukládání logů ###
touch ~/bee_homework/app.log
LOG_FILE="$HOME/bee_homework/app.log"

### Parsování vstupních parametrů a uložení do proměnných ###
PARAM1="$2"
PARAM2="$3"

### Uložení cesty pro soft_link && hard_link do proměnných PATH_SOFT && PATH_HARD ###
PATH_SOFT="/tmp/$3_soft"
PATH_HARD="/tmp/$3_hard"


### 🟢 FUNKCE PRO GENEROVÁNÍ DALŠÍ VERZE DOCKER IMAGE 🟢 ###
get_next_version() {
    local image_name="$1"
    
    # Získáme seznam existujících verzí pro daný image (jen tagy končící na .0)
    existing_versions=$(docker images --format "{{.Tag}}" "$image_name" | grep -E '^[0-9]+\.0$' | sort -V)
    
    # Pokud žádná verze neexistuje, začneme od 1.0
    if [[ -z "$existing_versions" ]]; then
        echo "1.0"
        return
    fi

    # Získáme nejvyšší existující verzi
    last_version=$(echo "$existing_versions" | tail -n 1)

    # Extrahujeme číslo verze a zvýšíme o 1
    next_version=$(( ${last_version%.*} + 1 )).0

    echo "$next_version"
}

### 🟢 FUNKCE PRO BUILD DOCKER IMAGE S AUTOMATICKOU VERZÍ 🟢 ###
docker_build_image() {
    IMAGE_NAME="$1"
    IMAGE_VERSION=$(get_next_version "$IMAGE_NAME")

    echo "📦 Building Docker image: $IMAGE_NAME:$IMAGE_VERSION"
    docker build --no-cache -t "$IMAGE_NAME:$IMAGE_VERSION" .
    
    if [ $? -eq 0 ]; then
        echo "✅ Build image: $IMAGE_NAME:$IMAGE_VERSION byl úspěšný."
        echo -e "$(date) $(whoami) \tDocker build image: $IMAGE_NAME:$IMAGE_VERSION byl úspěšný." >> "$LOG_FILE"
        echo
    else
        echo "❌ ERROR: Docker build nebyl úspěšný!"
        echo -e "$(date) $(whoami) \tERROR: Docker build nebyl úspěšný!" >> "$LOG_FILE"
        echo
        exit 1
    fi
}

### 🟢 FUNKCE PRO SMAZÁNÍ DOCKER IMAGE 🟢 ###

docker_remove_image () {
    IMAGE_NAME="$1"
    echo "Probíhá odstraňování Docker image: $IMAGE_NAME"
    echo
    docker rmi -f "$IMAGE_NAME"

    if [ $? == 0 ]; then
        echo "✅ Docker image $IMAGE_NAME byl úspěšně odstraněn."
        echo -e "$(date) $(whoami) \tDocker image $IMAGE_NAME byl úspěšně odstraněn." >> "$LOG_FILE"
        echo
    else
        echo "❌ Docker image $IMAGE_NAME se nepodařilo odstranit."
        echo -e "$(date) $(whoami) \tDocker image $IMAGE_NAME se nepodařilo odstranit." >> "$LOG_FILE"
        echo
    fi
}

### 🟢 FUNKCE PRO KONTROLU, ŽE DOCKER IMAGE EXISTUJE 🟢 ###

docker_image_check () {
    local IMAGE_NAME="$1"
    
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${IMAGE_NAME}"; then
        return 0
    else
        echo "❌ ERROR: Docker image neexistuje!"
        echo -e "$(date) $(whoami) \tERROR: Docker image neexistuje." >> "$LOG_FILE"
        echo
        return 1
    fi
}




### 🟢 FUNKCE PRO VYTVOŘENÍ SOFT LINKU 🟢 ###
create_soft_link() {
    if [ -e "${PATH_SOFT}" ]; then
        if [ -L "${PATH_SOFT}" ]; then
            echo -e "\nERROR: Soft link již existuje."
            echo -e "$(date) $(whoami) \tERROR: Soft link již existuje." >> "$LOG_FILE"
            echo
        else
            echo -e "\nERROR: Soft link již existuje, ale není to link. Přepisuji..."
            echo -e "$(date) $(whoami) \tERROR: Soft link již existuje, ale není to link. Přepisuji..." >> "$LOG_FILE"
            rm -f "$PATH_SOFT"
            ln -s "$PARAM1/$PARAM2.sh" "$PATH_SOFT"
            echo -e "\n✅ Soft link byl vytvořen: $PATH_SOFT"
            echo -e "$(date) $(whoami) \tSoft link byl vytvořen: $PATH_SOFT" >> "$LOG_FILE"
            echo
        fi
    else
        ln -s "$PARAM1/$PARAM2.sh" "$PATH_SOFT"
        echo -e "\n✅ Soft link byl vytvořen: $PATH_SOFT"
        echo -e "$(date) $(whoami) \tSoft link byl vytvořen: $PATH_SOFT" >> "$LOG_FILE"
        echo
    fi
}

### 🟢 FUNKCE PRO VYTVOŘENÍ HARD LINKU 🟢 ###
create_hard_link() {
    if [ -e "${PATH_HARD}" ]; then
        echo -e "\nERROR: Hard link již existuje."
        echo -e "$(date) $(whoami) \tERROR: Hard link již existuje." >> "$LOG_FILE"
        echo
    else
        ln "$PARAM1/$PARAM2.sh" "$PATH_HARD"
        if [ $? -eq 0 ]; then
            echo -e "\n✅ Hard link byl vytvořen: $PATH_HARD"
            echo -e "$(date) $(whoami) \tHard link byl vytvořen: $PATH_HARD" >> "$LOG_FILE"
            echo
        else
            echo -e "\nERROR: Hard link $PATH_HARD se nepodařilo vytvořit."
            echo -e "$(date) $(whoami) \tERROR: Hard link $PATH_HARD se nepodařilo vytvořit." >> "$LOG_FILE"
            echo
            exit 1
        fi
    fi
}

# Kontrola, zda byl zadán alespoň jeden argument
if [ $# -lt 1 ]; then
    echo -e "\nERROR: Nedostatečný počet vstupních parametrů."
    echo -e "$(date) $(whoami) \tERROR: Nedostatečný počet vstupních parametrů." >> "$LOG_FILE"
    echo
    exit 1

# Pokud první argument je "dirMake", vytvoříme adresář
elif [ "$1" == "dirMake" ]; then
    if [[ -z "$2" || ! "$2" =~ ^/tmp/.+ ]]; then
        echo -e "\nERROR! Musíš zadat správně cestu, kde se má adresář vytvořit."
        echo -e "$(date) $(whoami) \tERROR! Musíš zadat správně cestu, kde se má adresář vytvořit." >> "$LOG_FILE"
        echo
        exit 1
    elif [ -z "$3" ]; then
        echo -e "\nERROR! Musíš zadat název souboru, který chceš vytvořit."
        echo -e "$(date) $(whoami) \tERROR! Musíš zadat název souboru, který chceš vytvořit." >> "$LOG_FILE"
        echo
        exit 1
    elif [ -e "$PARAM1" ]; then
        echo -e "\nERROR: Adresář $PARAM1 již existuje. Zvol si jiný název."
        echo -e "$(date) $(whoami) \tERROR: Adresář $PARAM1 již existuje. Zvol si jiný název." >> "$LOG_FILE"
        echo
        exit 1
    else
        mkdir -p "$PARAM1"
        if [ $? -eq 0 ]; then
            echo -e "\n✅ Adresář '$2' byl správně vytvořen."
            echo -e "$(date) $(whoami) \tAdresář '$2' byl správně vytvořen." >> "$LOG_FILE"
            echo

            # Vytvoření souboru
            cat <<EOF > "$PARAM1/$PARAM2.sh"
#!/bin/bash
# Výpis názvu operačního systému
echo
echo "==============================================="
echo "               Systémové informace             "
echo "==============================================="
echo "Název operačního systému: \$(uname -s)"
echo "Verze operačního systému: \$(uname -v)"
echo "Verze kernelu: \$(uname -r)"
echo "-----------------------------------------------"

# Technické informace o systému a hardwaru
echo "Informace o systému:"
echo "  CPU: \$(lscpu | grep 'Model name')"
echo "  Počet jader CPU: \$(nproc)"
echo "  Paměť RAM: \$(free -h | grep 'Mem' | awk '{print \$2}')"
echo "-----------------------------------------------"

# Informace o uživatelském účtu
echo "Uživatelský účet:"
echo "  Přihlášený uživatel: \$(whoami)"
echo "  Domovský adresář: \$HOME"
echo "  Systémový čas: \$(date)"
echo "-----------------------------------------------"

# Informace o IP adrese
echo -e "Aktuální IP adresa: \n\$(ipconfig.exe | grep 'IPv4')"
echo ping beeit.cz
echo nslookup beeit.cz
EOF

            if [ $? -eq 0 ]; then
                echo -e "\n✅ Soubor '$3' byl úspěšně vytvořen v adresáři '$2'."
                echo -e "$(date) $(whoami) \tSoubor '$3' byl úspěšně vytvořen v adresáři '$2'." >> "$LOG_FILE"
                echo

                # 🟢 Zavolání funkcí pro vytvoření soft a hard linku 🟢
                create_soft_link
                create_hard_link

            else
                echo -e "\nERROR: Nepodařilo se vytvořit soubor '$3'."
                echo -e "$(date) $(whoami) \tSoubor '$3' se nepodařilo vytvořit." >> "$LOG_FILE"
                echo
                exit 1
            fi
        else
            echo -e "\nERROR: Nepodařilo se vytvořit adresář '$2'."
            echo -e "$(date) $(whoami) \tAdresář '$2' se nepodařilo vytvořit." >> "$LOG_FILE"
            echo
            exit 1
        fi
    fi

# Pokud první argument je "docker", spustíme build
elif [ "$1" == "--build-docker" ]; then
    if [ -e "Dockerfile" ]; then
        if [ -z "$3" ]; then
            echo "❌ ERROR: Nezadal si název Docker image."
            echo -e "$(date) $(whoami) \tERROR: Nezadal si název Docker image nutný pro korektní build." >> "$LOG_FILE"
            echo
        fi
    docker_build_image "$3" #POZOR! zde je správně uveden parametr $3 (pro získání jména image), ve funkci, které to předávám je to však parametr $1 
    echo
    else
        echo "❌ ERROR: Dockerfile neexistuje!"
        echo -e "$(date) $(whoami) \tERROR: Dockerfile se v adresáři nepodařilo nalézt." >> "$LOG_FILE"
        echo
        exit 1
    fi
elif [ "$1" == "--remove-image" ]; then
        if [ -z "$3" ]; then
            echo "❌ ERROR: Nezadal si název Docker image."
            echo -e "$(date) $(whoami) \tERROR: Nezadal si název Docker image nutný pro jeho korektní odstranění." >> "$LOG_FILE"
            echo
            exit 1
        else
            docker_image_check "$3"
            result=$?
            if [ $result -eq 0 ]; then
                docker_remove_image "$3" #POZOR! zde je správně uveden parametr $3 (pro získání jména image), ve funkci, které to předávám je to však parametr $1 
                echo
            else
                echo "❌ ERROR: Docker image nebyl nalezen a proto nemůže být odstraněn."
                echo -e "$(date) $(whoami) \tERROR: Docker image nebyl nalezen a proto nemůže být odstraněn." >> "$LOG_FILE"
                echo
            fi
        fi    
elif [ "$1" == "--show-container" ]; then
    docker ps -a
    echo
# Neznámý příkaz
else
    echo -e "\nERROR: '$1' příkaz neznám."
    echo -e "$(date) $(whoami) \tERROR: Příkaz '$1' neznám." >> "$LOG_FILE"
    exit 1
fi


