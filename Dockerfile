FROM debian

#WORKDIR /app

#ENV APP_ENV=production

#LABEL maintainer="devops_admin@domena.com"

#ARG version=1.0

#COPY . /network.sh

RUN apt-get update && apt-get install -y curl

#EXPOSE 8080

COPY . .

CMD ["bash"]
