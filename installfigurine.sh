#!/bin/bash
# Este script instala la versión específica de Go (go1.25.3),
# figurine, y configura el PATH en .bashrc de root.

# 1. Configuración de variables
# Versión de Go que especificaste
GO_FILE="go1.25.3.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_FILE}" # URL oficial de descarga
GO_INSTALL_DIR="/usr/local"
GO_BIN_DIR="${GO_INSTALL_DIR}/go/bin"
# El path de Go para los binarios instalados como root
GOPATH_BIN_DIR="/root/go/bin"
BASHRC_FILE="/root/.bashrc"

# 2. Salir inmediatamente si un comando falla
set -e

# 3. Verificar que el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script debe ejecutarse como root (usa sudo)."
  exit 1
fi

echo "--- Iniciando la instalación de Go ${GO_FILE} ---"

# --- Paso 1: Instalar Go con wget ---
echo "Descargando ${GO_FILE}..."
# -q es modo silencioso, -O es para guardar con un nombre específico
if ! wget -q "${GO_URL}" -O "${GO_FILE}"; then
  echo "Error: No se pudo descargar ${GO_FILE}."
  echo "Por favor, verifica que la versión y la URL sean correctas."
  exit 1
fi

echo "Extrayendo Go en ${GO_INSTALL_DIR}..."
# Limpiar cualquier instalación anterior
rm -rf "${GO_INSTALL_DIR}/go"
# Extraer el archivo
tar -C "${GO_INSTALL_DIR}" -xzf "${GO_FILE}"
# Limpiar el archivo descargado
rm "${GO_FILE}"

# --- Paso 2: Configurar PATH temporalmente e instalar figurine ---
echo "Configurando PATH para esta sesión..."
export PATH=$PATH:${GO_BIN_DIR}

echo "Verificando la versión de Go:"
go version

echo "Instalando figurine..."
go install github.com/arsham/figurine@latest

# --- Paso 3: Poner las rutas en .bashrc ---
echo "Actualizando ${BASHRC_FILE}..."

# Añadir /usr/local/go/bin si no está presente
if ! grep -q "export PATH=\$PATH:${GO_BIN_DIR}" "${BASHRC_FILE}"; then
  echo "Añadiendo ${GO_BIN_DIR} al PATH de root."
  echo "export PATH=\$PATH:${GO_BIN_DIR}" >>"${BASHRC_FILE}"
fi

# Añadir /root/go/bin si no está presente
if ! grep -q "export PATH=\$PATH:${GOPATH_BIN_DIR}" "${BASHRC_FILE}"; then
  echo "Añadiendo ${GOPATH_BIN_DIR} al PATH de root."
  echo "export PATH=\$PATH:${GOPATH_BIN_DIR}" >>"${BASHRC_FILE}"
fi

# --- Paso 4: Ejecutar figurine con el nombre del equipo ---
echo "Generando arte ASCII para el nombre del equipo..."

# Añadimos el gopath al PATH de esta sesión para encontrar el binario de figurine
export PATH=$PATH:${GOPATH_BIN_DIR}

# Obtenemos el nombre del equipo y lo pasamos a figurine
TEAM_NAME=$(hostname)
figurine -f 3d.flf "${TEAM_NAME}"

echo "--- ¡Instalación completada! ---"
echo "Para que los cambios del PATH se apliquen permanentemente, cierra y"
echo "vuelve a abrir tu terminal o ejecuta: source ${BASHRC_FILE}"
