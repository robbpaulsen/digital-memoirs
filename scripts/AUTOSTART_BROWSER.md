# 🖥️ Autostart del Navegador - Digital Memoirs

## 📋 Problema a Resolver

Cuando el servicio systemd inicia Flask correctamente, el navegador **NO se abre automáticamente** porque:

1. El servicio corre **sin sesión gráfica activa** (headless)
2. El código `webbrowser.open()` en `app.py` requiere una sesión de escritorio
3. Chromium pide **contraseña del keyring** cada vez que inicia

---

## ✅ Solución Implementada

### Sistema de Autostart con 3 Componentes:

```
┌──────────────────────────────────────────────────────────┐
│  1. Servicio systemd (backend)                           │
│     └── Inicia Flask automáticamente al boot             │
│         └── Flask corre en background (headless)         │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  2. Login del usuario 'pi' en el escritorio              │
│     └── Dispara el autostart                             │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  3. autostart_browser.sh                                 │
│     └── Espera a que Flask esté disponible               │
│         └── Abre Chromium en modo kiosk                  │
│             └── Muestra /display (slideshow)             │
└──────────────────────────────────────────────────────────┘
```

---

## 📦 Archivos Incluidos

| Archivo | Propósito |
|---------|-----------|
| `autostart_browser.sh` | Script que espera a Flask y abre Chromium |
| `digital-memoirs-autostart.desktop` | Archivo .desktop para autostart de LXDE |
| `setup_autostart.sh` | Instalador automático del autostart |
| `AUTOSTART_BROWSER.md` | Este documento - Explicación completa |

---

## 🚀 Instalación Rápida

```bash
cd /home/pi/Downloads/repos/digital-memoirs/scripts
chmod +x setup_autostart.sh
./setup_autostart.sh
```

El script:
1. ✅ Copia archivos necesarios
2. ✅ Configura autostart en `~/.config/autostart/`
3. ✅ Configura Chromium para NO pedir password del keyring
4. ✅ Te ofrece probar inmediatamente

---

## 🔧 ¿Cómo Funciona?

### Paso 1: Boot del Raspberry Pi

```
Boot → systemd inicia → digital-memoirs.service → Flask corriendo
```

**Resultado**: Flask está disponible en `http://localhost:5000` pero **no hay navegador abierto todavía**.

### Paso 2: Usuario hace login en el escritorio

```
Login (usuario 'pi') → LXDE/LXSession carga → Lee ~/.config/autostart/
```

**Resultado**: Ejecuta automáticamente `autostart_browser.sh`.

### Paso 3: autostart_browser.sh se ejecuta

```bash
# 1. Verifica si Flask está disponible
while true; do
    curl http://localhost:5000/display
    if success; then break; fi
    sleep 5
done

# 2. Abre Chromium en modo kiosk
chromium-browser \
    --kiosk \
    --password-store=basic \
    --noerrdialogs \
    http://localhost:5000/display
```

**Resultado**: Chromium abre en pantalla completa mostrando el slideshow.

---

## 🔐 Solución al Problema del Keyring

### ¿Por qué Chromium pedía contraseña?

Chromium intenta usar el **keyring del sistema** (gnome-keyring) para almacenar contraseñas de forma segura. Si el keyring no está desbloqueado, pide contraseña cada vez.

### Solución Implementada:

**Flag de Chromium**: `--password-store=basic`

Esto le dice a Chromium:
- ❌ NO uses el keyring del sistema
- ✅ Usa almacenamiento básico en archivos
- ✅ NO pidas contraseña

**Archivo creado**: `~/.config/chromium-flags.conf`

```
--password-store=basic
--no-first-run
--noerrdialogs
--disable-infobars
```

---

## 🎯 Flujo Completo del Día del Evento

### Antes del Evento (Setup):

```bash
# 1. Instalar servicio systemd
./install_service.sh  # (Ya hecho)

# 2. Instalar autostart del navegador
./setup_autostart.sh
```

### Día del Evento:

```
1. Enchufa el Raspberry Pi
   ↓
2. Espera 3-4 minutos (servicio systemd iniciando)
   ↓
3. Usuario 'pi' hace login en el escritorio
   ↓
4. ✅ AUTOMÁTICAMENTE:
   - Chromium se abre en pantalla completa
   - Muestra el slideshow (/display)
   - NO pide contraseña
   ↓
5. ✅ Conecta el HDMI a la TV/proyector
   ↓
6. ✅ Listo para el evento
```

**NO necesitas**:
- ❌ Abrir terminal
- ❌ Ejecutar comandos
- ❌ Abrir navegador manualmente
- ❌ Introducir contraseñas

---

## 📊 Verificación y Testing

### Test 1: Probar autostart manualmente

```bash
cd /home/pi/Downloads/repos/digital-memoirs/scripts
./autostart_browser.sh
```

**Resultado esperado**: Chromium abre en modo kiosk mostrando /display.

### Test 2: Ver logs del autostart

```bash
tail -f ~/.digital-memoirs-autostart.log
```

**Logs esperados**:
```
2025-10-28 10:05:00 - Autostart del navegador iniciado
2025-10-28 10:05:05 - Esperando a que Flask esté disponible...
2025-10-28 10:05:10 - ✅ Flask está disponible después de 10s
2025-10-28 10:05:13 - 🚀 Abriendo Chromium en modo kiosk...
2025-10-28 10:05:15 - ✅ Chromium iniciado con PID: 12345
```

### Test 3: Verificar que el servicio systemd está corriendo

