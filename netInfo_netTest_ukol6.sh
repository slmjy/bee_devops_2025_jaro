#!/bin/bash

# Funkce pro ziskani informaci o sitovych rozhranich
function netInfo() {
    echo "==============================="
    echo " Sitova rozhrani a IP adresy"
    echo "==============================="
    ip -brief address show | awk '{print $1, "-", $3}'
    
    echo -e "\n==============================="
    echo " MAC adresy"
    echo "==============================="
    ip link show | awk '/ether/ {print $(NF-4), "-", $2}'
}

# Funkce pro test pripojeni (ping)
function netTest() {
    echo "==============================="
    echo " Test pripojeni k beeit.cz"
    echo "==============================="
    ping -c 1 beeit.cz
}

# Menu pro uzivatele
echo "Vyberte akci:"
echo "1) Zobrazit sitove informace"
echo "2) Test pripojeni"
echo "3) Ukoncit"
read -p "Zadejte cislo volby: " choice

case "$choice" in
    1)
        netInfo
        ;;
    2)
        netTest
        ;;
    3)
        echo "Ukoncuji skript..."
        exit 0
        ;;
    *)
        echo "Neplatna volba!"
        exit 1
        ;;
esac
