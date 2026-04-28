#!/usr/bin/env bash

set -o pipefail

# 🎨 Styles
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[90m'

# 🔤 Iconos
ICON_ROBOT='🤖'
ICON_CPU='⚙️'
ICON_RAM='🧠'
ICON_FOLDER='📁'
ICON_ROCKET='🚀'
ICON_CHECK='✅'
ICON_WARN='⚠️'
ICON_ERROR='❌'
ICON_INFO='ℹ️'
ICON_ARROW='➜'
ICON_SEARCH='🔍'
ICON_BUILD='🏗️'
ICON_PACKAGE='📦'
ICON_POWER='⏻'

# 🖨️ Functions
ok() { printf "${GREEN}${ICON_CHECK} %s${RESET}\n" "$*"; }
warn() { printf "${YELLOW}${ICON_WARN} %s${RESET}\n" "$*"; }
err() { printf "${RED}${ICON_ERROR} %s${RESET}\n" "$*"; exit 1; }
info() { printf "${CYAN}${ICON_INFO} %s${RESET}\n" "$*"; }
bold() { printf "${BOLD}%s${RESET}\n" "$*"; }
title() { printf "\n${BOLD}${CYAN}╭─ %s ──────────────────────────╮${RESET}\n" "$*"; }
dim() { printf "${DIM}%s${RESET}\n" "$*"; }
step() { printf "${BOLD}${CYAN}━━━ %s ━━━${RESET}\n" "$*"; }

# 📦 Catálogo de modelos
MODELS=(
  "qwen2.5:0.5b|0.4|Ultra-ligero (400MB)"
  "tinyllama:1.1b|0.7|Equilibrado (700MB)"
  "llama3.2:1b|1.1|Calidad premium (1.1GB)"
  "qwen2.5:1.5b|1.8|Máxima calidad (1.8GB)"
)

# 🧮 Normalizar RAM
normalize_ram() {
  local input="$1"
  if [[ "$input" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "${input}g"
  elif [[ "$input" =~ ^[0-9]+(\.[0-9]+)?[gGmM]$ ]]; then
    echo "$input"
  else
    echo "${input}g"
  fi
}

# 🧮 Parsear RAM a GB
parse_ram_gb() {
  local input="$1"
  local num="${input//[!0-9.]/}"
  local unit="${input//[0-9.]/}"
  unit="${unit,,}"
  
  case "$unit" in
    g|gb|"") echo "$num" ;;
    m|mb) 
      if [[ "$num" == "512" ]]; then echo "0.5"
      elif [[ "$num" == "1024" ]]; then echo "1"
      elif [[ "$num" == "2048" ]]; then echo "2"
      else echo "1"
      fi
      ;;
    *) echo "$num" ;;
  esac
}

