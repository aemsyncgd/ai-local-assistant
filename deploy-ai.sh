#!/usr/bin/env bash

set -o pipefail

# 🎨 Styles - Usar printf para compatibilidad
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[90m'

# 🔤 Iconos Unicode
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

# 🖨️ Functions con printf (más compatible)
ok() { printf "${GREEN}${ICON_CHECK} %s${RESET}\n" "$*"; }
warn() { printf "${YELLOW}${ICON_WARN} %s${RESET}\n" "$*"; }
err() { printf "${RED}${ICON_ERROR} %s${RESET}\n" "$*"; exit 1; }
info() { printf "${CYAN}${ICON_INFO} %s${RESET}\n" "$*"; }
bold() { printf "${BOLD}%s${RESET}\n" "$*"; }
title() { printf "\n${BOLD}${CYAN}╭─ %s ──────────────────────────╮${RESET}\n" "$*"; }
dim() { printf "${DIM}%s${RESET}\n" "$*"; }

# 📦 Catálogo
MODELS=(
  "qwen2.5:0.5b|0.4|Ultra-ligero (400MB)"
  "tinyllama:1.1b|0.7|Equilibrado (700MB)"
  "llama3.2:1b|1.1|Calidad premium (1.1GB)"
  "qwen2.5:1.5b|1.8|Máxima calidad (1.8GB)"
)

# 🧮 Normalizar RAM (agregar 'g' si no tiene unidad)
normalize_ram() {
  local input="$1"
  
  # Si es solo número, agregar 'g'
  if [[ "$input" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "${input}g"
  # Si ya tiene 'g' o 'm', dejarlo así
  elif [[ "$input" =~ ^[0-9]+(\.[0-9]+)?[gGmM]$ ]]; then
    echo "$input"
  else
    echo "${input}g" # default
  fi
}

# 🧮 Parsear RAM a GB numérico
parse_ram_gb() {
  local input="$1"
  local num="${input//[!0-9.]/}"
  local unit="${input//[0-9.]/}"
  unit="${unit,,}"
  
  case "$unit" in
    g|gb|"") echo "$num" ;;
    m|mb) 
      # Aproximación simple
      if [[ "$num" == "512" ]]; then echo "0.5"
      elif [[ "$num" == "1024" ]]; then echo "1"
      elif [[ "$num" == "2048" ]]; then echo "2"
      else echo "1"
      fi
      ;;
    *) echo "$num" ;;
  esac
}

# 🚀 Main
main() {
  clear
  bold "${ICON_ROBOT} ASISTENTE IA LOCAL • DEPLOYER"
  dim "Offline - Catálogo local"
  printf "\n"

  # Verificar Podman
  if ! command -v podman &>/dev/null; then
    err "Podman no encontrado"
  fi

  # PASO 1
  title "${ICON_CPU} RECURSOS"
  
  printf "${CYAN}${ICON_ARROW} CPU [1.5]: ${RESET}"
  read -r CPU
  CPU="${CPU:-1.5}"
  
  printf "${CYAN}${ICON_ARROW} RAM [1.5g]: ${RESET}"
  read -r RAM
  RAM="${RAM:-1.5g}"
  
  # Normalizar RAM (CRÍTICO)
  RAM=$(normalize_ram "$RAM")
  ram_gb=$(parse_ram_gb "$RAM")
  
  ok "CPU: $CPU | RAM: $RAM (~${ram_gb}GB)"

  # PASO 2
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
    
    # Comparar
    check=$(awk -v a="$ram_req" -v b="$ram_gb" 'BEGIN{print (a<=b)?1:0}')
    
    if [[ "$check" == "1" ]]; then
      idx=$((idx + 1))
      compatible+=("$name")
      printf "${DIM}%d.${RESET} ${BOLD}%s${RESET} ${GRAY}(%sGB)${RESET} - %s\n" "$idx" "$name" "$ram_req" "$desc"
      printf "\n"
    fi
  done
  
  if [[ ${#compatible[@]} -eq 0 ]]; then
    err "Sin modelos para ${ram_gb}GB. Mínimo 0.5g"
  fi
  
  # Seleccionar
  while true; do
    printf "${CYAN}${ICON_ARROW} Elige [1-%d]: ${RESET}" "${#compatible[@]}"
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#compatible[@]} ]]; then
      SELECTED_MODEL="${compatible[$((choice-1))]}"
      ok "Modelo: $SELECTED_MODEL"
      break
    else
      warn "Usa 1-${#compatible[@]}"
    fi
  done

  # PASO 3
  title "${ICON_FOLDER} CARPETA"
  
  BASE_DIR="${AI_PROJECT_BASE:-$HOME/Almacen/Privado/docker-projects/local-ai-assistant}"
  dim "Base: $BASE_DIR"
  
  printf "${CYAN}${ICON_ARROW} Nombre [shared]: ${RESET}"
  read -r folder
  folder="${folder:-shared}"
  
  if [[ "$folder" == */* ]]; then
    err "Solo el nombre (sin /)"
  fi
  
  VOLUME_PATH="${BASE_DIR}/${folder}"
  mkdir -p "$VOLUME_PATH"
  ok "Volumen: $VOLUME_PATH"

  # DESPLIEGUE
  title "${ICON_ROCKET} DESPLEGAR"
  
  SELINUX=""
  if command -v getenforce &>/dev/null; then
    if [[ "$(getenforce 2>/dev/null)" != "Disabled" ]]; then
      SELINUX=":Z"
      info "SELinux: :Z"
    fi
  fi
  
  printf "\n"
  bold "CONFIGURACIÓN"
  printf "Modelo:  %s\n" "$SELECTED_MODEL"
  printf "CPU:     %s\n" "$CPU"
  printf "RAM:     %s\n" "$RAM"
  printf "Volumen: %s\n" "$VOLUME_PATH"
  printf "\n"
  
  printf "${YELLOW}¿Desplegar? [y/N]: ${RESET}"
  read -r confirm
  
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    info "Cancelado"
    exit 0
  fi

  printf "\n"
  bold "Iniciando..."
  podman rm -f ai-assistant 2>/dev/null || true
  
  # Ejecutar y verificar
  if podman run -d --name ai-assistant \
    --cpus "$CPU" --memory "$RAM" --memory-swap "$RAM" \
    -v "${VOLUME_PATH}:/shared${SELINUX}" \
    -p 8080:8080 -p 11434:11434 \
    -e MODEL_NAME="$SELECTED_MODEL" \
    localhost/local-ai-assistant:latest; then
    
    # Verificar que el contenedor esté corriendo
    sleep 3
    if podman ps | grep -q ai-assistant; then
      printf "\n"
      ok "¡Despliegue exitoso!"
      printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
      info "Web: http://localhost:8080"
      info "Logs: podman logs -f ai-assistant"
      warn "Espera ~60s primera carga"
    else
      printf "\n"
      warn "El contenedor se creó pero no está corriendo"
      info "Revisa logs: podman logs ai-assistant"
      info "Posible causa: Memoria insuficiente"
    fi
  else
    printf "\n"
    err "Falló el despliegue. Verifica:\n  - Imagen existe: podman images | grep local-ai-assistant\n  - Memoria suficiente: free -h"
  fi
}

main "$@"
