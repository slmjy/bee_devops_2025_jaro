#!/bin/bash

# Funkce pro sestaveni Docker image
build_docker() {
    if [[ ! -f "Dockerfile" ]]; then
        echo "Dockerfile nenalezen!"
        exit 1
    fi

    if [[ -z "$IMAGE_NAME" ]]; then
        echo "Musite zadat jmeno image pomoci --name <image_name>"
        exit 1
    fi

    echo "Buduji Docker image: $IMAGE_NAME"
    docker build -t "$IMAGE_NAME" .
}

# Funkce pro odstraneni Docker image
remove_image() {
    if [[ -z "$IMAGE_NAME" ]]; then
        echo "❗ Mažu vsechny Docker images..."
        docker rmi $(docker images -q) -f
    else
        echo "Mažu image: $IMAGE_NAME"
        docker rmi "$IMAGE_NAME" -f
    fi
}

# Funkce pro vypis vsech kontejneru
show_containers() {
    echo "Seznam vsech kontejneru:"
    docker ps -a
}

# Zpracovani argumentu
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --build-docker) BUILD_DOCKER=1 ;;
        --name) IMAGE_NAME="$2"; shift ;;
        --remove-image) REMOVE_IMAGE=1 ;;
        --image-name) IMAGE_NAME="$2"; shift ;;
        --show-container) SHOW_CONTAINER=1 ;;
        *) echo "Neznamy argument: $1"; exit 1 ;;
    esac
    shift
done

# Spusteni prikazu
if [[ $BUILD_DOCKER -eq 1 ]]; then build_docker; fi
if [[ $REMOVE_IMAGE -eq 1 ]]; then remove_image; fi
if [[ $SHOW_CONTAINER -eq 1 ]]; then show_containers; fi
