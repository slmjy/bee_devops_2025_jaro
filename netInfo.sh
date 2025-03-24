#!/bin/bash

# Získání hlavního síťového rozhraní
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^eth0|^et0' | head -n 1)

if [[ -z "$IFACE" ]]; then
    echo "Žádné síťové rozhraní eth0 nebo et0 nebylo nalezeno."
    exit 1
fi

# Získání IP adresy a CIDR masky
IP_INFO=$(ip -o -f inet addr show "$IFACE" | awk '{print $4}')
IP_ADDR=${IP_INFO%/*}
CIDR_MASK=${IP_INFO#*/}

# Získání adresy brány
GATEWAY=$(ip route show default | awk '/default/ {print $3}')

# Získání DNS serverů
DNS_SERVERS=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf | tr '\n' ' ')

# Výpis informací
echo "Síťové informace pro $IFACE:"
echo "--------------------------------------"
echo "IP adresa:      $IP_ADDR"
echo "Maska (CIDR):   $CIDR_MASK"
echo "Brána (Gateway): $GATEWAY"
echo "DNS servery:    $DNS_SERVERS"
echo "--------------------------------------"
