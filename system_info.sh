#!/bin/bash

# Skript pro zobrazení informací o zařízení

# Funkce pro oddělovač
separator() {
    echo "---------------------------------------------"
}

# Získání informací o systému
OsName=$(lsb_release -d | cut -f2)  # Získá název a verzi OS
Kernel=$(uname -r)                  # Verze jádra
UpTime=$(uptime -p | sed 's/up //') # Doba běhu systému (bez "up")
CPU=$(grep -m 1 "model name" /proc/cpuinfo | cut -d':' -f2 | xargs)  # Model CPU
User=$(whoami)                      # Přihlášený uživatel
Author=$(echo "Tomáš Drenko")       # Autor

# Výpis informací
echo "=== Informace o systému ==="
separator
echo "Operační systém: $OsName"
echo "Verze jádra: $Kernel"
echo "Doba běhu systému: $UpTime"
separator
echo "=== Informace o CPU ==="
separator
echo "Model CPU: $CPU"
separator
echo "=== Informace o uživateli ==="
separator
echo "Přihlášený uživatel: $User"
echo "Vytvořil: $Author"
separator