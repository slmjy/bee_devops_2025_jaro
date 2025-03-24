# Build stage
FROM alpine:latest as builder

WORKDIR /app

# Instalace build nástrojů a lsb-release pro použití lsb_release
RUN apk add --no-cache build-base lsb-release \
    && echo "int main() { return 0; }" > dummy.c \
    && gcc -o dummy dummy.c \
    && lsb-release \
    && rm -rf /var/cache/apk/*  # Čistíme cache balíčků pro menší obraz

# Runtime stage
FROM alpine:latest

WORKDIR /app

# Kopírování výsledného souboru z build fáze
COPY --from=builder /app/dummy .

# Vytvoření non-root uživatele
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

# Nastavení uživatele pro spuštění aplikace
USER appuser

# Výchozí příkaz
CMD ["./dummy"]
