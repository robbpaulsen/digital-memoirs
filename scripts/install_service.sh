#!/bin/bash
# ============================================================
# Digital Memoirs - Instalador Automático del Servicio systemd
# ============================================================
# Ejecutar en Raspberry Pi:
#   chmod +x install_service.sh
#   ./install_service.sh
# ============================================================

set -e  # Detener si hay errores

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   📦 Digital Memoirs - Instalador del Servicio systemd    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verificar que se está ejecutando en el directorio correcto
if [ ! -f "app.py" ]; then
    echo "❌ ERROR: Este script debe ejecutarse desde el directorio del proyecto"
    echo "   Ubicación actual: $(pwd)"
    echo "   Ejecuta: cd /home/pi/Downloads/repos/digital-memoirs"
    exit 1
fi

echo "✅ Directorio correcto detectado: $(pwd)"
echo ""

# Verificar que el usuario es pi
if [ "$(whoami)" != "pi" ]; then
    echo "⚠️ ADVERTENCIA: Este script está diseñado para el usuario 'pi'"
    echo "   Usuario actual: $(whoami)"
    read -p "¿Continuar de todas formas? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ============================================================
# Seleccionar versión del servicio
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Selecciona la versión del servicio a instalar:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1) VERSIÓN CON DELAY (3 minutos) - RECOMENDADA SI TIENES PROBLEMAS"
echo "   - Espera 3 minutos después del boot antes de iniciar"
echo "   - Más lenta pero más confiable"
echo "   - Usa TimeoutStartSec=240 para evitar timeout"
echo ""
echo "2) VERSIÓN SIN DELAY (10 segundos) - RECOMENDADA SI LA RED ES RÁPIDA"
echo "   - Espera solo 10 segundos"
echo "   - Arranque rápido (~30 segundos total)"
echo "   - Confía en systemd y dependencias de red"
echo ""

read -p "Selecciona [1 o 2]: " OPTION

case $OPTION in
    1)
        SERVICE_FILE="scripts/digital-memoirs-FIXED.service"
        VERSION_NAME="CON DELAY (3 minutos)"
        ;;
    2)
        SERVICE_FILE="scripts/digital-memoirs-NO-DELAY.service"
        VERSION_NAME="SIN DELAY (10 segundos)"
        ;;
    *)
        echo "❌ Opción inválida"
        exit 1
        ;;
esac

if [ ! -f "$SERVICE_FILE" ]; then
    echo "❌ ERROR: Archivo de servicio no encontrado: $SERVICE_FILE"
    exit 1
fi

echo "✅ Versión seleccionada: $VERSION_NAME"
echo "   Archivo: $SERVICE_FILE"
echo ""

# ============================================================
# Verificar pre-requisitos
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Verificando pre-requisitos..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar uv
if [ ! -f "/home/pi/.local/bin/uv" ]; then
    echo "❌ ERROR: uv no está instalado"
    echo "   Instala con: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi
echo "✅ uv encontrado: $(/home/pi/.local/bin/uv --version)"

# Verificar dnsmasq
if ! systemctl is-active --quiet dnsmasq; then
    echo "⚠️ ADVERTENCIA: dnsmasq no está corriendo"
    echo "   El servicio puede fallar al iniciar"
    read -p "¿Continuar de todas formas? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✅ dnsmasq está corriendo"
fi

# Verificar que app.py funciona
echo ""
echo "🧪 Probando que Flask puede iniciar..."
timeout 5s /home/pi/.local/bin/uv run app.py > /dev/null 2>&1 &
TEST_PID=$!
sleep 3
if ps -p $TEST_PID > /dev/null 2>&1; then
    kill $TEST_PID 2>/dev/null
    echo "✅ Flask puede iniciar correctamente"
else
    echo "⚠️ ADVERTENCIA: Flask no pudo iniciar en el test"
    echo "   Revisa las dependencias con: uv sync"
