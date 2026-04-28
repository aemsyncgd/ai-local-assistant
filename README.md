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

```bash
# 1. Clonar repositorio
git clone https://github.com/aems268/local-ai-assistant.git
cd local-ai-assistant

# 2. Dar permisos de ejecución
chmod +x deploy-ai.sh

# 3. Ejecutar asistente de despliegue
./deploy-ai.sh o ./deploy-full-ai.sh

¡Listo! El script:

    ✅ Verifica/instala dependencias
    ✅ Construye la imagen de Podman
    ✅ Descarga el modelo de IA
    ✅ Configura volúmenes y puertos
    ✅ Inicia el contenedor automáticamente

Método 2: Manual (Avanzado)

bash
1
2
3
4
5
6
7
8
9
10

🎯 Uso
Acceso a la Interfaz Web
Una vez desplegado, abre tu navegador en:

1

API REST
También puedes usar la API directamente:

bash
1
2
3
4
5
6
7
8
9
10
11
12

Ejemplos de Uso
📄 Analizar configuración de red

bash
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15

🔧 Generar script de monitoreo

bash
1
2
3
4
5
6

️ Configuración
Modelos Disponibles
El script deploy-ai.sh te permite elegir entre varios modelos optimizados:
Modelo
	
RAM
	
Velocidad
	
Calidad
	
Ideal para
qwen2.5:0.5b
	
400MB
	
⚡⚡⚡
	
⭐⭐⭐
	
Hardware antiguo
tinyllama:1.1b
	
700MB
	
⚡⚡⚡⚡
	
⭐⭐⭐
	
Uso general
llama3.2:1b
	
1.1GB
	
⚡⚡
	
⭐⭐⭐⭐⭐
	
Calidad premium
qwen2.5:1.5b
	
1.8GB
	
⚡
	
⭐⭐⭐⭐⭐
	
Hardware potente
Variables de Entorno

bash
1
2
3
4

Gestión del Contenedor

bash
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17

📁 Estructura del Proyecto

1
2
3
4
5
6
7
8
9

🔧 Arquitectura

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20

🐛 Troubleshooting
El contenedor no inicia

bash
1
2
3
4
5
6
7
8

Error "OOM-killed"

bash
1
2
3
4
5

La web no responde

bash
1
2
3
4
5
6
7
8
9

Modelo muy lento

bash
1
2
3
4
5
6

🤝 Contribuir
¡Las contribuciones son bienvenidas! 

bash
1
2
3
4
5
6
7
8
9
10
11
12

📄 Licencia
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
