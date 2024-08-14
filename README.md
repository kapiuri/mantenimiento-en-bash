# Script de Mantenimiento del Sistema

Este script de Bash realiza una serie de tareas de mantenimiento y administración del sistema Linux. Incluye funciones para limpiar archivos temporales, actualizar el sistema, verificar el espacio en disco, respaldar archivos importantes, y más. Todos los informes y resultados se guardan en el escritorio del usuario.

## Contenido

- [Script de Mantenimiento del Sistema](#script-de-mantenimiento-del-sistema)
  - [Contenido](#contenido)
  - [Características](#características)
  - [Configuración](#configuración)
  - [Uso](#uso)

## Características

- Limpieza de archivos temporales
- Actualización del sistema
- Verificación de integridad de paquetes y permisos
- Copia de seguridad de archivos importantes
- Detección de archivos grandes
- Generación de informes del sistema
- Control de temperatura del CPU
- Verificación de configuraciones y servicios
- Escaneo de vulnerabilidades con Lynis
- Envío de notificaciones por correo electrónico

## Configuración

Antes de ejecutar el script, asegúrate de configurar las variables en la sección de configuración al inicio del archivo. Las principales variables que puedes necesitar ajustar incluyen:

- `DIRECTORIO_TEMPORAL`: Directorio para limpiar archivos temporales.
- `DIRECTORIO_RESPALDO`: Directorio donde se guardan los respaldos.
- `ARCHIVOS_IMPORTANTES`: Lista de archivos importantes a respaldar.
- `LOGFILE`: Archivo de registro para los mensajes del script.
- `UMBRAL_ESPACIO`: Umbral de espacio en disco (en %).
- `EMAIL_NOTIFICACION`: Dirección de correo electrónico para notificaciones.
- `SMTP_SERVER`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`: Credenciales del servidor SMTP para el envío de correos.

Asegúrate de que el directorio del escritorio (`DIRECTORIO_ESCRITORIO`) esté correctamente definido. Por defecto, está configurado para `/home/$(whoami)/Escritorio`.

## Uso

1. **Hacer el script ejecutable:**

   ```bash
   chmod +x script.sh
   ```

2. **Ejecutar el script:**

   ```bash
   ./mantenimiento.sh
   ```

3. **Requisitos**

- Sistema operativo: Linux
- Dependencias:
    -- lynx
  
    -- mailutils (para enviar correos electrónicos)
  
    -- sudo (para comandos que requieren privilegios administrativos)
  
    -- apt (para actualizaciones y gestión de paquetes)
