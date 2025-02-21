#!/bin/bash

echo
echo "======================================================================================="
echo "                           Informace o tvém síťovém rozhraní                           "
echo "======================================================================================="
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
echo "======================================================================================="
echo "======================================================================================="
echo
timeout -s SIGINT 10 ping google.com
echo
echo "======================================================================================="
echo "                              Výsledky spuštění skriptu                                "
echo "======================================================================================="



# FUNKCE - Nápověda

show_help () {
    echo "======================================================================================="
	echo -e "\nSpuštění souboru: \t$0"
    echo -e "\nZvolení operace: \tdirMake"
    echo -e "\nCesta adresáře: \ttmp/nazev_slozky"
    echo -e "\nPojmenování souboru: \tnazev.sh"
    echo -e "\nVzorový příkaz: \t$0 dirMake /tmp/nova_slozka nazev_souboru"
	echo
}


# FUNKCE - Chceš nápovědu ?

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
        fi
} 


# Vytvoření souboru pro ukládání logů

touch ~/bee_homework/app.log
LOG_FILE="$HOME/bee_homework/app.log"

# Parsování vstupních parametrů a uložení do proměnných

DIRECTORY="$2"
FILE="$3.sh"


# Kontrola, zda byl zadán alespoň jeden argument
if [ $# -lt 1 ]; then
    echo -e "\nERROR: Nedostatečný počet vstupních parametrů."
    echo -e "$(date) $(whoami) \tERROR: Nedostatečný počet vstupních parametrů." >> "$LOG_FILE"
    echo
    show_help
    exit 1
else
    # Pokud první argument je "dirMake", vytvoříme adresář
    if [ "$1" == "dirMake" ]; then
        # Kontrola, zda byl zadán druhý argument (cesta k adresáři)
        if [[ -z "$2" || ! "$2" =~ ^/tmp/.+ ]]; then
            echo -e "\nERROR! Musíš zadat správně cestu, kde se má adresář vytvořit."
            echo -e "$(date) $(whoami) \tERROR! Musíš zadat správně cestu, kde se má adresář vytvořit." >> "$LOG_FILE"
            answer
            exit 1
        elif [ -z "$3" ]; then
            echo -e "\nERROR! Musíš zadat název souboru, který chceš vytvořit."
            echo -e "$(date) $(whoami) \tERROR! Musíš zadat název souboru, který chceš vytvořit." >> "$LOG_FILE"
            answer
            exit 1
        elif [ -e "$DIRECTORY" ]; then
            echo -e "\nERROR: Adresář $DIRECTORY již existuje. Zvol si jiný název."
            echo -e "$(date) $(whoami) \tERROR: Adresář $DIRECTORY již existuje. Zvol si jiný název." >> "$LOG_FILE"
            exit 1
        else
            mkdir -p "$DIRECTORY"
            if [ $? -eq 0 ]; then
                echo -e "\nAdresář '$2' byl správně vytvořen. Gratuluji."
                echo -e "$(date) $(whoami) \tAdresář '$2' byl správně vytvořen. Gratuluji." >> "$LOG_FILE"
                    if [ $? -eq 0 ]; then
                        cat <<EOF > "$DIRECTORY/$FILE"
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
                    else
                        echo -e "\nERROR: Nepodařilo se vytvořit soubor '$3'."
                        echo -e "$(date) $(whoami) \tERROR: Nepodařilo se vytvořit soubor '$3'." >> "$LOG_FILE"
                        answer
                    fi
            else
                echo -e "\nERROR: Nepodařilo se vytvořit adresář '$2'."
                echo -e "$(date) $(whoami) \tERROR: Nepodařilo se vytvořit adresář '$2'." >> "$LOG_FILE"
                exit 1                                   
            fi
        fi
    else
        echo -e "\nERROR: '$1' příkaz neznám."
        echo -e "$(date) $(whoami) \tERROR: '$1' příkaz neznám." >> "$LOG_FILE"
        answer
        exit 1
    fi
fi


# Uložení cesty pro soft_link do proměnné PATH_SOFT

PATH_SOFT="/tmp/$3_soft"

if [ -e "${PATH_SOFT}" ]; then
	if [ -L ${PATH_SOFT} ]; then
		echo -e "\nERROR: Soft link již existuje."
        echo -e "$(date) $(whoami) \tERROR: Soft link již existuje." >> "$LOG_FILE"
	else
	    echo -e "\nERROR: Soft link již existuje, ale není to link."
        echo -e "$(date) $(whoami) \tERROR: Soft link již existuje, ale není to link." >> "$LOG_FILE"
	    rm -f "$PATH_SOFT"
	    ln -s "$DIRECTORY/$FILE" "$PATH_SOFT"
            if [ $? -eq 0 ]; then
                echo -e "\nSoft link byl vytvořen: $PATH_SOFT"
                echo -e "$(date) $(whoami) \tSoft link byl vytvořen: $PATH_SOFT" >> "$LOG_FILE"
            else
                echo -e "\nERROR: Soft link $PATH_SOFT se nepodařilo vytvořit."
                echo -e "$(date) $(whoami) \tERROR: Soft link $PATH_SOFT se nepodařilo vytvořit." >> "$LOG_FILE"
            fi
	fi
else
	ln -s "$DIRECTORY/$FILE" "$PATH_SOFT"
	echo -e "\nSoft link byl vytvořen: $PATH_SOFT"
    echo -e "$(date) $(whoami) \tSoft link byl vytvořen: $PATH_SOFT" >> "$LOG_FILE"
fi

# Uložení cesty pro hard_link do proměnné PATH_HARD

PATH_HARD="/tmp/$3_hard"

if [ -e "${PATH_HARD}" ]; then
	echo -e "\nERROR: Hard link již existuje."
    echo -e "$(date) $(whoami) \tERROR: Hard link již existuje." >> "$LOG_FILE"
else
	ln "$DIRECTORY/$FILE" "$PATH_HARD"
	    if [ $? -eq 0 ]; then
            echo -e "\nHard link byl vytvořen: $PATH_HARD"
            echo -e "$(date) $(whoami) \tHard link byl vytvořen: $PATH_HARD" >> "$LOG_FILE"
            exit 0
        else
            echo -e "\nERROR: Hard link $PATH_HARD se nepodařilo vytvořit."
            echo -e "$(date) $(whoami) \tERROR: Hard link $PATH_HARD se nepodařilo vytvořit." >> "$LOG_FILE"
            answer
            exit 1
        fi
fi







