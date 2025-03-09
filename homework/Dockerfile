# Použití základního image (NGINX)
FROM nginx:latest

# Nastavení pracovního adresáře uvnitř kontejneru
WORKDIR /usr/share/nginx/html

# Zkopírování vlastního HTML souboru do kontejneru
COPY index.html .

# Exponujeme port 80 pro přístup k aplikaci
EXPOSE 80

# Spustíme NGINX
CMD ["nginx", "-g", "daemon off;"]
