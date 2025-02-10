#!/bin/bash

# Ziskani nazvu slozky a souboru
echo "nazev slozky:"
read dir_name
echo "nazev souboru:"
read file_name

soft_link="/tmp/${file_name}_soft_link"
hard_link="/tmp/${file_name}_hard_link"

# Vytvoreni adresare
mkdir -p "$dir_name"

# Vytvoreni souboru a zapis textu
echo "Automaticky zapsany retezec" > "$dir_name/$file_name"

# Vytvoreni symbolickeho (soft) linku
ln -s "$(pwd)/$dir_name/$file_name" "$soft_link"

# Vytvoreni hard linku
ln "$dir_name/$file_name" "$hard_link"

# Vypis potvrzeni
echo "Slozka a soubor vytvoreny v '$dir_name'."
echo "Soft link: $soft_link"
echo "Hard link: $hard_link"