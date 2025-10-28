# 📦 Scripts de Servicio systemd + Autostart - Digital Memoirs

Guía rápida para instalar el servicio systemd Y el autostart del navegador que inicia Digital Memoirs automáticamente al boot del Raspberry Pi.

---

## 🚀 Inicio Rápido (Para Impacientes)

```bash
# 1. Subir estos archivos al Raspberry Pi
cd /home/pi/Downloads/repos/digital-memoirs/scripts

# 2. Dar permisos de ejecución
chmod +x install_service.sh diagnose_service.sh setup_autostart.sh

# 3. Instalar servicio systemd (Flask en background)
./install_service.sh

# 4. Instalar autostart del navegador (abre Chromium automáticamente)
./setup_autostart.sh

# 5. ¡Listo! Flask + Navegador arrancarán automáticamente
```

---

## 📁 Archivos en este Directorio

### ⚙️ Archivos de Servicio

| Archivo | Descripción | Cuándo Usar |
|---------|-------------|-------------|
| `digital-memoirs-FIXED.service` | ✅ **Con delay de 180s** - Timeout aumentado a 240s | Máxima confiabilidad para eventos |
| `digital-memoirs-NO-DELAY.service` | ⚡ **Con delay de 10s** - Arranque rápido | Red rápida y estable |
| `digital-memoirs.service` | ❌ **Versión original** - Tiene el bug del timeout | No usar |

### 🛠️ Scripts de Utilidad

| Script | Descripción | Uso |
|--------|-------------|-----|
| `install_service.sh` | 🎯 **Instalador del servicio systemd** - Flask en background | `./install_service.sh` |
| `setup_autostart.sh` | 🖥️ **Instalador del autostart del navegador** - Abre Chromium automáticamente | `./setup_autostart.sh` |
| `diagnose_service.sh` | 🔍 **Diagnóstico completo** - Captura toda la info | `./diagnose_service.sh > report.txt` |
| `autostart_browser.sh` | 🌐 **Script de autostart** - Espera Flask y abre Chromium | Ejecutado automáticamente |

### 📄 Archivos de Configuración

| Archivo | Descripción |
|---------|-------------|
| `digital-memoirs-autostart.desktop` | Archivo .desktop para autostart de LXDE |

### 📚 Documentación

| Documento | Contenido |
|-----------|-----------|
| `INSTALL_SERVICE.md` | Guía manual de instalación paso a paso |
| `SOLUCION_TIMEOUT.md` | Explicación del problema del timeout y soluciones |
| `AUTOSTART_BROWSER.md` | Explicación del autostart del navegador y solución al keyring |
| `README_SCRIPTS.md` | Este archivo - Guía rápida |

---

## 🎯 ¿Qué Versión del Servicio Debo Usar?

### 🟢 Para el Evento del Sábado:

**Usa**: `digital-memoirs-FIXED.service` (opción 1 en el instalador)

**Razón**:
- ✅ Delay de 180 segundos asegura que wlan0 y dnsmasq estén listos
- ✅ Timeout aumentado evita el problema
- ✅ Máxima confiabilidad (sin sorpresas)

**Desventaja**:
- ⏱️ Arranque lento (3-4 minutos después del boot)

---

### ⚡ Para Desarrollo/Testing:

**Usa**: `digital-memoirs-NO-DELAY.service` (opción 2 en el instalador)

**Razón**:
- ✅ Arranque rápido (~30 segundos)
- ✅ Más cómodo para pruebas repetidas
- ✅ Confía en las dependencias de systemd

**Requisito**:
- ⚠️ Tu red debe configurarse rápido (< 30 segundos)

---

## 🔧 Comandos Esenciales

### Instalación

```bash
# Método 1: Automático (RECOMENDADO)
./install_service.sh

# Método 2: Manual
sudo cp digital-memoirs-FIXED.service /etc/systemd/system/digital-memoirs.service
sudo systemctl daemon-reload
sudo systemctl enable digital-memoirs
sudo systemctl start digital-memoirs
```

