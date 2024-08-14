#!/bin/bash

# Configuración
DIRECTORIO_TEMPORAL="/tmp"
DIRECTORIO_RESPALDO="/home/$(whoami)/respaldo"
ARCHIVOS_IMPORTANTES=("/etc/passwd" "/etc/hosts" "/home/$(whoami)/documentos")
LOGFILE="/var/log/mantenimiento.log"
UMBRAL_ESPACIO=10
PROCESOS_A_MONITOREAR=("apache2" "mysql")
ARCHIVO_CONFIG="/etc/configuracion.conf" # Ejemplo de archivo de configuración
UMBRAL_TEMPERATURA=75
DIRECTORIO_CACHES="/var/cache"
DIRECTORIO_LOGS="/var/log"
UMBRAL_ARCHIVO_GRANDE=100M
EMAIL_NOTIFICACION="tuemail@example.com"
SMTP_SERVER="smtp.example.com"
SMTP_PORT="587"
SMTP_USER="usuario"
SMTP_PASS="contraseña"
DIRECTORIO_BACKUP_DB="/home/$(whoami)/backup_db"
SERVIDORES_REMOTOS=("example.com" "example.org")
DIRECTORIO_PERMISOS="/etc"
CERTIFICADOS_SSL="/etc/ssl/certs"
DOCKER_REGISTRIES=("docker.io" "quay.io")
INTERVALO_SWAP=10
DIRECTORIO_ESCRITORIO="/home/$(whoami)/Escritorio" # Ajustar si el escritorio está en otra ruta

# Función para registrar mensajes en el archivo de log
registrar_log() {
  local mensaje=$1
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $mensaje" >> $LOGFILE
}

