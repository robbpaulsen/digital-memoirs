#!/bin/bash
# ============================================================
# Digital Memoirs - Script de Diagnóstico Completo
# ============================================================
# Ejecutar en Raspberry Pi:
#   chmod +x diagnose_service.sh
#   ./diagnose_service.sh > diagnosis_report.txt 2>&1
# ============================================================

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   🔍 Digital Memoirs - Diagnóstico Completo del Servicio  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Fecha: $(date)"
echo "Usuario ejecutando: $(whoami)"
echo ""

# ============================================================
# 1. Información del Sistema
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  INFORMACIÓN DEL SISTEMA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime)"
echo ""

# ============================================================
# 2. Verificación de Rutas y Archivos
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  VERIFICACIÓN DE RUTAS Y ARCHIVOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "[CHECK] Verificando uv:"
if [ -f "/home/pi/.local/bin/uv" ]; then
    echo "✅ uv encontrado"
    ls -la /home/pi/.local/bin/uv
    /home/pi/.local/bin/uv --version
else
    echo "❌ ERROR: uv NO encontrado en /home/pi/.local/bin/uv"
fi
echo ""

echo "[CHECK] Verificando directorio del proyecto:"
if [ -d "/home/pi/Downloads/repos/digital-memoirs" ]; then
    echo "✅ Directorio del proyecto existe"
    ls -la /home/pi/Downloads/repos/digital-memoirs/
else
    echo "❌ ERROR: Directorio NO encontrado"
fi
echo ""

echo "[CHECK] Verificando app.py:"
if [ -f "/home/pi/Downloads/repos/digital-memoirs/app.py" ]; then
    echo "✅ app.py encontrado"
    ls -la /home/pi/Downloads/repos/digital-memoirs/app.py
    echo "Primeras 10 líneas de app.py:"
    head -n 10 /home/pi/Downloads/repos/digital-memoirs/app.py
else
    echo "❌ ERROR: app.py NO encontrado"
fi
echo ""

echo "[CHECK] Verificando pyproject.toml:"
if [ -f "/home/pi/Downloads/repos/digital-memoirs/pyproject.toml" ]; then
    echo "✅ pyproject.toml encontrado"
    ls -la /home/pi/Downloads/repos/digital-memoirs/pyproject.toml
else
    echo "❌ ERROR: pyproject.toml NO encontrado (requerido por uv)"
fi
echo ""

echo "[CHECK] Verificando .venv:"
if [ -d "/home/pi/Downloads/repos/digital-memoirs/.venv" ]; then
    echo "✅ .venv existe"
    ls -la /home/pi/Downloads/repos/digital-memoirs/.venv/bin/python* 2>/dev/null || echo "⚠️ No se encontró Python en .venv"
else
    echo "⚠️ .venv NO existe (uv lo creará automáticamente)"
fi
echo ""

# ============================================================
# 3. Verificación de Permisos
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  VERIFICACIÓN DE PERMISOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "[CHECK] Owner del proyecto:"
ls -ld /home/pi/Downloads/repos/digital-memoirs
echo ""

echo "[CHECK] Carpeta uploads:"
if [ -d "/home/pi/Downloads/repos/digital-memoirs/uploads" ]; then
    ls -la /home/pi/Downloads/repos/digital-memoirs/uploads
else
    echo "⚠️ Carpeta uploads NO existe (se creará automáticamente)"
fi
echo ""

echo "[CHECK] Carpeta static:"
if [ -d "/home/pi/Downloads/repos/digital-memoirs/static" ]; then
    ls -la /home/pi/Downloads/repos/digital-memoirs/static
else
    echo "⚠️ Carpeta static NO existe (se creará automáticamente)"
fi
echo ""

# ============================================================
# 4. Estado del Servicio systemd
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  ESTADO DEL SERVICIO SYSTEMD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "[CHECK] Archivo de servicio:"
if [ -f "/etc/systemd/system/digital-memoirs.service" ]; then
    echo "✅ Archivo de servicio existe"
    ls -la /etc/systemd/system/digital-memoirs.service
    echo ""
    echo "Contenido del archivo de servicio:"
    cat /etc/systemd/system/digital-memoirs.service
else
    echo "❌ ERROR: Archivo de servicio NO encontrado"
fi
echo ""

echo "[CHECK] Estado del servicio:"
sudo systemctl status digital-memoirs --no-pager --full || echo "⚠️ Servicio no encontrado o tiene errores"
echo ""

echo "[CHECK] Servicio habilitado?"
systemctl is-enabled digital-memoirs 2>&1 || echo "⚠️ Servicio NO habilitado"
echo ""

echo "[CHECK] Servicio activo?"
systemctl is-active digital-memoirs 2>&1 || echo "⚠️ Servicio NO activo"
echo ""

