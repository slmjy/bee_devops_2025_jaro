#!/bin/bash

# Skript pro zjištìní informací o operaèním systému

echo "======= Informace o systému ======="

# Název stroje
echo "Název stroje: $(hostname)"

# Verze OS a distribuce
if [ -f /etc/os-release ]; then
  source /etc/os-release
  echo "Operaèní systém: $PRETTY_NAME"
else
  echo "Operaèní systém: Nelze zjistit"
fi

# Verze jádra
echo "Verze jádra: $(uname -r)"

# Architektura
echo "Architektura: $(uname -m)"

# Doba bìhu systému
echo -n "Doba od spuštìní: "
uptime -p | sed 's/up //'

# Procesor
echo "Procesor: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ //')"
echo "Poèet jader: $(nproc)"

# Vyuití pamìti
echo "Pamì RAM:"
free -h | grep Mem | awk '{print "Celkem: " $2 ", Vyuito: " $3 ", Volné: " $4}'

# Místo na disku
echo -e "\nMísto na discích:"
df -h --output=source,target,pcent,avail | grep -v 'tmpfs\|udev\|loop'

# Síová rozhraní
echo -e "\nSíová rozhraní:"
ip -brief address | awk '{print $1 " | IP: " $3}'

# Pøihlášení uivatelé
echo -e "\nAktivní uivatelé:"
who

# Nároèné procesy
echo -e "\nNejnároènìjší procesy (CPU):"
ps aux --sort=-%cpu | head -n 6 | awk '{print $1, $2, $3"%", $4"%", $11}' | column -t