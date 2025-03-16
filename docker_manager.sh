#!/bin/bash

echo "Docker image manager"
echo "--------------------"

# Funkce pro zobrazení chybové zprávy a ukončení skriptu
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Funkce pro kontrolu existence Dockerfile
check_dockerfile() {
    if [ ! -f Dockerfile ]; then
        error_exit "Dockerfile nenalezen v aktuálním adresáři."
    fi
}

# Funkce pro sestavení Docker image
build_docker_image() {
    check_dockerfile
    docker build -t "$1" . || error_exit "Chyba při sestavování Docker image."
    echo "Docker image '$1' úspěšně sestaven."
}

# Funkce pro odstranění Docker image
remove_docker_image() {
    if [ "$1" == "all" ]; then
        echo "Mazání všech Docker image..."
        docker rmi $(docker images -q) || error_exit "Chyba při mazání Docker image."
    else
        docker rmi "$1" || error_exit "Chyba při mazání Docker image '$1'."
        echo "Docker image '$1' úspěšně odstraněn."
    fi
}

# Funkce pro zobrazení všech kontejnerů
show_containers() {
    docker ps -a || error_exit "Chyba při zobrazení kontejnerů."
}


# Hlavní část skriptu pro zpracování argumentů
if [ $# -lt 1 ]; then
    error_exit "Použití: ./docker_manager.sh --build-docker --name <image_name> | --remove-image --image-name <image_name> | --show-container"
fi

case "$1" in
    --build-docker)
        if [ -z "$2" ] || [ "$2" != "--name" ] || [ -z "$3" ]; then
            error_exit "Pro sestavení image je třeba specifikovat --name <image_name>"
        fi
        build_docker_image "$3"
        ;;
    --remove-image)
        if [ -z "$2" ] || [ "$2" != "--image-name" ] || [ -z "$3" ]; then
            error_exit "Pro odstranění image je třeba specifikovat --image-name <image_name>"
        fi
        remove_docker_image "$3"
        ;;
    --remove-image-all)
        remove_docker_image "all"
        ;;
    --show-container)
        show_containers
        ;;
    *)
        error_exit "Neznámý argument. Použij --build-docker, --remove-image nebo --show-container."
        ;;
esac

echo "----------------------------------"
echo "Konec operací Docker image manager"