fi
wait $TEST_PID 2>/dev/null || true
echo ""

# ============================================================
# Backup del servicio anterior (si existe)
# ============================================================
if [ -f "/etc/systemd/system/digital-memoirs.service" ]; then
    BACKUP_FILE="/tmp/digital-memoirs.service.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Haciendo backup del servicio anterior..."
    sudo cp /etc/systemd/system/digital-memoirs.service "$BACKUP_FILE"
    echo "   Backup guardado en: $BACKUP_FILE"
    echo ""

    # Detener el servicio anterior
    if systemctl is-active --quiet digital-memoirs; then
        echo "⏹️  Deteniendo servicio anterior..."
        sudo systemctl stop digital-memoirs
        echo "   Servicio detenido"
        echo ""
    fi
fi

# ============================================================
# Instalar el servicio
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Instalando servicio..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Copiar archivo
sudo cp "$SERVICE_FILE" /etc/systemd/system/digital-memoirs.service
echo "✅ Archivo copiado a /etc/systemd/system/digital-memoirs.service"

# Establecer permisos
sudo chmod 644 /etc/systemd/system/digital-memoirs.service
echo "✅ Permisos establecidos (644)"

# Recargar systemd
sudo systemctl daemon-reload
echo "✅ systemd recargado (daemon-reload)"

# Habilitar el servicio
sudo systemctl enable digital-memoirs
echo "✅ Servicio habilitado para auto-inicio"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ INSTALACIÓN COMPLETADA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================
# Opciones post-instalación
# ============================================================
echo "🎯 ¿Qué deseas hacer ahora?"
echo ""
echo "1) Iniciar el servicio AHORA y ver logs en tiempo real"
echo "2) Solo iniciar el servicio (en background)"
echo "3) NO iniciar (solo dejar instalado para próximo boot)"
echo ""

read -p "Selecciona [1, 2 o 3]: " START_OPTION

case $START_OPTION in
    1)
        echo ""
        echo "🚀 Iniciando servicio..."
        sudo systemctl start digital-memoirs

        if [ "$OPTION" == "1" ]; then
            echo "⏳ Esperando 180 segundos (delay configurado)..."
            echo "   Mostrando logs en tiempo real..."
            echo "   Presiona Ctrl+C cuando quieras salir (el servicio seguirá corriendo)"
            echo ""
            sleep 3
            sudo journalctl -u digital-memoirs -f
        else
            echo "⏳ Esperando 10 segundos..."
            sleep 10
            echo ""
            echo "📊 Estado del servicio:"
            sudo systemctl status digital-memoirs --no-pager
        fi
        ;;
    2)
        echo ""
        echo "🚀 Iniciando servicio..."
        sudo systemctl start digital-memoirs

        if [ "$OPTION" == "1" ]; then
            echo "⏳ Nota: El servicio tiene un delay de 180 segundos antes de iniciar Flask"
            echo "   Espera 3 minutos y luego verifica con: sudo systemctl status digital-memoirs"
        fi

        echo ""
        echo "✅ Servicio iniciado en background"
        ;;
    3)
        echo ""
        echo "✅ Servicio instalado pero NO iniciado"
        echo "   Iniciará automáticamente en el próximo boot"
        echo "   Para iniciarlo manualmente: sudo systemctl start digital-memoirs"
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 COMANDOS ÚTILES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Ver status:          sudo systemctl status digital-memoirs"
echo "Ver logs en vivo:    sudo journalctl -u digital-memoirs -f"
echo "Reiniciar servicio:  sudo systemctl restart digital-memoirs"
echo "Detener servicio:    sudo systemctl stop digital-memoirs"
echo "Deshabilitar:        sudo systemctl disable digital-memoirs"
echo ""
echo "Probar endpoint:     curl http://localhost:5000/api/status"
echo "Ver en navegador:    http://10.0.17.1:5000/qr"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
