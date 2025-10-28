# 🔧 Solución al Problema del Timeout del Servicio systemd

## 🐛 El Problema

Al ejecutar `sudo systemctl start digital-memoirs`, el comando se cuelga por 180 segundos y luego falla con error de timeout.

### Causa Raíz

El archivo de servicio original tiene:

```ini
ExecStartPre=/bin/sleep 180
```

Esto hace que systemd espere 3 minutos ANTES de ejecutar Flask. Sin embargo, **systemd tiene un timeout por defecto de ~90 segundos** para que un servicio arranque.

**Resultado**: systemd espera 90 segundos → timeout → marca el servicio como "failed" → nunca ejecuta Flask.

---

## ✅ Soluciones Disponibles

### Solución 1: Aumentar Timeout de systemd (RECOMENDADA SI TIENES PROBLEMAS DE RED)

**Archivo**: `scripts/digital-memoirs-FIXED.service`

**Cambios**:
- Agrega `TimeoutStartSec=240` (permite 240 segundos = 180s delay + 60s margen)
- Mantiene el delay de 180 segundos

**Ventajas**:
- ✅ Máxima confiabilidad (asegura que wlan0 y dnsmasq estén listos)
- ✅ No depende de timing preciso de la red

**Desventajas**:
- ⏱️ Arranque lento (3+ minutos después del boot)

**Cuándo usar**:
- Si tienes problemas con wlan0 tardando en configurarse
- Si el Raspberry Pi es viejo y lento
- Para máxima estabilidad en eventos importantes

---

### Solución 2: Eliminar Delay y Confiar en systemd (RECOMENDADA SI LA RED ES RÁPIDA)

**Archivo**: `scripts/digital-memoirs-NO-DELAY.service`

**Cambios**:
- Cambia `ExecStartPre=/bin/sleep 180` → `ExecStartPre=/bin/sleep 10`
- Agrega `Requires=dnsmasq.service` (espera obligatoriamente a dnsmasq)
- Timeout normal: `TimeoutStartSec=60`

**Ventajas**:
- ✅ Arranque rápido (~30 segundos total)
- ✅ Más profesional y moderno
- ✅ No hay problemas de timeout

**Desventajas**:
- ⚠️ Si wlan0 tarda mucho, puede fallar (pero systemd reintentará)

**Cuándo usar**:
- Si tu red se configura rápido (< 30 segundos)
- Para desarrollo y testing rápido
- En producción con red estable

---

## 📦 Instalación Fácil

He creado un **script de instalación automático** que hace todo por ti:

```bash
cd /home/pi/Downloads/repos/digital-memoirs
chmod +x scripts/install_service.sh
./scripts/install_service.sh
```

El script:
1. ✅ Verifica pre-requisitos (uv, dnsmasq, app.py)
2. ✅ Te pregunta qué versión instalar (con delay o sin delay)
3. ✅ Hace backup del servicio anterior
4. ✅ Instala el servicio nuevo
5. ✅ Te ofrece iniciarlo inmediatamente o esperar al próximo boot
6. ✅ Muestra logs en tiempo real si quieres

---

## 🧪 Testing Manual

### Diagnóstico Completo

Usa el script de diagnóstico para obtener **toda** la información de una vez:

```bash
cd /home/pi/Downloads/repos/digital-memoirs
chmod +x scripts/diagnose_service.sh
./scripts/diagnose_service.sh > diagnosis_report.txt 2>&1
```

El script verifica:
- ✅ Rutas y archivos (uv, app.py, pyproject.toml)
- ✅ Permisos (carpetas uploads/, static/)
- ✅ Estado del servicio systemd
- ✅ Logs completos (últimas 100 líneas)
- ✅ dnsmasq funcionando
- ✅ Test manual del comando ExecStart
- ✅ Red (wlan0, interfaces)
- ✅ Python y dependencias
- ✅ Análisis de errores comunes

**Envía el archivo `diagnosis_report.txt` para análisis completo.**

---

## ❓ Respuesta a tus Preguntas

### 1. ¿El problema es que no se activa el entorno virtual?

**❌ No**. El comando `uv run app.py` es inteligente:
- `uv` detecta automáticamente el `pyproject.toml`
- Crea `.venv` si no existe
- Instala dependencias automáticamente
- Activa el entorno virtual internamente
- Ejecuta `app.py`

**No necesitas** hacer `source .venv/bin/activate` manualmente.

**El problema real** es el timeout de systemd, NO el entorno virtual.

### 2. ¿Se puede "compilar" la aplicación?

**Sí**, pero **NO resolvería este problema específico del timeout**.

#### Opciones de "compilación":

**A) PyInstaller** (empaqueta Python + dependencias en un binario):

```bash
# Instalar PyInstaller
pip install pyinstaller

# Crear binario
pyinstaller --onefile app.py
```

**Pros**:
- ✅ Un solo archivo ejecutable
- ✅ No necesita Python instalado

