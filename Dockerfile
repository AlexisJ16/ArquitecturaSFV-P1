# --- Etapa 1: Builder ---
# Usamos una imagen de Node.js ligera (basada en Alpine Linux) para la construcción.
# Le damos un alias "builder" para referenciarla después.
FROM node:18-alpine AS builder

# Establecemos el directorio de trabajo dentro del contenedor.
WORKDIR /usr/src/app

# Copiamos package.json y package-lock.json (si existiera).
# Esto aprovecha la caché de Docker: si estos archivos no cambian,
# no se volverán a instalar las dependencias, acelerando futuras construcciones.
COPY package*.json ./

# Instalamos SOLAMENTE las dependencias de producción. Tu package.json solo
# tiene "dependencies", así que esto es perfecto.
RUN npm install --omit=dev

# Copiamos el resto de los archivos, incluyendo tu app.js.
COPY . .

# --- Etapa 2: Production ---
# Empezamos de nuevo desde la misma imagen ligera para la producción.
FROM node:18-alpine

WORKDIR /usr/src/app

# Copiamos únicamente los artefactos necesarios desde la etapa "builder".
# Esto crea una imagen final mucho más pequeña y segura.
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/app.js ./app.js

# EXPOSE documenta que el contenedor escuchará en el puerto 8080.
# La rúbrica especifica este puerto para la ejecución.
EXPOSE 8080

# Práctica de seguridad clave: Creamos un usuario sin privilegios 'node'
# y lo usamos para ejecutar la aplicación. Evita correr como 'root'.
USER node

# Comando final para ejecutar la aplicación. Usa el script "start" de tu package.json.
CMD ["node", "app.js"]