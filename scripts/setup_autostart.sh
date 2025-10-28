#!/bin/bash
# ============================================================
# Digital Memoirs - Configurar Autostart del Navegador
# ============================================================
# Este script configura el autostart del navegador para que
# se abra automáticamente en /display cuando el usuario 'pi'
# inicia sesión en el escritorio
# ============================================================

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   🖥️  Digital Memoirs - Setup Autostart del Navegador     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "autostart_browser.sh" ]; then
    echo "❌ ERROR: Este script debe ejecutarse desde el directorio scripts/"
    echo "   Ubicación actual: $(pwd)"
    exit 1
fi

# Verificar usuario
CURRENT_USER=$(whoami)
if [ "$CURRENT_USER" != "pi" ]; then
    echo "⚠️ ADVERTENCIA: Este script está diseñado para el usuario 'pi'"
    echo "   Usuario actual: $CURRENT_USER"
    read -p "¿Continuar de todas formas? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 ¿Qué hará este script?"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. ✅ Configurar autostart del navegador en el escritorio"
echo "2. ✅ Copiar autostart_browser.sh a la ubicación correcta"
echo "3. ✅ Dar permisos de ejecución"
echo "4. ✅ Crear archivo .desktop en ~/.config/autostart/"
echo "5. ✅ Configurar Chromium sin solicitud de password del keyring"
echo ""
echo "Después de esto, cuando inicies sesión en el escritorio:"
echo "  - El navegador se abrirá automáticamente en modo kiosk"
echo "  - Mostrará la página /display (slideshow)"
echo "  - NO pedirá contraseña del keyring"
echo ""

read -p "¿Continuar? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "❌ Cancelado por el usuario"
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Instalando autostart..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Crear directorio autostart si no existe
mkdir -p ~/.config/autostart
echo "✅ Directorio ~/.config/autostart verificado"

# Copiar y dar permisos al script
SCRIPT_PATH="/home/$CURRENT_USER/Downloads/repos/digital-memoirs/scripts/autostart_browser.sh"
chmod +x autostart_browser.sh
echo "✅ Permisos de ejecución establecidos en autostart_browser.sh"

# Copiar archivo .desktop
cp digital-memoirs-autostart.desktop ~/.config/autostart/
echo "✅ Archivo .desktop copiado a ~/.config/autostart/"

# Verificar instalación
if [ -f ~/.config/autostart/digital-memoirs-autostart.desktop ]; then
    echo "✅ Autostart configurado correctamente"
else
    echo "❌ ERROR: No se pudo copiar el archivo .desktop"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Configurando Chromium (evitar solicitud de password)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Crear directorio de configuración de Chromium si no existe
mkdir -p ~/.config/chromium

# Crear archivo de flags de Chromium
CHROMIUM_FLAGS_FILE=~/.config/chromium-flags.conf

cat > "$CHROMIUM_FLAGS_FILE" << 'EOF'
# Digital Memoirs - Chromium Flags
# Evita solicitar contraseña del keyring y optimiza para modo kiosk

--password-store=basic
--no-first-run
--noerrdialogs
--disable-infobars
--check-for-update-interval=31536000
--disable-session-crashed-bubble
--disable-restore-session-state
EOF

echo "✅ Archivo de flags creado: $CHROMIUM_FLAGS_FILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CONFIGURACIÓN COMPLETADA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎯 ¿Qué hacer ahora?"
echo ""
echo "1. 🔄 Cierra sesión y vuelve a iniciar sesión en el escritorio"
echo "   - El navegador se abrirá automáticamente"
echo "   - Mostrará /display en modo kiosk (pantalla completa)"
echo "   - NO pedirá contraseña del keyring"
echo ""
echo "2. 🧪 O prueba manualmente ahora mismo:"
echo "   ./autostart_browser.sh"
echo ""
echo "3. 📊 Ver logs del autostart:"
echo "   tail -f ~/.digital-memoirs-autostart.log"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 ARCHIVOS CREADOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "~/.config/autostart/digital-memoirs-autostart.desktop"
echo "~/.config/chromium-flags.conf"
echo "~/.digital-memoirs-autostart.log (se creará al ejecutar)"
echo ""

# Preguntar si quiere probar ahora
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "¿Quieres probar el autostart AHORA? (y/N): " -n 1 -r
echo
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Ejecutando autostart_browser.sh..."
    echo "   Chromium debería abrirse en unos segundos..."
    echo "   Ver logs en: tail -f ~/.digital-memoirs-autostart.log"
    echo ""
    ./autostart_browser.sh &
    echo ""
    echo "✅ Script ejecutado en background"
    echo "   Si Chromium no se abre, revisa los logs"
else
    echo "✅ Setup completado"
    echo "   El navegador se abrirá automáticamente en el próximo login"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 NOTAS IMPORTANTES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "• El navegador SOLO se abre cuando haces login en el escritorio"
echo "• Si accedes al Pi solo por SSH, el navegador NO se abrirá"
echo "• Para deshabilitar el autostart: rm ~/.config/autostart/digital-memoirs-autostart.desktop"
echo "• Para salir del modo kiosk: Presiona Alt+F4 o Ctrl+W"
echo ""