**Contras**:
- ❌ **NO resuelve el timeout de systemd** (el delay seguiría ahí)
- ❌ Binario grande (~50-100 MB con Flask + dependencias)
- ❌ Más lento de iniciar que Python directo
- ❌ Complica debugging (sin logs de Python claros)

---

**B) Containerización con Docker**:

```dockerfile
FROM python:3.11-slim
COPY . /app
WORKDIR /app
RUN pip install -e .
CMD ["python", "app.py"]
```

**Pros**:
- ✅ Entorno aislado y reproducible
- ✅ Fácil de mover entre máquinas

**Contras**:
- ❌ **NO resuelve el timeout** (el delay seguiría ahí)
- ❌ Requiere instalar Docker en Raspberry Pi
- ❌ Overhead de memoria (~100MB extra)

---

**C) uv con pyproject.toml (LO QUE YA TIENES)** ✅:

**Pros**:
- ✅ Ya está implementado
- ✅ Rápido (uv es más rápido que pip)
- ✅ Gestión automática de dependencias
- ✅ Fácil de actualizar

**Contras**:
- ⚠️ Requiere `uv` instalado (ya lo tienes)

---

### 3. ¿Por qué NO compilar?

Para este tipo de aplicación web con Flask:

1. **No hay beneficio** - Flask necesita Python runtime de todas formas
2. **Más lento** - PyInstaller descomprime todo al iniciar
3. **Más difícil de mantener** - Cada cambio requiere recompilar
4. **Debugging complicado** - Los errores son más difíciles de rastrear

**Recomendación**: Mantén `uv run` como está. Es la forma moderna y correcta de hacerlo.

---

## 🎯 Solución Recomendada

### Para el evento del sábado:

1. **Usa el script de instalación**:
   ```bash
   ./scripts/install_service.sh
   ```

2. **Selecciona versión CON DELAY** (opción 1):
   - Más confiable para el evento
   - Aunque es lenta, garantiza que todo esté listo

3. **Prueba con un reboot completo**:
   ```bash
   sudo reboot
   # Espera 4 minutos
   # Verifica: sudo systemctl status digital-memoirs
   ```

### Después del evento:

1. **Prueba la versión SIN DELAY** (opción 2):
   - Si funciona bien, úsala para futuros eventos
   - Arranque mucho más rápido

---

## 📊 Comparación de Versiones

| Característica | CON DELAY (180s) | SIN DELAY (10s) |
|---------------|------------------|-----------------|
| Tiempo total de arranque | ~200s (3.5 min) | ~30s |
| Confiabilidad | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Timeout de systemd | 240s (aumentado) | 60s (normal) |
| Requiere red rápida | ❌ No | ✅ Sí |
| Recomendado para evento | ✅ SÍ | ⚠️ Solo si probaste antes |
| Recomendado para desarrollo | ❌ Muy lento | ✅ SÍ |

---

## 🚨 Troubleshooting

### Si sigue fallando después de aplicar la solución:

1. **Ejecuta el diagnóstico**:
   ```bash
   ./scripts/diagnose_service.sh > diagnosis_report.txt 2>&1
   ```

2. **Verifica que uv funciona manualmente**:
   ```bash
   cd /home/pi/Downloads/repos/digital-memoirs
   /home/pi/.local/bin/uv run app.py
   # Debería iniciar Flask sin errores
   ```

3. **Revisa los logs del servicio**:
   ```bash
   sudo journalctl -u digital-memoirs -n 100 --no-pager
   ```

4. **Busca errores específicos**:
   - `timeout` → Aumenta más el TimeoutStartSec
   - `permission denied` → Verifica owner con `ls -la`
   - `no such file` → Verifica rutas en el servicio
   - `uv: command not found` → Verifica PATH en el servicio

---

## 📝 Archivos Generados

He creado estos archivos para ti:

1. ✅ `scripts/diagnose_service.sh` - Diagnóstico completo
2. ✅ `scripts/digital-memoirs-FIXED.service` - Versión con delay corregida
3. ✅ `scripts/digital-memoirs-NO-DELAY.service` - Versión sin delay
4. ✅ `scripts/install_service.sh` - Instalador automático
5. ✅ `scripts/SOLUCION_TIMEOUT.md` - Este documento

**Sube todos a tu Raspberry Pi y estarás listo.**

---

## 🎉 Resumen

- ✅ El problema es **timeout de systemd**, NO el entorno virtual
- ✅ La solución es **aumentar TimeoutStartSec** o **reducir el delay**
- ✅ NO necesitas compilar la aplicación (no resolvería nada)
- ✅ Usa el script `install_service.sh` para instalación fácil
- ✅ Usa `diagnose_service.sh` para debugging completo

**Para el evento: usa versión CON DELAY (más confiable)**
**Para desarrollo: usa versión SIN DELAY (más rápida)**
