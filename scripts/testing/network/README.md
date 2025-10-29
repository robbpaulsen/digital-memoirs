# 🌐 Diagnóstico de Red - Digital Memoirs

Script de diagnóstico de red para verificar configuración del Access Point, interfaces y conectividad.

---

## 📄 Archivo: `network_diagnostic.py`

**Propósito**: Verificar configuración de red, interfaces WiFi, dnsmasq y conectividad para eventos.

---

## 🚀 Uso

### Ejecución Básica

```bash
cd /home/pi/Downloads/repos/digital-memoirs/scripts/testing/network
python3 network_diagnostic.py
```

### Guardar Reporte

```bash
python3 network_diagnostic.py > network_report.txt 2>&1
```

---

## 📊 Información Verificada

### Interfaces de Red
- ✅ eth0 (Ethernet)
- ✅ wlan0 (WiFi Access Point)
- ✅ lo (Loopback)

### Configuración del Access Point
- IP de wlan0: `10.0.17.1/24`
- Estado: UP/DOWN
- SSID configurado
- Canal WiFi

### Servicios de Red
- ✅ dnsmasq (DHCP y DNS)
- ✅ hostapd (Access Point)

### Conectividad
- Ping a localhost
- Ping a gateway
- Resolución DNS

---

## 🎯 Escenarios de Uso

### Antes del Evento

Verifica que todo esté configurado correctamente:
```bash
python3 network_diagnostic.py
```

**Espera ver**:
- ✅ wlan0: `10.0.17.1` UP
- ✅ dnsmasq: active (running)
- ✅ hostapd: active (running)

### Durante el Evento

Si los invitados no pueden conectarse:
```bash
python3 network_diagnostic.py > issue_report.txt
```

Revisa el reporte para identificar el problema.

### Después de Cambios de Configuración

Verifica que los cambios se aplicaron correctamente:
```bash
python3 network_diagnostic.py
```

---

## 🔧 Problemas Comunes y Soluciones

### wlan0 no tiene IP asignada

**Síntoma**: `wlan0: no IP address`

**Solución**:
```bash
sudo ifconfig wlan0 10.0.17.1 netmask 255.255.255.0
sudo systemctl restart hostapd
```

---

### dnsmasq no está corriendo

**Síntoma**: `dnsmasq: inactive (dead)`

**Solución**:
```bash
sudo systemctl start dnsmasq
sudo systemctl enable dnsmasq
```

---

### hostapd no está corriendo

**Síntoma**: `hostapd: inactive (dead)`

**Solución**:
```bash
sudo systemctl start hostapd
sudo systemctl enable hostapd
```

---

### Invitados no reciben IP (DHCP no funciona)

**Verificar**:
```bash
sudo systemctl status dnsmasq
cat /var/lib/misc/dnsmasq.leases  # Ver IPs asignadas
```

**Solución**:
```bash
sudo systemctl restart dnsmasq
```

---

## 📝 Ejemplo de Output

```
═══════════════════════════════════════════
  Digital Memoirs - Network Diagnostic
═══════════════════════════════════════════

[CHECK] Network Interfaces
✅ eth0: 192.168.6.130/22 (UP)
✅ wlan0: 10.0.17.1/24 (UP)
✅ lo: 127.0.0.1/8 (UP)

[CHECK] Access Point Configuration
✅ wlan0 IP: 10.0.17.1
✅ wlan0 State: UP
✅ SSID: MomentoMarco

[CHECK] Network Services
✅ dnsmasq: active (running)
✅ hostapd: active (running)

[CHECK] Connectivity
✅ Ping localhost: OK
✅ Ping gateway: OK
✅ DNS resolution: OK
```

---

## 💡 Notas

- **Tiempo de ejecución**: ~5-10 segundos
- **Permisos**: Usuario `pi` (algunos checks pueden requerir sudo)
- **Dependencias**: Python 3.x standard library

---

## 🆘 Troubleshooting del Script

### Error: "ModuleNotFoundError"

El script usa solo módulos estándar de Python. Si falla, verifica la instalación de Python:
```bash
python3 --version  # Debe ser Python 3.11+
```

### Error: "Permission denied" al verificar servicios

Algunos checks requieren permisos elevados. Ejecuta con sudo si es necesario:
```bash
sudo python3 network_diagnostic.py
```

---

**Última actualización**: 2025-10-28
