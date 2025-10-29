# ⚙️ Service Files Reference - Digital Memoirs

Archivos de configuración de systemd archivados (versiones con bugs o reemplazadas).

---

## 📁 Contenido

- `digital-memoirs.service` - Versión original con timeout bug

---

## 📖 digital-memoirs.service (Original)

**Estado**: Versión con bug - Reemplazada por versión FIXED

### El Problema

```ini
ExecStartPre=/bin/sleep 180  # Espera 3 minutos
```

**Sin**:
```ini
TimeoutStartSec=240  # ❌ FALTA ESTA LÍNEA
```

**Resultado**: systemd tiene timeout por defecto de ~90 segundos, pero el servicio espera 180 segundos → **timeout → falla**.

---

### Síntomas del Bug

```bash
$ sudo systemctl start digital-memoirs
# Se cuelga por 90 segundos...
# Error: "Start operation timed out"
# Estado: failed
```

**Logs**:
```
Oct 28 17:45:00 raspberrypi systemd[1]: Starting digital-memoirs.service...
Oct 28 17:46:30 raspberrypi systemd[1]: digital-memoirs.service: Start operation timed out. Terminating.
Oct 28 17:46:30 raspberrypi systemd[1]: digital-memoirs.service: Failed with result 'timeout'.
```

---

### La Solución

**Versión corregida**: `digital-memoirs-FIXED.service` (en directorio padre)

```ini
[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/Downloads/repos/digital-memoirs

# ✅ SOLUCIÓN: Aumentar timeout de systemd
TimeoutStartSec=240  # 180s sleep + 60s margen
TimeoutStopSec=30

ExecStartPre=/bin/sleep 180
ExecStart=/home/pi/.local/bin/uv run app.py
```

---

## 🔍 Diferencias: Original vs FIXED

| Configuración | Original | FIXED |
|---------------|----------|-------|
| TimeoutStartSec | Default (~90s) | 240s ✅ |
| TimeoutStopSec | Default (~90s) | 30s ✅ |
| Resultado | ❌ Timeout error | ✅ Funciona correctamente |

---

## 💡 Por Qué se Conserva

### Razones:

1. **Documentación del bug**: Referencia de qué estaba mal
2. **Troubleshooting**: Si alguien tiene un problema similar
3. **Historial**: Entender la evolución de la configuración
4. **Aprendizaje**: Ejemplo de problemas comunes de systemd

### NO se debe usar:

- ❌ NO copiar este archivo a `/etc/systemd/system/`
- ❌ NO reemplazar la versión actual con esta
- ❌ NO intentar "arreglarlo" - usa la versión FIXED

---

## 📚 Lecciones Aprendidas

### De este bug aprendimos:

1. **systemd tiene timeouts por defecto**: No son infinitos
2. **ExecStartPre cuenta para el timeout**: El sleep de 180s cuenta
3. **Siempre configurar TimeoutStartSec**: Especialmente con delays largos
4. **Testing es crucial**: Este bug solo se descubrió en testing real

### Mejores prácticas de systemd:

```ini
# ✅ SIEMPRE especifica timeouts explícitos
TimeoutStartSec=<tiempo_necesario + margen>
TimeoutStopSec=<tiempo_razonable>

# ✅ Si usas delays largos, aumenta el timeout
ExecStartPre=/bin/sleep 180  # Necesita TimeoutStartSec >= 240

# ✅ Usa After/Wants para dependencias en lugar de sleeps
After=network-online.target dnsmasq.service
Wants=network-online.target
```

---

## 🔧 Cómo Diagnosticar Timeouts en systemd

### 1. Ver estado del servicio

```bash
sudo systemctl status digital-memoirs
```

Busca: `"Start operation timed out"` o `"Failed with result 'timeout'"`

### 2. Ver logs completos

```bash
sudo journalctl -u digital-memoirs -n 100
```

Busca líneas con:
- `Starting...` (hora de inicio)
- `Started` o `Failed` (hora de finalización)
- Calcula la diferencia → Si es ~90s, es timeout

### 3. Verificar configuración de timeout

```bash
systemctl show digital-memoirs | grep Timeout
```

Debe mostrar:
```
TimeoutStartUSec=4min       # 240 segundos
TimeoutStopUSec=30s
```

Si muestra valores por defecto (1min 30s), hay un problema.

---

## 🆘 Si Encuentras Este Bug en Otro Servicio

### Pasos para solucionarlo:

1. **Identifica el problema**:
   ```bash
   sudo journalctl -u <servicio> | grep timeout
   ```

2. **Edita el archivo .service**:
   ```bash
   sudo nano /etc/systemd/system/<servicio>.service
   ```

3. **Agrega timeout apropiado**:
   ```ini
   [Service]
   TimeoutStartSec=<tiempo_necesario>
   TimeoutStopSec=30
   ```

4. **Recarga y reinicia**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart <servicio>
   ```

5. **Verifica**:
   ```bash
   sudo systemctl status <servicio>
   ```

---

## 📊 Timeline del Bug

| Fecha | Evento |
|-------|--------|
| 25/10/2025 | Servicio original creado con delay de 180s |
| 28/10/2025 | Bug descubierto: timeout en testing |
| 28/10/2025 | Solución implementada: TimeoutStartSec=240 |
| 28/10/2025 | Testing exitoso con versión FIXED |
| 28/10/2025 | Versión original archivada en reference/ |

---

## 🔗 Ver También

- **Versión corregida**: `../digital-memoirs-FIXED.service`
- **Versión sin delay**: `../digital-memoirs-NO-DELAY.service`
- **Documentación del fix**: `../SOLUCION_TIMEOUT.md`
- **Script de instalación**: `../install_service.sh`

---

**Última actualización**: 2025-10-28
**Bug resuelto**: Sí (en versión FIXED)
**Versión actual del proyecto**: 0.3.0
