#!/bin/bash

# Určíme název hlavního síťového rozhraní
INTERFACE="eth0"

# Zkontrolujeme, zda rozhraní eth0 existuje, jinak použijeme et0
if ! ip addr show "$INTERFACE" &> /dev/null; then
    INTERFACE="et0"
fi

# Získáme IP adresu a masku
IP_INFO=$(ip addr show "$INTERFACE" | grep inet | awk '{print $2}')
IP_ADDRESS=$(echo $IP_INFO | cut -d'/' -f1)
CIDR_MASK=$(echo $IP_INFO | cut -d'/' -f2)

# Získáme výchozí bránu (gateway)
GATEWAY=$(ip route show dev "$INTERFACE" | grep default | awk '{print $3}')

# Získáme DNS servery
DNS_SERVERS=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')

# Výpis informací
echo "Síťové rozhraní: $INTERFACE"
echo "IP adresa: $IP_ADDRESS"
echo "CIDR maska: /$CIDR_MASK"
echo "Výchozí brána (gateway): $GATEWAY"
echo "DNS servery:"

# Vypíše DNS servery, pokud jsou dostupné
if [ -n "$DNS_SERVERS" ]; then
    echo "$DNS_SERVERS"
else
    echo "Žádné DNS servery nenalezeny."
fi

