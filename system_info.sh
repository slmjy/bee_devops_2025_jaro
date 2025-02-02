#!/bin/bash

echo "================================================="
echo "               Domácí úkol - lekce 3             "
echo "================================================="

# Základní informace o operačním systému
echo "Název operačního systému: $(uname -s)"
echo "Verze operačního systému: $(uname -v)"
echo "Verze kernelu: $(uname -r)"
echo "-----------------------------------------------"

# Základní informace o hardware
echo "Informace o systému:"
echo "  CPU: $(lscpu | grep 'Model name')"
echo "  Počet jader CPU: $(nproc)"
echo "  Paměť RAM: $(free -h | grep 'Mem' | awk '{print $2}')"
echo "-----------------------------------------------"

# Informace o uživatelském účtu
echo "Uživatelský účet:"
echo "  Přihlášený uživatel: $(whoami)"
echo "  Domovská složka: $HOME"
echo "  Systémový čas: $(date)"
echo "-----------------------------------------------"

# Informace o IP adrese
echo -e "Aktuální IP adresa: \n$(ipconfig.exe | grep 'IPv4')"