# Función para limpiar archivos temporales
limpiar_temporales() {
  echo "Limpiando archivos temporales en $DIRECTORIO_TEMPORAL..."
  sudo rm -rf $DIRECTORIO_TEMPORAL/*
  registrar_log "Limpiados archivos temporales en $DIRECTORIO_TEMPORAL."
  echo "Archivos temporales eliminados."
}

# Función para actualizar el sistema
actualizar_sistema() {
  echo "Actualizando el sistema..."
  sudo apt update && sudo apt upgrade -y
  sudo apt autoremove -y
  registrar_log "Sistema actualizado."
  echo "Sistema actualizado."
}

# Función para verificar la integridad de los paquetes
verificar_paquetes() {
  echo "Verificando la integridad de los paquetes..."
  sudo apt install -f
  registrar_log "Verificación de paquetes completada."
  echo "Verificación de paquetes completada."
}

# Función para hacer una copia de seguridad de archivos importantes
respaldo_archivos() {
  echo "Haciendo copia de seguridad de archivos importantes en $DIRECTORIO_RESPALDO..."
  mkdir -p $DIRECTORIO_RESPALDO
  for archivo in "${ARCHIVOS_IMPORTANTES[@]}"; do
    if [ -e "$archivo" ]; then
      cp -r "$archivo" "$DIRECTORIO_RESPALDO"
      registrar_log "Respaldo del archivo $archivo realizado."
    else
      registrar_log "El archivo $archivo no existe y no se puede respaldar."
    fi
  done
  echo "Copia de seguridad completada."
}

# Función para verificar el espacio en disco
verificar_espacio() {
  local espacio_libre=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
  if [ "$espacio_libre" -lt "$UMBRAL_ESPACIO" ]; then
    echo "Alerta: Solo queda $espacio_libre% de espacio libre en el disco."
    registrar_log "Alerta de espacio en disco: Solo queda $espacio_libre% libre."
  else
    echo "Espacio en disco suficiente: $espacio_libre% libre."
  fi
}

# Función para verificar procesos en ejecución
verificar_procesos() {
  echo "Verificando procesos en ejecución..."
  for proceso in "${PROCESOS_A_MONITOREAR[@]}"; do
    if pgrep "$proceso" > /dev/null; then
      echo "Alerta: El proceso $proceso está en ejecución."
      registrar_log "Alerta: El proceso $proceso está en ejecución."
    else
      echo "El proceso $proceso no está en ejecución."
    fi
  done
}

# Función para comprobar actualizaciones pendientes para paquetes Snap
verificar_snap() {
  echo "Verificando actualizaciones pendientes para Snap..."
  sudo snap refresh --list
  registrar_log "Verificación de actualizaciones de Snap completada."
}

# Función para verificar configuración de red
verificar_red() {
  echo "Verificando configuración de red..."
  ifconfig -a
  registrar_log "Verificación de configuración de red realizada."
}

# Función para verificar servicios críticos
verificar_servicios() {
  echo "Verificando servicios críticos..."
  systemctl list-units --type=service --state=running
  registrar_log "Verificación de servicios críticos completada."
}

# Función para limpiar cachés del sistema
limpiar_caches() {
  echo "Limpiando cachés del sistema en $DIRECTORIO_CACHES..."
  sudo rm -rf $DIRECTORIO_CACHES/*
  registrar_log "Cachés del sistema limpiados."
}

# Función para generar un informe del sistema
generar_informe() {
  echo "Generando informe del sistema..."
  uname -a > $DIRECTORIO_ESCRITORIO/informe_sistema.txt
  df -h >> $DIRECTORIO_ESCRITORIO/informe_sistema.txt
  free -m >> $DIRECTORIO_ESCRITORIO/informe_sistema.txt
  registrar_log "Informe del sistema generado en $DIRECTORIO_ESCRITORIO/informe_sistema.txt."
}

# Función para controlar la temperatura del CPU
verificar_temperatura() {
  echo "Verificando temperatura del CPU..."
  local temperatura=$(sensors | grep 'Core 0' | awk '{print $3}' | sed 's/+//;s/°C//')
  if [ "$temperatura" -gt "$UMBRAL_TEMPERATURA" ]; then
    echo "Alerta: La temperatura del CPU es $temperatura°C."
    registrar_log "Alerta de temperatura: $temperatura°C."
  else
    echo "Temperatura del CPU adecuada: $temperatura°C."
  fi
}

# Función para comprobar archivos de configuración con errores
verificar_configuracion() {
  echo "Verificando archivos de configuración..."
  sudo configtest
  registrar_log "Verificación de archivos de configuración realizada."
}

# Función para verificar permisos de archivos importantes
verificar_permisos() {
  echo "Verificando permisos de archivos importantes..."
  for archivo in "${ARCHIVOS_IMPORTANTES[@]}"; do
    if [ -e "$archivo" ]; then
      ls -l "$archivo"
    else
      echo "El archivo $archivo no existe."
    fi
  done
  registrar_log "Verificación de permisos completada."
}

# Función para detectar archivos grandes
detectar_archivos_grandes() {
  echo "Detectando archivos grandes en /..."
  find / -type f -size +$UMBRAL_ARCHIVO_GRANDE -exec ls -lh {} \; > $DIRECTORIO_ESCRITORIO/archivos_grandes.txt
  registrar_log "Detección de archivos grandes realizada. Resultados en $DIRECTORIO_ESCRITORIO/archivos_grandes.txt."
}

# Función para comprobar integridad del sistema de archivos
verificar_integridad() {
  echo "Verificando integridad del sistema de archivos..."
  sudo fsck -n / > $DIRECTORIO_ESCRITORIO/integridad_sistema.txt
  registrar_log "Verificación de integridad del sistema de archivos completada. Resultados en $DIRECTORIO_ESCRITORIO/integridad_sistema.txt."
}

# Función para verificar archivos de log para errores
verificar_logs() {
  echo "Verificando archivos de log para errores..."
  grep -i error $DIRECTORIO_LOGS/* > $DIRECTORIO_ESCRITORIO/errores_logs.txt
  registrar_log "Verificación de archivos de log realizada. Errores guardados en $DIRECTORIO_ESCRITORIO/errores_logs.txt."
}

# Función para verificar actualizaciones de seguridad
verificar_actualizaciones_seguridad() {
  echo "Verificando actualizaciones de seguridad..."
  sudo apt list --upgradable | grep -i security > $DIRECTORIO_ESCRITORIO/actualizaciones_seguridad.txt
  registrar_log "Verificación de actualizaciones de seguridad realizada. Resultados en $DIRECTORIO_ESCRITORIO/actualizaciones_seguridad.txt."
}

# Función para enviar notificación por correo electrónico
enviar_notificacion() {
  local asunto=$1
  local mensaje=$2
  echo "$mensaje" | mail -s "$asunto" -S smtp="$SMTP_SERVER:$SMTP_PORT" -S smtp-user="$SMTP_USER" -S smtp-pass="$SMTP_PASS" "$EMAIL_NOTIFICACION"
  registrar_log "Notificación enviada: $asunto"
}

# Función para verificar conexiones de red activas
verificar_conexiones_red() {
  echo "Verificando conexiones de red activas..."
  netstat -tulnp > $DIRECTORIO_ESCRITORIO/conexiones_red.txt
  registrar_log "Verificación de conexiones de red activas realizada. Resultados en $DIRECTORIO_ESCRITORIO/conexiones_red.txt."
}

# Función para verificar procesos zombis
verificar_procesos_zombis() {
  echo "Verificando procesos zombis..."
  ps aux | grep 'Z' > $DIRECTORIO_ESCRITORIO/procesos_zombis.txt
  registrar_log "Verificación de procesos zombis realizada. Resultados en $DIRECTORIO_ESCRITORIO/procesos_zombis.txt."
}

# Función para analizar uso de disco por directorio
analizar_uso_disco() {
  echo "Analizando uso de disco por directorio..."
  du -sh /* > $DIRECTORIO_ESCRITORIO/uso_disco.txt
  registrar_log "Análisis de uso de disco completado. Resultados en $DIRECTORIO_ESCRITORIO/uso_disco.txt."
}

# Función para comprobar archivos huérfanos o enlaces rotos
verificar_enlaces_rotos() {
  echo "Verificando archivos huérfanos o enlaces rotos..."
  find / -type l ! -exec test -e {} \; -print > $DIRECTORIO_ESCRITORIO/enlaces_rotos.txt
  registrar_log "Verificación de enlaces rotos realizada. Resultados en $DIRECTORIO_ESCRITORIO/enlaces_rotos.txt."
}

# Función para hacer backup de bases de datos
backup_bases_datos() {
  echo "Haciendo backup de bases de datos..."
  mkdir -p $DIRECTORIO_BACKUP_DB
  for db in $(ls /var/lib/mysql); do
    mysqldump $db > "$DIRECTORIO_BACKUP_DB/${db}_backup.sql"
  done
  registrar_log "Backup de bases de datos realizado en $DIRECTORIO_BACKUP_DB."
}

# Función para verificar actualizaciones del sistema de paquetes (incluyendo PPA)
verificar_actualizaciones_ppas() {
  echo "Verificando actualizaciones de paquetes y PPA..."
  sudo apt update
  sudo apt list --upgradable > $DIRECTORIO_ESCRITORIO/actualizaciones_ppas.txt
  registrar_log "Verificación de actualizaciones de paquetes y PPA realizada. Resultados en $DIRECTORIO_ESCRITORIO/actualizaciones_ppas.txt."
}

# Función para monitorear el uso de la memoria swap
monitorear_swap() {
  echo "Monitoreando uso de memoria swap..."
  free -m | grep Swap > $DIRECTORIO_ESCRITORIO/monitoreo_swap.txt
  registrar_log "Monitoreo de uso de swap realizado. Resultados en $DIRECTORIO_ESCRITORIO/monitoreo_swap.txt."
}

# Función para verificar archivos y directorios con cambios recientes
verificar_cambios_recientes() {
  echo "Verificando archivos y directorios con cambios recientes..."
  find / -type f -mtime -7 -exec ls -lh {} \; > $DIRECTORIO_ESCRITORIO/cambios_recientes.txt
  registrar_log "Verificación de cambios recientes realizada. Resultados en $DIRECTORIO_ESCRITORIO/cambios_recientes.txt."
}

# Función para chequear configuración del firewall
verificar_firewall() {
  echo "Verificando configuración del firewall..."
  sudo ufw status > $DIRECTORIO_ESCRITORIO/configuracion_firewall.txt
  registrar_log "Verificación de configuración del firewall realizada. Resultados en $DIRECTORIO_ESCRITORIO/configuracion_firewall.txt."
}

# Función para reportar consumo de recursos por procesos
reportar_consumo_recursos() {
  echo "Reportando consumo de recursos por procesos..."
  top -b -n 1 | head -n 20 > $DIRECTORIO_ESCRITORIO/consumo_recursos.txt
  registrar_log "Reporte de consumo de recursos generado en $DIRECTORIO_ESCRITORIO/consumo_recursos.txt."
}

# Función para reiniciar servicios fallidos
reiniciar_servicios_fallidos() {
  echo "Reiniciando servicios fallidos..."
  systemctl list-units --type=service --state=failed | awk '{print $1}' | while read -r servicio; do
    sudo systemctl restart "$servicio"
    registrar_log "Reiniciado el servicio $servicio."
  done
}

# Función para verificar cron jobs
verificar_cron_jobs() {
  echo "Verificando cron jobs..."
  crontab -l > $DIRECTORIO_ESCRITORIO/cron_jobs.txt
  registrar_log "Verificación de cron jobs realizada. Resultados en $DIRECTORIO_ESCRITORIO/cron_jobs.txt."
}

# Función para verificar certificados SSL vencidos
verificar_certificados_ssl() {
  echo "Verificando certificados SSL vencidos..."
  find $CERTIFICADOS_SSL -type f -name "*.crt" -exec openssl x509 -in {} -noout -enddate \; > $DIRECTORIO_ESCRITORIO/certificados_ssl.txt
  registrar_log "Verificación de certificados SSL realizada. Resultados en $DIRECTORIO_ESCRITORIO/certificados_ssl.txt."
}

# Función para verificar actualizaciones disponibles para Docker
verificar_actualizaciones_docker() {
  echo "Verificando actualizaciones disponibles para Docker..."
  docker images --filter "dangling=true" -q | xargs docker rmi
  docker system df > $DIRECTORIO_ESCRITORIO/actualizaciones_docker.txt
  registrar_log "Verificación de actualizaciones de Docker realizada. Resultados en $DIRECTORIO_ESCRITORIO/actualizaciones_docker.txt."
}

# Función para verificar conexiones a servidores remotos
verificar_conexiones_remotas() {
  echo "Verificando conexiones a servidores remotos..."
  for servidor in "${SERVIDORES_REMOTOS[@]}"; do
    ping -c 4 "$servidor" > $DIRECTORIO_ESCRITORIO/conexiones_remotas.txt
  done
  registrar_log "Verificación de conexiones a servidores remotos realizada. Resultados en $DIRECTORIO_ESCRITORIO/conexiones_remotas.txt."
}

# Función para comprobar permisos de archivos en directorios específicos
verificar_permisos_directorios() {
  echo "Verificando permisos de archivos en $DIRECTORIO_PERMISOS..."
  find $DIRECTORIO_PERMISOS -type f -exec ls -l {} \; > $DIRECTORIO_ESCRITORIO/permisos_directorios.txt
  registrar_log "Verificación de permisos en directorios realizada. Resultados en $DIRECTORIO_ESCRITORIO/permisos_directorios.txt."
}

# Función para escanear vulnerabilidades avanzadas
escanear_vulnerabilidades_avanzadas() {
  echo "Escaneando vulnerabilidades avanzadas con Lynis..."
  sudo lynis audit system --quiet > $DIRECTORIO_ESCRITORIO/vulnerabilidades_avanzadas.txt
  registrar_log "Escaneo de vulnerabilidades avanzadas realizado. Resultados en $DIRECTORIO_ESCRITORIO/vulnerabilidades_avanzadas.txt."
}

# Función para mostrar el menú y ejecutar la tarea seleccionada
mostrar_menu() {
  echo "Seleccione una opción:"
  echo "1. Limpiar archivos temporales"
  echo "2. Actualizar el sistema"
  echo "3. Verificar la integridad de los paquetes"
  echo "4. Hacer una copia de seguridad de archivos importantes"
  echo "5. Verificar el espacio en disco"
  echo "6. Verificar procesos en ejecución"
  echo "7. Verificar actualizaciones de Snap"
  echo "8. Verificar configuración de red"
  echo "9. Verificar servicios críticos"
  echo "10. Limpiar cachés del sistema"
  echo "11. Generar informe del sistema"
  echo "12. Controlar temperatura del CPU"
  echo "13. Verificar archivos de configuración"
  echo "14. Verificar permisos de archivos importantes"
  echo "15. Detectar archivos grandes"
  echo "16. Comprobar integridad del sistema de archivos"
  echo "17. Verificar archivos de log para errores"
  echo "18. Verificar actualizaciones de seguridad"
  echo "19. Enviar notificación por correo electrónico"
  echo "20. Verificar conexiones de red activas"
  echo "21. Verificar procesos zombis"
  echo "22. Analizar uso de disco"
  echo "23. Verificar enlaces rotos"
  echo "24. Backup de bases de datos"
  echo "25. Verificar actualizaciones de paquetes y PPA"
  echo "26. Monitorear uso de swap"
  echo "27. Verificar cambios recientes"
  echo "28. Verificar configuración del firewall"
  echo "29. Reportar consumo de recursos por procesos"
  echo "30. Reiniciar servicios fallidos"
  echo "31. Verificar cron jobs"
  echo "32. Verificar certificados SSL vencidos"
  echo "33. Verificar actualizaciones disponibles para Docker"
  echo "34. Verificar conexiones a servidores remotos"
  echo "35. Verificar permisos de archivos en directorios específicos"
  echo "36. Escanear vulnerabilidades básicas"
  echo "37. Escanear vulnerabilidades avanzadas"
  echo "38. Salir"
}

# Ejecutar la tarea seleccionada
ejecutar_opcion() {
  local opcion=$1
  case $opcion in
    1)
      limpiar_temporales
      ;;
    2)
      actualizar_sistema
      ;;
    3)
      verificar_paquetes
      ;;
    4)
      respaldo_archivos
      ;;
    5)
      verificar_espacio
      ;;
    6)
      verificar_procesos
      ;;
    7)
      verificar_snap
      ;;
    8)
      verificar_red
      ;;
    9)
      verificar_servicios
      ;;
    10)
      limpiar_caches
      ;;
    11)
      generar_informe
      ;;
    12)
      verificar_temperatura
      ;;
    13)
      verificar_configuracion
      ;;
    14)
      verificar_permisos
      ;;
    15)
      detectar_archivos_grandes
      ;;
    16)
      verificar_integridad
      ;;
    17)
      verificar_logs
      ;;
    18)
      verificar_actualizaciones_seguridad
      ;;
    19)
      enviar_notificacion "Asunto del Correo" "Mensaje del correo electrónico"
      ;;
    20)
      verificar_conexiones_red
      ;;
    21)
      verificar_procesos_zombis
      ;;
    22)
      analizar_uso_disco
      ;;
    23)
      verificar_enlaces_rotos
      ;;
    24)
      backup_bases_datos
      ;;
    25)
      verificar_actualizaciones_ppas
      ;;
    26)
      monitorear_swap
      ;;
    27)
      verificar_cambios_recientes
      ;;
    28)
      verificar_firewall
      ;;
    29)
      reportar_consumo_recursos
      ;;
    30)
      reiniciar_servicios_fallidos
      ;;
    31)
      verificar_cron_jobs
      ;;
    32)
      verificar_certificados_ssl
      ;;
    33)
      verificar_actualizaciones_docker
      ;;
    34)
      verificar_conexiones_remotas
      ;;
    35)
      verificar_permisos_directorios
      ;;
    36)
      echo "Escaneo de vulnerabilidades básicas..."
      lynis audit system --quiet | tee $DIRECTORIO_ESCRITORIO/vulnerabilidades_basicas.txt
      registrar_log "Escaneo de vulnerabilidades básicas realizado. Resultados en $DIRECTORIO_ESCRITORIO/vulnerabilidades_basicas.txt."
      ;;
    37)
      escanear_vulnerabilidades_avanzadas
      ;;
    38)
      echo "Saliendo del script."
      exit 0
      ;;
    *)
      echo "Opción inválida. Por favor seleccione una opción válida."
      ;;
  esac
}

# Menú principal
while true; do
  mostrar_menu
  read -p "Ingrese su opción: " opcion
  ejecutar_opcion $opcion
done