# Instalación del Servicio systemd - Digital Memoirs

Este documento explica cómo instalar y configurar el servicio systemd para que Digital Memoirs arranque automáticamente 3 minutos después de encender el Raspberry Pi.

---

## 📋 Pre-requisitos

- Raspberry Pi OS Bookworm (Debian 12)
- Usuario: `pi`
- Proyecto en: `/home/pi/Downloads/repos/digital-memoirs`
- `uv` instalado en: `/home/pi/.local/bin/uv`
- dnsmasq configurado y funcionando

---

## 🚀 Instalación

### 1. Copiar el archivo de servicio

Desde tu computadora local, copia el archivo al Raspberry Pi:

```bash
# Opción A: Si tienes acceso SSH desde tu PC
scp scripts/digital-memoirs.service pi@raspberrypi.local:/tmp/

# Opción B: Si estás directamente en el Pi
# Copia el archivo desde el repositorio
cd /home/pi/Downloads/repos/digital-memoirs
```

### 2. Instalar el servicio

Ejecuta estos comandos en el Raspberry Pi:

```bash
# Copiar el archivo de servicio al directorio systemd
sudo cp /tmp/digital-memoirs.service /etc/systemd/system/
# O si estás en el repo:
sudo cp scripts/digital-memoirs.service /etc/systemd/system/

# Establecer permisos correctos
sudo chmod 644 /etc/systemd/system/digital-memoirs.service

# Recargar systemd para reconocer el nuevo servicio
sudo systemctl daemon-reload

# Habilitar el servicio para que arranque al boot
sudo systemctl enable digital-memoirs

# Verificar que está habilitado
systemctl is-enabled digital-memoirs
# Debería mostrar: enabled
```

---

## ✅ Testing

### Opción 1: Iniciar el servicio inmediatamente (sin reiniciar)

```bash
# Iniciar el servicio ahora
sudo systemctl start digital-memoirs

# Esperar 3 minutos (por el delay configurado)
# Luego verificar el status
sudo systemctl status digital-memoirs

# Debería mostrar:
# Active: active (running)
```

### Opción 2: Reiniciar el Pi (testing completo)

```bash
# Reiniciar
sudo reboot

# Después de reiniciar, espera 3-4 minutos y luego verifica:
sudo systemctl status digital-memoirs
```

---

## 📊 Verificación

### Ver el estado del servicio

```bash
sudo systemctl status digital-memoirs
```

**Output esperado:**
```
● digital-memoirs.service - Digital Memoirs - Event Photo Sharing Application
     Loaded: loaded (/etc/systemd/system/digital-memoirs.service; enabled; preset: enabled)
     Active: active (running) since Sat 2025-10-26 10:03:00 GMT; 5min ago
   Main PID: 1234 (python3)
      Tasks: 5 (limit: 4164)
     Memory: 45.2M
        CPU: 2.156s
     CGroup: /system.slice/digital-memoirs.service
             └─1234 /usr/bin/python3 app.py
```

### Ver logs en tiempo real

```bash
# Logs en vivo
sudo journalctl -u digital-memoirs -f

# Últimas 50 líneas
sudo journalctl -u digital-memoirs -n 50

# Logs desde el último boot
sudo journalctl -u digital-memoirs -b
```

**Output esperado en logs:**
```
Oct 26 10:03:00 raspberrypi systemd[1]: Starting Digital Memoirs - Event Photo Sharing Application...
Oct 26 10:03:00 raspberrypi digital-memoirs[1234]: INFO:__main__:🚀 Starting Digital Memoirs app...
Oct 26 10:03:00 raspberrypi digital-memoirs[1234]: INFO:__main__:🧹 Cleaned up QR code files
Oct 26 10:03:01 raspberrypi digital-memoirs[1234]: INFO:__main__:📱 WiFi QR generated: SSID=MomentoMarco
Oct 26 10:03:01 raspberrypi digital-memoirs[1234]: * Running on all addresses (0.0.0.0)
Oct 26 10:03:01 raspberrypi digital-memoirs[1234]: * Running on http://127.0.0.1:5000
```

### Verificar que Flask está respondiendo

```bash
# Desde el Pi
curl http://localhost:5000/api/status

# Debería responder:
# {"status":"healthy","image_count":0,"timestamp":"...","upload_limit":800}

# Desde tu teléfono conectado al WiFi
# Abrir navegador: http://10.0.17.1/qr
```

