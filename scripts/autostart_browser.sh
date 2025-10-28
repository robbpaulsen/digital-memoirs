#!/bin/bash
# ============================================================
# Digital Memoirs - Autostart del Navegador en Modo Kiosk
# ============================================================
# Este script se ejecuta automáticamente cuando el usuario 'pi'
# inicia sesión en el escritorio (X11/Wayland)
#
# Espera a que Flask esté disponible y luego abre Chromium
# en modo kiosk (pantalla completa) mostrando /display
# ============================================================

# Configuración
FLASK_URL="http://localhost:5000/display"
MAX_WAIT=300  # Esperar máximo 5 minutos (300 segundos)
CHECK_INTERVAL=5  # Verificar cada 5 segundos

# Logging
LOG_FILE="/home/pi/.digital-memoirs-autostart.log"
echo "═══════════════════════════════════════════════════════" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Autostart del navegador iniciado" >> "$LOG_FILE"

# Función para verificar si Flask está disponible
check_flask_ready() {
    curl -s -f -o /dev/null "$FLASK_URL"
    return $?
}

# Esperar a que Flask esté disponible
echo "$(date '+%Y-%m-%d %H:%M:%S') - Esperando a que Flask esté disponible..." >> "$LOG_FILE"

ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if check_flask_ready; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ✅ Flask está disponible después de ${ELAPSED}s" >> "$LOG_FILE"
        break
    fi

    sleep $CHECK_INTERVAL
    ELAPSED=$((ELAPSED + CHECK_INTERVAL))

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Esperando... (${ELAPSED}/${MAX_WAIT}s)" >> "$LOG_FILE"
done

# Verificar si llegamos al timeout
if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ❌ TIMEOUT: Flask no respondió después de ${MAX_WAIT}s" >> "$LOG_FILE"

    # Intentar abrir de todas formas (tal vez Flask está corriendo pero tardó más)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Intentando abrir navegador de todas formas..." >> "$LOG_FILE"
fi

# Pequeño delay adicional para asegurar que Flask terminó de cargar
sleep 3

# Abrir Chromium en modo kiosk
echo "$(date '+%Y-%m-%d %H:%M:%S') - 🚀 Abriendo Chromium en modo kiosk..." >> "$LOG_FILE"

# Flags de Chromium:
# --kiosk                    : Modo pantalla completa sin barras
# --noerrdialogs             : Sin diálogos de error
# --disable-infobars         : Sin barras de información
# --no-first-run             : Sin asistente de primera ejecución
# --check-for-update-interval=31536000 : Deshabilitar actualizaciones automáticas
# --password-store=basic     : No usar keyring del sistema (evita pedir contraseña)
# --disable-session-crashed-bubble : Sin diálogo "Chromium cerró inesperadamente"
# --disable-restore-session-state  : No restaurar sesión anterior

chromium-browser \
    --kiosk \
    --noerrdialogs \
    --disable-infobars \
    --no-first-run \
    --check-for-update-interval=31536000 \
    --password-store=basic \
    --disable-session-crashed-bubble \
    --disable-restore-session-state \
    "$FLASK_URL" \
    >> "$LOG_FILE" 2>&1 &

CHROMIUM_PID=$!

echo "$(date '+%Y-%m-%d %H:%M:%S') - ✅ Chromium iniciado con PID: $CHROMIUM_PID" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - URL: $FLASK_URL" >> "$LOG_FILE"
echo "═══════════════════════════════════════════════════════" >> "$LOG_FILE"
