# Použití základního image (Python3-slim)
FROM python:3.12.3-slim

# Nastavení pracovního adresáře uvnitř kontejneru
WORKDIR /app

# Zkopíruju soubor requirements.txt z adresáře, ve kterém se aktuálně nacházím (zajistí tečka na konci)
COPY requirements.txt .

# Provede instalaci knihoven ze souboru requirements.txt
RUN pip install -r requirements.txt 

# Zkopírování app.py souboru (případně lze použít 2 tečky, to zkopíruje vše z aktuálního adresáře) do kontejneru
COPY . .

# Spustíme Python a app.py
CMD ["python3", "app.py"]