# 🏗️ Construir imagen si no existe
build_image_if_needed() {
  step "${ICON_PACKAGE} VERIFICANDO IMAGEN"
  
  local image_name="localhost/local-ai-assistant:latest"
  
  if podman image exists "$image_name" 2>/dev/null; then
    ok "Imagen ya existe: $image_name"
    return 0
  fi
  
  warn "Imagen no encontrada. Construyendo..."
  printf "\n"
  
  local required_files=("Containerfile" "assistant.py" "entrypoint.sh" "index.html")
  local missing=()
  
  for file in "${required_files[@]}"; do
    [[ ! -f "$file" ]] && missing+=("$file")
  done
  
  [[ ${#missing[@]} -gt 0 ]] && err "Archivos faltantes:\n   ${missing[*]}"
  
  info "Construyendo imagen (5-10 min)..."
  dim "Descargando base ollama/ollama..."
  printf "\n"
  
  podman build -t "$image_name" . && ok "¡Imagen construida!" || err "Falló la construcción"
}

# 🚀 Main
main() {
  clear
  bold "${ICON_ROBOT} ASISTENTE IA LOCAL • DEPLOYER"
  dim "Presiona Enter para usar valores por defecto"
  printf "\n"

  command -v podman &>/dev/null || err "Podman no encontrado"
  
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$script_dir" || err "No se pudo acceder al directorio"
  
  dim "Directorio: $script_dir"
  printf "\n"

  build_image_if_needed
  printf "\n"

  # ───────── PASO 1: RECURSOS (Defaults: CPU=2, RAM=2g) ─────────
  title "${ICON_CPU} RECURSOS"
  
  printf "${CYAN}${ICON_ARROW} Núcleos CPU [2]: ${RESET}"
  read -r CPU
  CPU="${CPU:-2}"
  
  printf "${CYAN}${ICON_ARROW} Memoria RAM [2g]: ${RESET}"
  read -r RAM
  RAM="${RAM:-2g}"
  
  RAM=$(normalize_ram "$RAM")
  ram_gb=$(parse_ram_gb "$RAM")
  ok "CPU: $CPU | RAM: $RAM (~${ram_gb}GB)"

  # ───────── PASO 2: MODELOS (Default: 1) ─────────
  title "${ICON_SEARCH} MODELOS"
  
  dim "Compatibles con ${ram_gb}GB:"
  printf "\n"
  
  compatible=()
  idx=0
  
  for entry in "${MODELS[@]}"; do
    name="${entry%%|*}"
    rest="${entry#*|}"
    ram_req="${rest%%|*}"
    desc="${rest#*|}"
    
    check=$(awk -v a="$ram_req" -v b="$ram_gb" 'BEGIN{print (a<=b)?1:0}')
    
    if [[ "$check" == "1" ]]; then
      idx=$((idx + 1))
      compatible+=("$name")
      printf "${DIM}%d.${RESET} ${BOLD}%s${RESET} ${GRAY}(%sGB)${RESET} - %s\n" "$idx" "$name" "$ram_req" "$desc"
      printf "\n"
    fi
  done
  
  [[ ${#compatible[@]} -eq 0 ]] && err "Sin modelos para ${ram_gb}GB"
  
  printf "${CYAN}${ICON_ARROW} Elige modelo [1]: ${RESET}"
  read -r choice
  choice="${choice:-1}"
  
  if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#compatible[@]} ]]; then
    SELECTED_MODEL="${compatible[$((choice-1))]}"
  else
    SELECTED_MODEL="${compatible[0]}"
    warn "Opción inválida. Usando: $SELECTED_MODEL"
  fi
  ok "Modelo: $SELECTED_MODEL"

  # ───────── PASO 3: CARPETA (Default: shared) ─────────
  title "${ICON_FOLDER} CARPETA COMPARTIDA"
  
  BASE_DIR="${AI_PROJECT_BASE:-$PWD}"
  dim "Base: $BASE_DIR"
  
  printf "${CYAN}${ICON_ARROW} Nombre carpeta [shared]: ${RESET}"
  read -r folder
  folder="${folder:-shared}"
  
  [[ "$folder" == */* ]] && err "Solo el nombre (sin /)"
  
  VOLUME_PATH="${BASE_DIR}/${folder}"
  mkdir -p "$VOLUME_PATH" 2>/dev/null || {
    VOLUME_PATH="$HOME/ai-shared/${folder}"
    mkdir -p "$VOLUME_PATH" || err "No se pudo crear"
    warn "Ubicación alternativa: $VOLUME_PATH"
  }
  ok "Volumen: $VOLUME_PATH"

  # ───────── PASO 4: DESPLIEGUE ─────────
  title "${ICON_ROCKET} DESPLIEGUE"
  
  SELINUX=""
  if command -v getenforce &>/dev/null && [[ "$(getenforce 2>/dev/null)" != "Disabled" ]]; then
    SELINUX=":Z"
    info "SELinux: :Z"
  fi
  
  printf "\n"
  bold "CONFIGURACIÓN FINAL"
  printf "${DIM}━${RESET} Modelo:   %s\n" "$SELECTED_MODEL"
  printf "${DIM}━${RESET} CPU:      %s núcleos\n" "$CPU"
  printf "${DIM}━${RESET} RAM:      %s\n" "$RAM"
  printf "${DIM}━${RESET} Carpeta:  %s\n" "$folder"
  printf "\n"
  
  printf "${YELLOW}¿Desplegar? [y/N]: ${RESET}"
  read -r confirm
  [[ ! "$confirm" =~ ^[Yy]$ ]] && { info "Cancelado"; exit 0; }

  printf "\n"
  bold "${ICON_ROCKET} Desplegando..."
  podman rm -f ai-assistant 2>/dev/null || true
  
  if podman run -d --name ai-assistant \
    --cpus "$CPU" --memory "$RAM" --memory-swap "$RAM" \
    -v "${VOLUME_PATH}:/shared${SELINUX}" \
    -p 8080:8080 -p 11434:11434 \
    -e MODEL_NAME="$SELECTED_MODEL" \
    localhost/local-ai-assistant:latest; then
    
    sleep 3
    if podman ps | grep -q ai-assistant; then
      printf "\n"
      ok "¡DESPLIEGUE EXITOSO!"
      printf "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
      info "🌐 Web: http://localhost:8080"
      warn "⏳ Primera carga del modelo: ~60s"
    else
      warn "El contenedor no respondió. Revisa: podman logs ai-assistant"
    fi
  else
    err "Falló el despliegue"
  fi

  # ───────── MENÚ FINAL (Script se mantiene activo) ─────────
  printf "\n"
  title "${ICON_POWER} GESTIÓN DEL CONTENEDOR"
  dim "El script permanecerá activo hasta que elijas una opción:"
  printf "\n"
  printf "  ${DIM}1.${RESET} Detener contenedor ${GRAY}(por defecto)${RESET}\n"
  printf "  ${DIM}2.${RESET} Detener y eliminar contenedor\n"
  printf "\n"
  
  while true; do
    printf "${CYAN}${ICON_ARROW} Elige opción [1]: ${RESET}"
    read -r action
    action="${action:-1}"
    
    case "$action" in
      1)
        info "Deteniendo contenedor..."
        podman stop ai-assistant 2>/dev/null && ok "Contenedor detenido." || warn "Ya estaba detenido."
        dim "💡 Para reiniciarlo luego: podman start ai-assistant"
        break
        ;;
      2)
        warn "Deteniendo y eliminando contenedor..."
        podman rm -f ai-assistant 2>/dev/null && ok "Contenedor eliminado." || warn "Ya no existía."
        dim "🔄 Para volver a usarlo, ejecuta el script nuevamente."
        break
        ;;
      *)
        warn "Opción inválida. Usa 1 o 2."
        ;;
    esac
  done
  
  printf "\n"
  ok "¡Sesión finalizada! 👋"
}

main "$@"
