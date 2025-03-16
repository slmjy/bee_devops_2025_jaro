FROM debian

COPY . /app
COPY . /network.sh

RUN apt-get update && apt-get install -y openssl 
#dát update registry a -y pro automatický souhlas s instalací, jinak ERROR 100 !

RUN apt-get update && apt-get install -y curl

LABEL maintainer="devops_admin@domena.com"

ARG version=1.0

ENV APP_ENV=production

EXPOSE 8080