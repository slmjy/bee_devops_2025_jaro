FROM debian:stable-20250113-slim

COPY . /app
COPY . /netInfo.sh

RUN app-get update && app-get install -y opnenssl
