#!/bin/bash

# Funkce netInfo pro zobrazení informací o síťových rozhraních, IP a MAC adresách
netInfo() {
  echo -e "\n### Síťové informace ###"

  # Zobrazení všech síťových rozhraní, jejich IP adres a MAC adres
  ip -o link show | while read -r line; do
    iface=$(echo $line | awk -F': ' '{print $2}') #druhý sloupec
    mac=$(echo $line | grep -oP 'link/ether \K[^\s]+') #pomocí regulárního výrazu

    if [ -n "$iface" ]; then
      # Zjištění IP adresy pro dané rozhraní
      ip_addr=$(ip -o -f inet addr show dev $iface | awk '{print $4}') #čtvrtý sloupec

      # Výstupní formát
      echo -e "\nRozhraní: $iface"
      echo -e "  MAC adresa: $mac"
      echo -e "  IP adresa: $ip_addr"
    fi
  done
}

# Zavolání funkce netInfo pro zobrazení informací
netInfo

#############################

# Funkce netTest pro provedení jednoho pingu na beeit.cz
netTest() {
  echo -e "\n### Test připojení na beeit.cz ###\n"
  ping -c 1 beeit.cz
}

# Zavolání funkce netTest pro spuštění pingu
netTest