# ============================================================
# 5. Logs del Servicio (últimas 100 líneas)
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  LOGS DEL SERVICIO (últimas 100 líneas)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo journalctl -u digital-memoirs -n 100 --no-pager || echo "⚠️ No se pudieron obtener logs"
echo ""

# ============================================================
# 6. Verificación de dnsmasq
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  VERIFICACIÓN DE DNSMASQ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo systemctl status dnsmasq --no-pager || echo "⚠️ dnsmasq no está corriendo"
echo ""

# ============================================================
# 7. Test Manual del Comando ExecStart
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣  TEST MANUAL DEL COMANDO EXACTO DEL SERVICIO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST] Ejecutando como usuario pi:"
echo "Comando: cd /home/pi/Downloads/repos/digital-memoirs && /home/pi/.local/bin/uv run app.py"
echo ""
echo "⚠️ Este test iniciará Flask por 10 segundos y luego lo detendrá..."
echo "Esperando 3 segundos antes de empezar..."
sleep 3

cd /home/pi/Downloads/repos/digital-memoirs

# Ejecutar Flask en background con timeout de 10 segundos
timeout 10s /home/pi/.local/bin/uv run app.py 2>&1 &
FLASK_PID=$!

echo "Flask iniciado con PID: $FLASK_PID"
echo "Esperando 5 segundos para que Flask arranque..."
sleep 5

# Verificar si Flask está corriendo
if ps -p $FLASK_PID > /dev/null 2>&1; then
    echo "✅ Flask está corriendo correctamente"

    # Probar endpoint
    echo ""
    echo "[TEST] Probando endpoint /api/status:"
    curl -s http://localhost:5000/api/status 2>&1 || echo "⚠️ No se pudo conectar a Flask"
    echo ""
else
    echo "❌ Flask NO está corriendo (posible error en el inicio)"
fi

# Esperar a que termine el timeout
wait $FLASK_PID 2>/dev/null
echo ""
echo "Test de Flask completado."
echo ""

# ============================================================
# 8. Verificación de Red
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8️⃣  VERIFICACIÓN DE RED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Interfaces de red:"
ip addr show
echo ""

echo "Verificando wlan0:"
ip addr show wlan0 2>&1 || echo "⚠️ wlan0 no encontrado"
echo ""

# ============================================================
# 9. Verificación de Python y Dependencias
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "9️⃣  VERIFICACIÓN DE PYTHON Y DEPENDENCIAS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Python del sistema:"
which python3
python3 --version
echo ""

echo "Python en .venv (si existe):"
if [ -f "/home/pi/Downloads/repos/digital-memoirs/.venv/bin/python" ]; then
    /home/pi/Downloads/repos/digital-memoirs/.venv/bin/python --version
    echo ""
    echo "Paquetes instalados en .venv:"
    /home/pi/Downloads/repos/digital-memoirs/.venv/bin/pip list
else
    echo "⚠️ No hay Python en .venv todavía"
fi
echo ""

# ============================================================
# 10. Análisis de Errores Comunes
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔟 ANÁLISIS DE ERRORES COMUNES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "[CHECK] Buscando errores 'timeout' en logs:"
sudo journalctl -u digital-memoirs | grep -i "timeout" | tail -n 10
echo ""

echo "[CHECK] Buscando errores 'failed' en logs:"
sudo journalctl -u digital-memoirs | grep -i "failed" | tail -n 10
echo ""

echo "[CHECK] Buscando errores 'permission' en logs:"
sudo journalctl -u digital-memoirs | grep -i "permission" | tail -n 10
echo ""

echo "[CHECK] Buscando errores 'no such file' en logs:"
sudo journalctl -u digital-memoirs | grep -i "no such file" | tail -n 10
echo ""

# ============================================================
# 11. Recomendaciones
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 RECOMENDACIONES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "/home/pi/.local/bin/uv" ]; then
    echo "❌ CRÍTICO: Instala uv con: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

if [ ! -f "/home/pi/Downloads/repos/digital-memoirs/app.py" ]; then
    echo "❌ CRÍTICO: Verifica la ruta del proyecto"
fi

if systemctl is-active digital-memoirs >/dev/null 2>&1; then
    echo "✅ Servicio está corriendo correctamente"
else
    echo "⚠️ Servicio NO está corriendo. Revisa logs arriba."
    echo "   Posibles causas:"
    echo "   1. Timeout de systemd (ExecStartPre demasiado largo)"
    echo "   2. Error en uv o dependencias"
    echo "   3. Permisos incorrectos"
    echo "   4. Ruta incorrecta"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DIAGNÓSTICO COMPLETADO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📄 Guarda este output completo para análisis:"
echo "   ./diagnose_service.sh > diagnosis_report.txt 2>&1"
echo ""