---

## 🔧 Comandos Útiles

### Controlar el servicio

```bash
# Iniciar
sudo systemctl start digital-memoirs

# Detener
sudo systemctl stop digital-memoirs

# Reiniciar
sudo systemctl restart digital-memoirs

# Ver status
sudo systemctl status digital-memoirs

# Habilitar (auto-inicio)
sudo systemctl enable digital-memoirs

# Deshabilitar (no auto-inicio)
sudo systemctl disable digital-memoirs
```

### Editar configuración del servicio

```bash
# Editar el archivo
sudo nano /etc/systemd/system/digital-memoirs.service

# Después de editar, SIEMPRE recargar:
sudo systemctl daemon-reload

# Y reiniciar el servicio:
sudo systemctl restart digital-memoirs
```

---

## 🐛 Troubleshooting

### El servicio no inicia

```bash
# Ver errores detallados
sudo journalctl -u digital-memoirs -n 100 --no-pager

# Verificar que dnsmasq está corriendo
sudo systemctl status dnsmasq

# Verificar que uv existe en la ruta
ls -la /home/pi/.local/bin/uv

# Verificar que el proyecto existe
ls -la /home/pi/Downloads/repos/digital-memoirs/app.py
```

### El servicio se reinicia constantemente

```bash
# Ver historial de reinicios
sudo systemctl status digital-memoirs

# Si dice "Start request repeated too quickly"
# Aumentar StartLimitIntervalSec en el archivo de servicio
sudo nano /etc/systemd/system/digital-memoirs.service
# Cambiar: StartLimitIntervalSec=300 a 600
```

### Flask no genera QR codes

```bash
# Verificar permisos de la carpeta static
ls -la /home/pi/Downloads/repos/digital-memoirs/static/

# Crear carpeta si no existe
mkdir -p /home/pi/Downloads/repos/digital-memoirs/static
chown pi:pi /home/pi/Downloads/repos/digital-memoirs/static
```

### Logs no aparecen en journalctl

```bash
# Verificar que rsyslog está corriendo
sudo systemctl status rsyslog

# Reiniciar journald
sudo systemctl restart systemd-journald
```

---

## 🔄 Desinstalación

Si necesitas remover el servicio:

```bash
# Detener y deshabilitar
sudo systemctl stop digital-memoirs
sudo systemctl disable digital-memoirs

# Remover el archivo
sudo rm /etc/systemd/system/digital-memoirs.service

# Recargar systemd
sudo systemctl daemon-reload

# Resetear estado fallido (si aplica)
sudo systemctl reset-failed
```

---

## 📝 Notas Importantes

1. **Delay de 3 minutos:** El servicio espera 180 segundos después del boot antes de iniciar Flask. Esto asegura que wlan0 y dnsmasq estén completamente listos.

2. **Auto-restart:** Si Flask crashea, systemd lo reinicia automáticamente después de 10 segundos.

3. **Logs centralizados:** Todos los logs van a journalctl, igual que dnsmasq.

4. **Usuario pi:** El servicio corre con el usuario `pi`, no como root, por seguridad.

5. **PATH configurado:** El servicio incluye `/home/pi/.local/bin` en el PATH para encontrar `uv`.

---

## ✅ Checklist Post-Instalación

- [ ] Servicio instalado: `systemctl is-enabled digital-memoirs` muestra "enabled"
- [ ] Servicio corriendo: `systemctl is-active digital-memoirs` muestra "active"
- [ ] Flask responde: `curl http://localhost:5000/api/status` retorna JSON
- [ ] QR generados: `ls -la static/qr_*.png` muestra archivos
- [ ] Logs visibles: `journalctl -u digital-memoirs -n 20` muestra output
- [ ] WiFi funcional: Teléfono puede conectarse a "MomentoMarco"
- [ ] Testing de reinicio: Después de `sudo reboot`, todo arranca automáticamente

---

## 🎯 Día del Evento

El día del evento, solo necesitas:

1. **Enchufar el Raspberry Pi**
2. **Esperar 3-4 minutos**
3. **Verificar con tu teléfono** que el WiFi "MomentoMarco" está disponible
4. ✅ **¡Listo!** - Todo debería estar corriendo automáticamente

No necesitas SSH, laptop, ni nada más. El Pi hace todo solo.
