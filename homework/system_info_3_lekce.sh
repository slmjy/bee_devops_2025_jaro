echo "Ahoj, znát svůj počítáč a systém je základ. Dnes ti pár informací o něm sdělím."
read -p "Pokud jsi připraven stiskni stiskni y a ENTER: " ANSWER

if [[ "$ANSWER" == "y" || "$ANSWER" == "Y" ]]; then
	echo
# Výpis názvu operačního systému
echo "==============================================="
echo "               System Information              "
echo "==============================================="
echo "Název operačního systému: $(uname -s)"
echo "Verze operačního systému: $(uname -v)"
echo "Verze kernelu: $(uname -r)"
echo "-----------------------------------------------"

# Technické informace o systému a hardwaru
echo "Informace o systému:"
echo "  CPU: $(lscpu | grep 'Model name')"
echo "  Počet jader CPU: $(nproc)"
echo "  Paměť RAM: $(free -h | grep 'Mem' | awk '{print $2}')"
echo "-----------------------------------------------"

# Informace o uživatelském účtu
echo "Uživatelský účet:"
echo "  Přihlášený uživatel: $(whoami)"
echo "  Domovský adresář: $HOME"
echo "  Systémový čas: $(date)"
echo "-----------------------------------------------"

# Informace o IP adrese
echo -e "Aktuální IP adresa: \n$(ipconfig.exe | grep 'IPv4')"
echo
echo
read -p "Stiskněte ENTER pro ukončení."
echo "-----------------------------------------------"

elif [[ "$ANSWER" ==  "n" || "$ANSWER" == "N" ]]; then
	echo
	echo
	read -p "Stiskni ENTER pro ukončení."
else
	echo
	echo "ERROR !!! Nepovolená odpověď."
fi
