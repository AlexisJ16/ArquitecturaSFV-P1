# ArquitecturaSFV-P1

# Evaluación Práctica - Ingeniería de Software V

## Información del Estudiante
- **Nombre:** [Tu Nombre Completo]
- **Código:** [Tu Código de Estudiante]
- **Fecha:** [Fecha Actual]

## Resumen de la Solución
Esta solución implementa una aplicación Node.js y la despliega en un entorno aislado y reproducible utilizando Docker. El proceso está totalmente automatizado mediante un script de Bash (`deploy.sh`) que maneja la verificación de dependencias, la construcción de la imagen, la ejecución del contenedor y una prueba de salud para confirmar que el despliegue fue exitoso.

## Dockerfile
Para la creación del `Dockerfile`, se tomaron decisiones clave para optimizar la seguridad, el tamaño y la eficiencia, cumpliendo con las mejores prácticas de la industria:

- **Construcción Multietapa (Multi-stage Build):** Se usaron dos etapas. Una `builder` para instalar dependencias y otra `production` para la imagen final. Esto reduce drásticamente el tamaño de la imagen (de ~400MB a ~55MB) al no incluir herramientas de compilación innecesarias.
- **Imagen Base Ligera (`node:18-alpine`):** Se eligió la variante `alpine` de Node.js por su tamaño reducido, lo que disminuye la superficie de ataque y acelera la distribución.
- **Optimización de Caché de Docker:** Se copia `package.json` y se ejecuta `npm install` antes de copiar el resto del código. Esto permite que Docker reutilice la capa de dependencias si solo cambia el código fuente, acelerando significativamente las reconstrucciones.
- **Usuario No-Root:** Por seguridad, la aplicación se ejecuta con el usuario `node` (sin privilegios) en lugar de `root`, limitando el acceso al sistema anfitrión en caso de una vulnerabilidad.

## Script de Automatización
El script `deploy.sh` orquesta todo el despliegue localmente. Sus características son:

- **Robustez:** Usa `set -e` para detener la ejecución ante cualquier error.
- **Verificación de Entorno:** Comprueba que Docker esté instalado y en ejecución.
- **Idempotencia:** Siempre limpia contenedores anteriores con el mismo nombre para asegurar un estado de inicio limpio.
- **Automatización Total:** Construye, ejecuta y prueba la aplicación con un solo comando.
- **Prueba de Salud:** Valida activamente que el servicio responde correctamente al endpoint `/health` después del despliegue.
- **Feedback Claro:** Informa al usuario sobre cada paso del proceso con mensajes de estado y un resumen final.

## Principios DevOps Aplicados
1.  **Automatización:** El script `deploy.sh` es la encarnación de este principio. Automatiza un proceso manual y propenso a errores, garantizando consistencia y fiabilidad en cada ejecución.
2.  **Infraestructura como Código (IaC):** El `Dockerfile` define el entorno de la aplicación como código. Es versionable, reproducible y portátil, eliminando el problema de "en mi máquina funciona". Cualquiera con Docker puede recrear el entorno exacto.
3.  **Integración y Entrega Continuas (CI/CD):** Esta solución es el primer paso para un pipeline de CI/CD. El script y el Dockerfile son los componentes que una herramienta como GitHub Actions o Jenkins usaría para automatizar las pruebas y los despliegues en diferentes entornos (desarrollo, producción) tras cada cambio en el código.

## Captura de Pantalla
[Aquí, inserta una captura de pantalla de tu terminal después de ejecutar `./deploy.sh` con éxito. Debe mostrar el resumen final.]


## Mejoras Futuras
1.  **Implementar un Pipeline de CI/CD:** Usar GitHub Actions para automatizar la ejecución del script `deploy.sh` en cada `push` a la rama principal, publicando la imagen en un registro como Docker Hub.
2.  **Orquestación con Docker Compose:** Añadir un archivo `docker-compose.yml` para gestionar la aplicación. Esto simplificaría la ejecución y facilitaría la adición de otros servicios en el futuro (ej. una base de datos).
3.  **Pruebas Unitarias Reales:** Integrar un framework de pruebas como Jest. El `Dockerfile` se podría modificar para ejecutar `npm test` en la etapa de `build`, deteniendo la construcción si las pruebas fallan y evitando que código defectuoso sea desplegado.

## Instrucciones para Ejecutar
1.  Clonar este repositorio.
2.  Asegurarse de tener Docker instalado y en ejecución.
3.  Dar permisos de ejecución al script: `chmod +x deploy.sh`
4.  Ejecutar el script: `./deploy.sh`
5.  La aplicación estará disponible en `http://localhost:8080`.