### Control del Servicio

```bash
# Ver estado
sudo systemctl status digital-memoirs

# Ver logs en tiempo real
sudo journalctl -u digital-memoirs -f

# Reiniciar
sudo systemctl restart digital-memoirs

# Detener
sudo systemctl stop digital-memoirs

# Deshabilitar auto-inicio
sudo systemctl disable digital-memoirs
```

### Diagnóstico

```bash
# Diagnóstico completo (guarda en archivo)
./diagnose_service.sh > diagnosis_report.txt 2>&1

# Ver últimos logs
sudo journalctl -u digital-memoirs -n 50

# Verificar si está habilitado
systemctl is-enabled digital-memoirs

# Verificar si está corriendo
systemctl is-active digital-memoirs
```

### Testing

```bash
# Probar Flask manualmente
cd /home/pi/Downloads/repos/digital-memoirs
/home/pi/.local/bin/uv run app.py

# Probar endpoint
curl http://localhost:5000/api/status

# Ver desde navegador
# http://10.0.17.1:5000/qr
```

---

## 🐛 Problema del Timeout - Resumen

### ¿Qué pasaba?

El servicio original tenía:
```ini
ExecStartPre=/bin/sleep 180  # Espera 3 minutos
```

Pero systemd tiene timeout de ~90 segundos por defecto.

**Resultado**: Se colgaba y fallaba.

### ¿Cómo se arregló?

**Solución 1 (FIXED.service)**:
```ini
TimeoutStartSec=240  # Aumenta timeout a 240s
ExecStartPre=/bin/sleep 180  # Mantiene delay
```

**Solución 2 (NO-DELAY.service)**:
```ini
TimeoutStartSec=60  # Timeout normal
ExecStartPre=/bin/sleep 10  # Solo 10 segundos
Requires=dnsmasq.service  # Espera a dnsmasq obligatoriamente
```

**Ver detalles completos**: `SOLUCION_TIMEOUT.md`

---

## 🖥️ Autostart del Navegador (NUEVO)

### ¿Por qué necesitas esto?

El servicio systemd inicia Flask en background, **PERO** el navegador NO se abre automáticamente porque:
- El servicio corre sin sesión gráfica (headless)
- `webbrowser.open()` en `app.py` requiere sesión de escritorio

### Solución: Autostart del navegador

```bash
# Instalar autostart del navegador
./setup_autostart.sh
```

**Esto configura**:
1. ✅ Script que espera a Flask y abre Chromium en modo kiosk
2. ✅ Archivo .desktop en `~/.config/autostart/`
3. ✅ Chromium SIN solicitud de password del keyring

### Flujo Completo con Autostart:

```
1. Boot del Raspberry Pi
   ↓
2. systemd inicia digital-memoirs.service (Flask en background)
   ↓
3. Usuario 'pi' hace login en el escritorio
   ↓
4. Autostart ejecuta autostart_browser.sh
   ↓
5. Script espera a que Flask esté disponible
   ↓
6. Chromium abre en modo kiosk mostrando /display
   ↓
7. ✅ TODO LISTO - Slideshow proyectándose
```

**Ver documentación completa**: `AUTOSTART_BROWSER.md`

---

## ✅ Checklist Post-Instalación

### Backend (Servicio systemd):
- [ ] Servicio instalado: `systemctl is-enabled digital-memoirs` → `enabled`
- [ ] Servicio corriendo: `systemctl is-active digital-memoirs` → `active`
- [ ] Flask responde: `curl http://localhost:5000/api/status` → JSON
- [ ] Logs limpios: `sudo journalctl -u digital-memoirs -n 20` → Sin errores
- [ ] WiFi funcional: Teléfono se conecta a "MomentoMarco"

