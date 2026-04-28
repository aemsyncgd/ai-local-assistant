# 🤖 Asistente IA Local

[![GitHub](https://img.shields.io/github/license/aems268/local-ai-assistant)](LICENSE)
[![Podman](https://img.shields.io/badge/Podman-4.0+-blue.svg)](https://podman.io)
[![Ollama](https://img.shields.io/badge/Ollama-LLM-orange.svg)](https://ollama.ai)
[![Python](https://img.shields.io/badge/Python-3.8+-green.svg)](https://python.org)

**Asistente de inteligencia artificial 100% local, privado y portable.** Ejecuta modelos de lenguaje en tu propio hardware sin depender de APIs externas ni conexión a internet constante.

![Demo](https://img.shields.io/badge/Status-✅_Producción-success)
![RAM](https://img.shields.io/badge/RAM_Mínima-2GB-lightgrey)
![CPU](https://img.shields.io/badge/CPU-2_núcleos-lightgrey)

---

## 🌟 Características

- 🔒 **Privacidad total**: Todo se ejecuta localmente, sin envío de datos a la nube
- 🚀 **Despliegue automático**: Script inteligente que configura todo en minutos
- 💾 **Ultra-portable**: Llévalo en un USB y ejecútalo en cualquier PC con Podman
- 🎨 **Interfaz web moderna**: Chat intuitivo accesible desde el navegador
- 📁 **Contexto con archivos**: Sube documentos y la IA los analiza automáticamente
- ⚡ **Optimizado para hardware limitado**: Funciona desde 2GB RAM
- 🔄 **Múltiples modelos**: Soporte para Qwen, Llama, TinyLlama, Phi3, y más

---

## 📋 Requisitos

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| **RAM** | 2 GB | 4 GB |
| **CPU** | 2 núcleos | 4 núcleos |
| **Almacenamiento** | 5 GB | 10 GB |
| **Sistema** | Linux/macOS/Windows | Linux (Fedora/Ubuntu) |
| **Podman** | 4.0+ | Última versión |

---

## 🚀 Instalación Rápida

### Método 1: Script Automático (Recomendado)

```
### bash
# 1. Clonar repositorio
git clone https://github.com/aems268/local-ai-assistant.git ; cd local-ai-assistant ; podman build -t local-ai-assistant:latest .

# 2. Dar permisos de ejecución
chmod +x deploy-ai.sh

# 3. Ejecutar asistente de despliegue
./deploy-ai.sh o ./deploy-full-ai.sh
```

¡Listo! El script:

    ✅ Verifica/instala dependencias
    ✅ Construye la imagen de Podman
    ✅ Descarga el modelo de IA
    ✅ Configura volúmenes y puertos
    ✅ Inicia el contenedor automáticamente

## Método 2: Manual (Avanzado)
```
# Construir imagen desde los archivos locales
podman build -t local-ai-assistant:latest .

# Ejecutar contenedor con configuración base
podman run -d --name ai-assistant \
  --cpus 2 --memory 2g \
  -v $(pwd)/shared:/shared:Z \
  -p 8080:8080 -p 11434:11434 \
  -e MODEL_NAME=qwen2.5:0.5b \
  localhost/local-ai-assistant:latest
```


## 🎯 Uso
Acceso a la Interfaz Web
Una vez desplegado, abre tu navegador en:
```
http://localhost:8080
```

API REST
También puedes usar la API directamente:
```
# Health check - verificar estado del servicio
curl http://localhost:8080/health

# Consulta simple - pregunta directa a la IA
curl -X POST http://localhost:8080/ask \
  -H "Content-Type: application/json" \
  -d '{"prompt": "¿Qué es Podman?", "use_files": false}'

# Consulta con archivos - la IA analiza tus documentos
curl -X POST http://localhost:8080/ask \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Analiza mis archivos", "use_files": true}'
```

Ejemplos de Uso
## 📄 Analizar configuración de red
```
# 1. Coloca tu archivo en la carpeta compartida
cat > shared/olt-config.txt << 'EOF'
OLT-ZONA
IP: 192.168.100.1
SNMP: public
VLANs: 100,200,300
EOF

# 2. Pregunta a la IA sobre ese archivo
curl -X POST http://localhost:8080/ask \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "¿Qué VLANs están configuradas en mi OLT?",
    "use_files": true
  }'

Respuesta esperada
{
  "response": "Según el archivo olt-config.txt, las VLANs configuradas son: 100, 200 y 300."
}
```


## 🔧 Generar script de monitoreo
```
curl -X POST http://localhost:8080/ask \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Genera un script bash para monitorear temperatura de OLT via SNMP cada 60s",
    "use_files": false
  }'
```


️## Configuración
### Modelos Disponibles
El script deploy-ai.sh te permite elegir entre varios modelos optimizados:

Modelo                RAM Aprox.             Velocidad*            Calidad
qwen2.5:0.5b          ~400 MB               ⚡⚡⚡⚡⚡          ⭐⭐⭐
tinyllama:1.1b        ~700 MB               ⚡⚡⚡⚡            ⭐⭐⭐⭐
llama3.2:1b           ~1.1 GB               ⚡⚡⚡              ⭐⭐⭐⭐⭐
qwen2.5:1.5b          ~1.8 GB               ⚡⚡                 ⭐⭐⭐⭐⭐

## Variables de Entorno
```
# Modelo de IA a utilizar
export MODEL_NAME="qwen2.5:0.5b"

# Tiempo que el modelo permanece cargado en RAM
export OLLAMA_KEEP_ALIVE="24h"

# Tamaño máximo del contexto de conversación
export OLLAMA_CONTEXT_LENGTH="2048"

# Número de peticiones paralelas permitidas
export OLLAMA_NUM_PARALLEL="1"
```

## Gestión del Contenedor
```
# Verificar estado del contenedor
podman ps -f name=ai-assistant

# Ver logs en tiempo real
podman logs -f ai-assistant

# Detener contenedor (conserva datos)
podman stop ai-assistant

# Reiniciar contenedor
podman restart ai-assistant

# Eliminar contenedor (la imagen se conserva)
podman rm -f ai-assistant

# Ver consumo de recursos en tiempo real
podman stats ai-assistant

# Acceder a shell dentro del contenedor
podman exec -it ai-assistant /bin/bash
```


## 📁 Estructura del Proyecto

local-ai-assistant/
├── Containerfile          # Definición del contenedor Podman
├── assistant.py           # Backend FastAPI + integración con Ollama
├── index.html             # Interfaz web de chat (HTML+JS)
├── entrypoint.sh          # Script de inicialización del contenedor
├── deploy-ai.sh           # Script de despliegue inteligente (CLI)
├── shared/                # Volumen compartido para tus archivos
│   └── .gitkeep           # Marcador para rastrear carpeta vacía
├── .gitignore             # Archivos excluidos de Git
└── README.md              # Este archivo de documentación

## 🔧 Arquitectura
┌─────────────────────────────────────┐
│         NAVEGADOR WEB               │
│    http://localhost:8080            │
└────────────┬────────────────────────┘
             │ HTTP/JSON
             ▼
┌──────────────────────────────────────┐
│         FastAPI (assistant.py)       │
│  • POST /ask   → Consulta a la IA    │
│  • GET  /health → Estado del servicio│
│  • Lee archivos de /shared           │
│  • Inyecta contexto en el prompt     │
└────────────┬─────────────────────────┘
             │ API interna
             ▼
┌─────────────────────────────────────┐
│         Ollama Server               │
│         Puerto 11434                │
│  • Carga el modelo seleccionado     │
│  • Ejecuta inferencia en CPU        │
│  • Devuelve respuesta generada      │
└─────────────────────────────────────┘


🐛 Troubleshooting
### El contenedor no inicia
```
# Verificar logs para diagnóstico
podman logs ai-assistant

# Verificar si los puertos están ocupados
sudo netstat -tlnp | grep -E '8080|11434'

# Verificar memoria disponible en el host
free -h
```

### Error "OOM-killed"
```
# El modelo requiere más RAM de la asignada
# Solución: aumentar memoria al recrear

podman rm -f ai-assistant
podman run -d --name ai-assistant \
  --cpus 2 --memory 3g \  # ← Aumentar de 2g a 3g
  -v $(pwd)/shared:/shared:Z \
  -p 8080:8080 -p 11434:11434 \
  -e MODEL_NAME=qwen2.5:0.5b \  # ← O usar modelo más ligero
  localhost/local-ai-assistant:latest
```

### La web no responde
```
# 1. Verificar que el contenedor está corriendo
podman ps | grep ai-assistant

# 2. Probar API directamente (sin navegador)
curl http://localhost:8080/health

# 3. Si usas Fedora/RHEL con SELinux:
getenforce
# Si devuelve "Enforcing", recrear con etiqueta :Z
podman run -d ... -v ./shared:/shared:Z ...
```


### Respuestas muy lentas
```
# Opción A: Usar modelo más ligero
./deploy-ai.sh
# Seleccionar: qwen2.5:0.5b

# Opción B: Reducir tamaño de contexto
export OLLAMA_CONTEXT_LENGTH=1024

# Opción C: Limitar peticiones paralelas
export OLLAMA_NUM_PARALLEL=1
```

### Error de tiempo en apt (build)
```
# Causa: reloj del sistema desincronizado
# Solución: sincronizar hora

sudo timedatectl set-ntp true
# o manualmente:
sudo ntpdate pool.ntp.org
sudo hwclock --systohc

# Workaround temporal en Containerfile:
# Agregar flag: -o Acquire::Check-Valid-Until=false
```

## 🤝 Contribuir
¡Las contribuciones son bienvenidas! 

```
# 1. Fork del repositorio desde GitHub

# 2. Clonar tu fork localmente
git clone https://github.com/TU_USUARIO/local-ai-assistant.git
cd local-ai-assistant

# 3. Crear rama para tu funcionalidad
git checkout -b feature/nueva-funcionalidad

# 4. Realizar cambios y commit
git add .
git commit -m "✨ Agrega nueva funcionalidad: descripción breve"

# 5. Push y crear Pull Request
git push origin feature/nueva-funcionalidad
# Luego visita GitHub para crear el PR
```

## 📄 Licencia
Este proyecto está bajo la Licencia MIT - ver el archivo LICENSE
 para detalles.
🙏 Agradecimientos

    Ollama
     - Framework de inferencia local
    Podman
     - Motor de contenedores rootless
    FastAPI
     - Framework web Python
    Comunidad Ollama - Por los modelos optimizados

📬 Contacto

	Proyecto: https://github.com/aems268/local-ai-assistant
    Issues: Reportar bug
    Discusión: GitHub Discussions
