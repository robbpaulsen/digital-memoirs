# 🔍 Diagnóstico del Servicio - Digital Memoirs

Script de diagnóstico exhaustivo para el servicio systemd de Digital Memoirs.

---

## 📄 Archivo: `diagnose_service.sh`

**Propósito**: Recopila información completa del sistema, servicio systemd, Flask, red y dependencias para diagnosticar problemas.

---

## 🚀 Uso

### Ejecución Básica

```bash
cd /home/pi/Downloads/repos/digital-memoirs/scripts/testing/diagnostics
chmod +x diagnose_service.sh
./diagnose_service.sh
```

### Guardar Reporte en Archivo

```bash
./diagnose_service.sh > diagnosis_report.txt 2>&1
```

**Recomendado**: Siempre guarda el output en un archivo para análisis posterior.

---

## 📊 Información Recopilada

El script verifica y reporta:

### 1️⃣ Información del Sistema
- Hostname, OS, Kernel
- Uptime y carga del sistema

### 2️⃣ Verificación de Rutas y Archivos
- ✅ `uv` instalado en `/home/pi/.local/bin/uv`
- ✅ Proyecto en `/home/pi/Downloads/repos/digital-memoirs`
- ✅ `app.py` existe
- ✅ `pyproject.toml` existe
- ✅ `.venv` configurado

### 3️⃣ Verificación de Permisos
- Owner del proyecto (debe ser `pi:pi`)
- Carpetas `uploads/` y `static/`

### 4️⃣ Estado del Servicio systemd
- Archivo de servicio existe
- Contenido del archivo `.service`
- Estado actual (running/stopped/failed)
- Servicio habilitado para auto-inicio

### 5️⃣ Logs del Servicio
- Últimas 100 líneas de logs de systemd
- `journalctl -u digital-memoirs`

### 6️⃣ Verificación de dnsmasq
- Estado del servicio dnsmasq
- Logs recientes

### 7️⃣ Test Manual de Flask
- Ejecuta Flask por 10 segundos
- Verifica que pueda iniciar
- Prueba endpoint `/api/status`

### 8️⃣ Verificación de Red
- Interfaces de red (eth0, wlan0)
- Configuración de IP
- Estado de wlan0 (Access Point)

### 9️⃣ Python y Dependencias
- Python del sistema
- Python en .venv
- Paquetes instalados

### 🔟 Análisis de Errores Comunes
- Búsqueda de errores "timeout"
- Búsqueda de errores "failed"
- Búsqueda de errores "permission"
- Búsqueda de errores "no such file"

---

## 📝 Ejemplo de Output

```
╔════════════════════════════════════════════════════════════╗
║   🔍 Digital Memoirs - Diagnóstico Completo del Servicio  ║
╚════════════════════════════════════════════════════════════╝

Fecha: Tue Oct 28 05:49:51 PM CST 2025
Usuario ejecutando: pi

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1️⃣  INFORMACIÓN DEL SISTEMA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Hostname: raspberrypi
OS: PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
...
```

---

## 🐛 Cuándo Ejecutar Este Script

### Ejecutar cuando:
- ❌ El servicio systemd no inicia después de un reboot
- ❌ Flask muestra errores en los logs
- ❌ El navegador no se abre automáticamente
- ❌ Los invitados no pueden subir fotos
- ❌ El endpoint `/api/status` no responde

### NO ejecutar cuando:
- ✅ Todo funciona correctamente (no es necesario)

---

## 📤 Compartir Reporte

Si necesitas soporte remoto:

1. Ejecuta el script y guarda el output:
   ```bash
   ./diagnose_service.sh > diagnosis_report.txt 2>&1
   ```

2. Comparte el archivo `diagnosis_report.txt`

3. El reporte NO contiene información sensible (contraseñas, keys, etc.)

---

## 🔧 Solución de Problemas Comunes

### Si el script falla con "Permission denied"

```bash
chmod +x diagnose_service.sh
```

### Si no puede acceder a systemd logs

```bash
# Agregar usuario 'pi' al grupo systemd-journal (si es necesario)
sudo usermod -a -G systemd-journal pi
```

### Si el script se cuelga en el test de Flask

Presiona `Ctrl+C` y continúa. El timeout está configurado en 10 segundos.

---

## 💡 Notas Técnicas

- **Tiempo de ejecución**: ~15-30 segundos
- **Permisos requeridos**: Usuario `pi` (no requiere sudo para la mayoría de checks)
- **Output**: ~350 líneas de texto
- **Formato**: Plain text con Unicode box-drawing characters

---

**Última actualización**: 2025-10-28
