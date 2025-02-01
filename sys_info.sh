echo "Informace o operačním systému:"
echo "------------------------------"
lsb_release -a

#echo "Název jádra, hostname, verze a architektura:"
#echo "--------------------------------------------"
#uname -a

echo "Hostname, operační systém, verze jádra a architektura:"
echo "------------------------------------------------------"
hostnamectl

#echo "informace o běžících procesech a systémových prostředcích:"
#echo "----------------------------------------------------------"
#top

echo "Doba běhu systému, počet aktivních uživatelů, zatížení systému:"
echo "---------------------------------------------------------------"
uptime

#echo "Zprávy jádra:"
#echo "-------------"
#dmesg

echo "Využití paměti:"
echo "---------------"
free -h

echo "Aktuální adresář:"
echo "-----------------"
pwd

echo "Uživatel, pod kterým je momentálně otevřená relace:"
echo "---------------------------------------------------"
whoami