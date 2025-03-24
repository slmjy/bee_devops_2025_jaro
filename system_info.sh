#!/bin/bash

# Skript pro zjisteni informaci o operacnim systemu

echo "======= Informace o systemu ======="

# Nazev stroje
echo "Nazev stroje: $(hostname)"

# Verze OS a distribuce
if [ -f /etc/os-release ]; then
  source /etc/os-release
  echo "Operacni system: $PRETTY_NAME"
else
  echo "Operacni system: Nelze zjistit"
fi

# Verze jadra
echo "Verze jadra: $(uname -r)"

# Architektura
echo "Architektura: $(uname -m)"

# Doba behu systemu
echo -n "Doba od spusteni: "
uptime -p | sed 's/up //'

# Procesor
echo "Procesor: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ //')"
echo "Pocet jader: $(nproc)"

# Vyuziti pameti
echo "Pameť RAM:"
free -h | grep Mem | awk '{print "Celkem: " $2 ", Vyuzito: " $3 ", Volne: " $4}'

# Misto na disku
echo -e "\nMisto na discich:"
df -h --output=source,target,pcent,avail | grep -v 'tmpfs\|udev\|loop'

# Siťova rozhrani
echo -e "\nSiťova rozhrani:"
ip -brief address | awk '{print $1 " | IP: " $3}'

# Přihlaseni uzivatele
echo -e "\nAktivni uzivatele:"
who

# Narocne procesy
echo -e "\nNejnarocnejsi procesy (CPU):"
ps aux --sort=-%cpu | head -n 6 | awk '{print $1, $2, $3"%", $4"%", $11}' | column -t