```bash
sudo systemctl status digital-memoirs
```

**Estado esperado**: `Active: active (running)`

### Test 4: Test completo con reboot

```bash
# 1. Reinicia el Pi
sudo reboot

# 2. Haz login en el escritorio (GUI)

# 3. Espera 3-5 minutos

# Resultado esperado:
# ✅ Chromium se abre automáticamente
# ✅ Muestra /display en pantalla completa
# ✅ NO pide contraseña
```

---

## 🐛 Troubleshooting

### Problema: El navegador no se abre después de login

**Diagnóstico**:
```bash
# 1. Verificar que el archivo .desktop existe
ls -la ~/.config/autostart/digital-memoirs-autostart.desktop

# 2. Ver logs del autostart
tail -n 50 ~/.digital-memoirs-autostart.log

# 3. Verificar que Flask está corriendo
curl http://localhost:5000/api/status
```

**Soluciones**:
- Si el archivo .desktop no existe: `./setup_autostart.sh`
- Si Flask no responde: `sudo systemctl restart digital-memoirs`
- Si hay timeout en logs: Aumentar `MAX_WAIT` en `autostart_browser.sh`

---

### Problema: Chromium sigue pidiendo contraseña

**Diagnóstico**:
```bash
# Verificar que el archivo de flags existe
cat ~/.config/chromium-flags.conf
```

**Soluciones**:

**Opción 1**: Reejecutar setup
```bash
./setup_autostart.sh
```

**Opción 2**: Editar manualmente
```bash
nano ~/.config/chromium-flags.conf
# Agregar: --password-store=basic
```

**Opción 3**: Desactivar keyring del sistema completamente
```bash
# Renombrar el ejecutable de gnome-keyring
sudo mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon.bak
```

---

### Problema: Chromium se abre pero no en modo kiosk

**Causa**: Flags de Chromium no se están aplicando.

**Solución**:
```bash
# Editar autostart_browser.sh y verificar los flags
nano /home/pi/Downloads/repos/digital-memoirs/scripts/autostart_browser.sh

# Verificar que incluye:
# --kiosk
# --noerrdialogs
# --disable-infobars
```

---

### Problema: Autostart se ejecuta muy lento

**Causa**: Flask tarda mucho en estar disponible.

**Solución 1**: Aumentar el delay del servicio systemd
```bash
# Editar el servicio y reducir ExecStartPre
sudo nano /etc/systemd/system/digital-memoirs.service
# Cambiar: ExecStartPre=/bin/sleep 180
# A:       ExecStartPre=/bin/sleep 60
```

**Solución 2**: Usar la versión NO-DELAY del servicio
```bash
./install_service.sh
# Seleccionar opción 2 (sin delay)
```

---

## 🔄 Desinstalación del Autostart

Si necesitas deshabilitar el autostart del navegador:

```bash
# Remover archivo .desktop
rm ~/.config/autostart/digital-memoirs-autostart.desktop

# Remover archivo de flags de Chromium
rm ~/.config/chromium-flags.conf

# Remover logs
rm ~/.digital-memoirs-autostart.log
```

**Nota**: Esto NO afecta el servicio systemd de Flask (seguirá corriendo).

---

## 💡 Notas Importantes

1. **El autostart SOLO funciona cuando haces login en el escritorio (GUI)**
   - Si accedes solo por SSH, el navegador NO se abrirá
   - Necesitas conectar pantalla, teclado y hacer login gráfico

2. **Chromium en modo kiosk es pantalla completa**
   - Para salir: `Alt+F4` o `Ctrl+W`
   - Para recargar: `F5` o `Ctrl+R`

3. **El script espera hasta 5 minutos a que Flask esté disponible**
   - Si Flask tarda más, aumenta `MAX_WAIT` en `autostart_browser.sh`

4. **Logs útiles**:
   - Autostart: `~/.digital-memoirs-autostart.log`
   - Flask: `sudo journalctl -u digital-memoirs -f`
   - Chromium: `/tmp/chromium-debug.log` (si existe)

---

## 📝 Resumen de Comandos

```bash
# Instalación
./setup_autostart.sh

# Testing manual
./autostart_browser.sh

# Ver logs
tail -f ~/.digital-memoirs-autostart.log

# Verificar Flask
curl http://localhost:5000/api/status

# Verificar servicio
sudo systemctl status digital-memoirs

# Desinstalar
rm ~/.config/autostart/digital-memoirs-autostart.desktop
```

---

## ✅ Checklist Post-Instalación

- [ ] Servicio systemd instalado y corriendo
- [ ] Autostart configurado en `~/.config/autostart/`
- [ ] Chromium flags configurado en `~/.config/chromium-flags.conf`
- [ ] Test manual: `./autostart_browser.sh` abre Chromium
- [ ] Test de reboot completo: Todo funciona después de reiniciar
- [ ] Chromium NO pide contraseña del keyring
- [ ] Chromium abre en modo kiosk (pantalla completa)

---

## 🎉 Resultado Final

Después de completar la instalación:

**Día del evento**:
1. 🔌 Enchufa el Raspberry Pi
2. 🖥️ Haz login en el escritorio
3. ⏳ Espera ~3 minutos
4. ✅ **TODO funciona automáticamente**:
   - Flask corriendo
   - Chromium abierto en pantalla completa
   - Slideshow mostrándose
   - Sin solicitar contraseñas
   - Listo para proyectar

**¡No se requiere intervención manual!** 🚀
