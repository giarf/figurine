#!/bin/bash
# Este script instala la ÚLTIMA versión estable de Go, figurine,
# y configura el PATH en .bashrc de root.

# 1. Salir inmediatamente si un comando falla
set -e

# 2. Verificar que el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script debe ejecutarse como root (usa sudo)."
  exit 1
fi

echo "--- Iniciando la instalación ---"

# --- Paso 1: Obtener la última versión estable de Go ---
echo "Buscando la última versión estable de Go..."
# Usamos el endpoint oficial de go.dev para obtener la versión
GO_LATEST=$(wget -qO- "https://go.dev/VERSION?m=text")
ARCH="linux-amd64" # Puedes cambiar esto si es necesario (ej: linux-arm64)

if [ -z "$GO_LATEST" ]; then
  echo "Error: No se pudo obtener la última versión de Go."
  exit 1
fi

GO_FILE="${GO_LATEST}.${ARCH}.tar.gz"
GO_URL="https://go.dev/dl/${GO_FILE}"
echo "Versión encontrada: ${GO_LATEST}"

# --- Paso 2: Descargar e Instalar Go ---
GO_INSTALL_DIR="/usr/local"
GO_BIN_DIR="${GO_INSTALL_DIR}/go/bin"

echo "Descargando ${GO_FILE}..."
wget -q "${GO_URL}" -O "${GO_FILE}"

echo "Extrayendo Go en ${GO_INSTALL_DIR}..."
# Limpiar cualquier instalación anterior
rm -rf "${GO_INSTALL_DIR}/go"
# Extraer el archivo
tar -C "${GO_INSTALL_DIR}" -xzf "${GO_FILE}"
# Limpiar el archivo descargado
rm "${GO_FILE}"

# --- Paso 3: Configurar PATH temporalmente e instalar figurine ---
echo "Configurando PATH para esta sesión..."
# Exportamos la ruta del Go recién instalado para usarlo ya mismo
export PATH=$PATH:${GO_BIN_DIR}

echo "Verificando la versión de Go:"
go version

echo "Instalando figurine..."
go install github.com/arsham/figurine@latest

# --- Paso 4: Poner las rutas en .bashrc ---
GOPATH_BIN_DIR="/root/go/bin"
BASHRC_FILE="/root/.bashrc"

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

# --- Paso 5: Ejecutar figurine con el nombre del equipo ---
echo "Generando arte ASCII para el nombre del equipo..."

# Añadimos el gopath al PATH de esta sesión para encontrar el binario de figurine
export PATH=$PATH:${GOPATH_BIN_DIR}

# Obtenemos el nombre del equipo y lo pasamos a figurine
TEAM_NAME=$(hostname)
figurine -f 3d.flf "${TEAM_NAME}"

echo "--- ¡Instalación completada! ---"
echo "Para que los cambios del PATH se apliquen permanentemente en esta terminal,"
echo "ejecuta ahora: source ${BASHRC_FILE}"