### Frontend (Autostart del navegador):
- [ ] Autostart instalado: `ls ~/.config/autostart/digital-memoirs-autostart.desktop`
- [ ] Script ejecutable: `ls -la scripts/autostart_browser.sh`
- [ ] Chromium flags: `cat ~/.config/chromium-flags.conf` contiene `--password-store=basic`
- [ ] Test manual: `./autostart_browser.sh` abre Chromium

### Testing Final:
- [ ] Reboot completo: `sudo reboot`
- [ ] Login en escritorio (GUI)
- [ ] Chromium abre automáticamente (~3-5 min)
- [ ] Muestra /display en modo kiosk
- [ ] NO pide contraseña del keyring

---

## 📊 Flujo de Arranque

### Con Delay (FIXED.service):

```
1. Boot del Raspberry Pi (0s)
   ↓
2. Network Online + dnsmasq listos (~20s)
   ↓
3. systemd inicia digital-memoirs.service (~25s)
   ↓
4. ExecStartPre: sleep 180 (espera) (~205s)
   ↓
5. ExecStart: uv run app.py (inicia Flask) (~210s)
   ↓
6. Flask corriendo ✅ (~220s total = 3.5 minutos)
```

### Sin Delay (NO-DELAY.service):

```
1. Boot del Raspberry Pi (0s)
   ↓
2. Network Online + dnsmasq listos (~20s)
   ↓
3. systemd inicia digital-memoirs.service (~25s)
   ↓
4. ExecStartPre: sleep 10 (espera corta) (~35s)
   ↓
5. ExecStart: uv run app.py (inicia Flask) (~40s)
   ↓
6. Flask corriendo ✅ (~50s total)
```

---

## 🆘 Troubleshooting Rápido

### Servicio no inicia

```bash
# 1. Ver logs con detalles
sudo journalctl -u digital-memoirs -n 100 --no-pager

# 2. Ejecutar diagnóstico
./diagnose_service.sh > report.txt

# 3. Probar Flask manualmente
cd /home/pi/Downloads/repos/digital-memoirs
/home/pi/.local/bin/uv run app.py
```

### Servicio se reinicia constantemente

```bash
# Ver historial de reinicios
sudo systemctl status digital-memoirs

# Si dice "Start request repeated too quickly":
# Edita el servicio y aumenta StartLimitIntervalSec
sudo nano /etc/systemd/system/digital-memoirs.service
```

### uv no encontrado

```bash
# Verificar que existe
ls -la /home/pi/.local/bin/uv

# Instalar si no existe
curl -LsSf https://astral.sh/uv/install.sh | sh

# Recargar PATH
source ~/.bashrc
```

---

## 📞 Soporte

Si tienes problemas:

1. **Ejecuta el diagnóstico**:
   ```bash
   ./diagnose_service.sh > diagnosis_report.txt 2>&1
   ```

2. **Comparte el archivo** `diagnosis_report.txt`

3. **Comparte los logs**:
   ```bash
   sudo journalctl -u digital-memoirs -n 100 --no-pager > logs.txt
   ```

---

## 🎉 ¡Listo!

Con estos scripts tienes todo lo necesario para:

- ✅ Instalar el servicio systemd (Flask en background)
- ✅ Instalar autostart del navegador (Chromium en modo kiosk)
- ✅ Diagnosticar problemas completamente
- ✅ Elegir entre máxima confiabilidad o velocidad
- ✅ Solucionar el problema del keyring de Chromium
- ✅ Tener el sistema 100% automático para el evento

**Día del evento**:
1. 🔌 Enchufa el Raspberry Pi
2. 🖥️ Haz login en el escritorio
3. ⏳ Espera 3-5 minutos
4. ✅ **TODO funciona automáticamente**:
   - Flask corriendo en background
   - Chromium abierto en pantalla completa
   - Slideshow mostrándose en /display
   - Sin pedir contraseñas
   - Listo para proyectar 🚀
