FROM debian

COPY . /app
COPY . /network.sh

#RUN apt install openssl  #--exit code: 100, (oprávnění???)

RUN apt-get update && apt-get install -y curl

LABEL maintainer="devops_admin@domena.com"

ARG version=1.0

ENV APP_ENV=production

EXPOSE 8080