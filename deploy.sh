#!/bin/bash

# Termina el script si un comando falla. Esencial para el manejo de errores.
set -e

# --- Variables (Claridad del código) ---
IMAGE_NAME="devops-app"
IMAGE_TAG="1.0"
CONTAINER_NAME="mi-app-devops"
HOST_PORT="8080"
CONTAINER_PORT="8080" # El puerto que usará Node.js dentro del contenedor.
NODE_ENV="production"

# --- Funciones para mensajes claros ---
print_status() { echo -e "\n--- $1 ---"; }
print_success() { echo "✅ $1"; }
print_error() { echo "❌ Error: $1" >&2; exit 1; }

# --- Lógica del Script (Funcionalidad completa) ---

# 1. Verificar si Docker está instalado y corriendo.
print_status "Verificando instalación de Docker"
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor, instálalo."
fi
if ! docker info &> /dev/null; then
    print_error "El servicio de Docker no está corriendo. Por favor, inícialo."
fi
print_success "Docker está listo."

# 2. Limpieza de contenedor previo para evitar conflictos.
print_status "Limpiando contenedores antiguos"
if [ "$(docker ps -a -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Deteniendo y eliminando contenedor '${CONTAINER_NAME}'."
    docker stop ${CONTAINER_NAME} > /dev/null
    docker rm ${CONTAINER_NAME} > /dev/null
    print_success "Contenedor previo eliminado."
else
    echo "No se encontró un contenedor previo para limpiar."
fi

# 3. Construir la imagen automáticamente.
print_status "Construyendo la imagen Docker: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" . || print_error "Falló la construcción de la imagen."
print_success "Imagen construida exitosamente."

# 4. Ejecutar el contenedor con las variables de entorno adecuadas.
print_status "Ejecutando el contenedor"
docker run -d -p "${HOST_PORT}:${CONTAINER_PORT}" \
    --name "${CONTAINER_NAME}" \
    -e PORT="${CONTAINER_PORT}" \
    -e NODE_ENV="${NODE_ENV}" \
    "${IMAGE_NAME}:${IMAGE_TAG}" || print_error "Falló la ejecución del contenedor."
print_success "Contenedor '${CONTAINER_NAME}' iniciado."

# 5. Realizar una prueba básica para verificar que el servicio responde.
print_status "Verificando el estado del servicio (Health Check)"
echo "Esperando 5 segundos a que el servidor inicie..."
sleep 5
# Usamos el endpoint /health de tu app.js y --fail para que curl falle si el status no es 200.
if curl --fail --silent "http://localhost:${HOST_PORT}/health" > /dev/null; then
    print_success "La prueba de salud fue exitosa. El servicio está operativo."
else
    # Si falla, muestra los logs del contenedor para facilitar el diagnóstico.
    echo "Los logs del contenedor son:"
    docker logs ${CONTAINER_NAME}
    print_error "La prueba de salud falló. Revisa los logs de arriba."
fi

# 6. Imprimir un resumen del estado.
print_status "Resumen del Despliegue"
echo "🎉 ¡Despliegue completado con éxito! 🎉"
echo "  - Aplicación disponible en: http://localhost:${HOST_PORT}"
echo "  - Nombre del contenedor: ${CONTAINER_NAME}"
echo "  - Imagen: ${IMAGE_NAME}:${IMAGE_TAG}"