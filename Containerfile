# Base oficial optimizada de Ollama
FROM docker.io/ollama/ollama:latest

# Dependencias ligeras
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip curl jq \
    && rm -rf /var/lib/apt/lists/*

# Librerías Python para el asistente
RUN pip3 install --no-cache-dir --break-system-packages fastapi uvicorn requests

# Copiar scripts
COPY assistant.py /app/assistant.py
COPY index.html /app/index.html
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Volumen para archivos compartidos
VOLUME ["/shared"]

# Puertos: 11434 (Ollama) + 8080 (Asistente)
EXPOSE 11434 8080

# Inicio orquestado
ENTRYPOINT ["/app/entrypoint.sh"]
