#!/bin/bash
set -e

# 1. Iniciar Ollama en segundo plano
echo "🚀 Iniciando Ollama..."
ollama serve &
OLLAMA_PID=$!

# 2. Esperar a que el servicio esté listo
echo "⏳ Esperando a que Ollama escuche en puerto 11434..."
until curl -sf http://localhost:11434/ > /dev/null 2>&1; do
  sleep 2
done

# 3. Descargar modelo ligero (configurable vía variable de entorno)
MODEL=${MODEL_NAME:-qwen2.5:1.5b}
echo "📥 Descargando modelo: $MODEL"
ollama pull "$MODEL"

# 4. Configurar parámetros de bajo consumo (opcional pero recomendado)
export OLLAMA_KEEP_ALIVE="24h"        # Mantener modelo en RAM
export OLLAMA_NUM_PARALLEL="2"        # Máx. peticiones simultáneas
export OLLAMA_MAX_LOADED_MODELS="1"   # Solo 1 modelo cargado

# 5. === OPTIMIZACIONES PARA HARDWARE LIMITADO ===
export OLLAMA_NUM_PARALLEL=1          # Solo 1 petición a la vez (evita colas)
export OLLAMA_CONTEXT_LENGTH=2048     # Máximo de tokens en contexto (reduce RAM)
export OLLAMA_KEEP_ALIVE=24h          # Mantener modelo cargado (evita recargas lentas)
export OLLAMA_MAX_LOADED_MODELS=1     # Solo 1 modelo en memoria
export OLLAMA_FLASH_ATTENTION=0       # Desactivar atención flash (ahorra RAM en CPU)

# Límites de recursos para el contenedor (ajustar según hardware real)
# Al ejecutar podman run, agregar:
#   --cpus 1.5 --memory 1.5g --memory-swap 2g

# 6. Iniciar asistente
echo "🤖 Iniciando asistente en puerto 8080..."
exec python3 /app/assistant.py
