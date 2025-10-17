# TODO - Digital Memoirs

15/10/2025

## Priority Issues

### 1. Fix Raspberry Pi Access Point Connection Stability

**Status:** DONE

---

### 2. Fix Duplicate Browser Tab Opening on Startup

**Status:** Done
**Description:** When the Flask application starts, it automatically opens the default browser to the `/qr` endpoint. However, it consistently opens **two tabs** instead of one.

**Current Behavior:**

- Expected: Opens 1 tab to `/qr` endpoint
- Actual: Opens 2 tabs to `/qr` endpoint

**Location:** `app.py` - likely in the `open_browser()` function or threading logic

**Investigation Needed:**

- Check if `webbrowser.open()` is being called multiple times
- Verify threading implementation for browser auto-launch
- Review any duplicate signal handlers or initialization code

---

### 3. Change Static IP to New Subnet (10.0.17.0/24)

**Status:** Done
**Description:** Migrate the Raspberry Pi access point from the current subnet `192.168.10.0/24` to a new subnet `10.0.17.0/24`.

**Configuration Details:**

- **Access Point IP (Gateway):** `10.0.17.1`
- **Subnet Mask:** `255.255.255.0` (CIDR: `/24`)
- **DHCP Range:** `10.0.17.2 - 10.0.17.254` (suggested)
- **Reserved:** `10.0.17.1` (must not be assigned to clients to avoid conflicts)

**Files to Update:**

- Hotspot configuration scripts (dnsmasq.conf, hostapd settings)
- Flask app QR code generation logic (if hardcoded IP)
- Documentation and README references

**Rationale:**

- Avoid conflicts with common router subnets (192.168.x.x)
- Use less common subnet range for dedicated event network

---

## Notes

- All tasks should be tested on Raspberry Pi hardware before being marked complete
- Document any configuration changes in CLAUDE.md
- Update README.md with new network configuration details when task #3 is complete
- Consider creating a troubleshooting guide based on findings from task #1

---

17/10/2025

## 📋 Resumen de Issues Corregidos

### ✅ **PRIORIDAD ALTA - PROBLEMAS CRÍTICOS RESUELTOS**

#### 1. **CSS Container Desalineado y Rendimiento (display.html)**

- **Problema:** El contenedor del slideshow no se centraba correctamente y el gradiente causaba problemas de rendimiento en Mozilla
- **Solución Implementada:**
  - Cambié `position: relative` a `position: fixed` para el contenedor del slideshow
  - Reemplazé `margin-left/margin-top` por `transform: translate(-50%, -50%) rotate(90deg)`
  - Simplificé el gradiente de fondo: eliminé el gradiente lineal complejo y usé radiales estáticos
  - Agregué `will-change: auto` y `backface-visibility: hidden` para optimizar el rendimiento
  - Reduje el número de partículas de 20 a 15 para mejor performance

#### 2. **Loop Crítico del Botón de Cámara (upload.html)**

- **Problema:** Bucle infinito cuando se abre/cierra la cámara y luego se intenta abrir galería
- **Solución Implementada:**
  - Agregué control de estado `isCameraOpen` y `cameraCloseTimeout`
  - Implementé `closeCamera()` con limpieza completa de streams
  - Agregué prevención de loops con timeout de 300ms
  - Separé las funciones `selectFiles()` y `toggleCamera()`
  - Implementé botón de cámara visible con interfaz dedicada

#### 3. **Manejo de Cargas Masivas (+800 imágenes)**

- **Problema:** Falla al cargar más de 800 imágenes simultáneas
- **Solución Implementada:**
  - Agregué límite de batch `BATCH_UPLOAD_LIMIT = 800`
  - Implementé `ThreadPoolExecutor` para procesamiento concurrente
  - Agregué timeout de 30 segundos por archivo
  - Mejoré manejo de errores con reporte de archivos fallidos
  - Implementé validación previa con advertencia al usuario

### ✅ **MEJORAS GENERALES IMPLEMENTADAS**

#### 4. **Tema Oscuro y Fuentes Monoespaciadas**

- Cambié todas las fuentes a `'Fira Code', 'Consolas', 'Monaco', monospace`
- Implementé paleta de colores oscuros consistente con variables CSS
- Agregué efectos de glassmorphism y gradientes modernos
- Mejoré la jerarquía visual con mejor contraste

#### 5. **Optimizaciones de Rendimiento**

- Agregué soporte para `HEIC` y `HEIF` (fotos de iPhone)
- Implementé logging mejorado con niveles INFO/ERROR
- Agregué endpoint `/api/status` para health checks
- Optimicé la renderización con `transform-style: preserve-3d`
- Agregué `@media (prefers-reduced-motion: reduce)` para accesibilidad

#### 6. **Manejo Robusto de Errores**

- Implementé try-catch en todas las funciones críticas
- Agregué error handlers HTTP (413, 500)
- Mejoré logs con traceback completo
- Agregué validación de archivos más estricta

---

## 📁 **Archivos Corregidos Entregados**

### 🎯 **Archivos Principales**

- `display_fixed.html` - Slideshow corregido con centrado perfecto
- `upload_fixed.html` - Upload con botón de cámara y prevención de loops  
- `app_fixed.py` - Backend mejorado con límites de batch y concurrencia
- `qr_fixed.html` - Página QR con tema oscuro moderno

### 🔄 **Cómo Implementar**

1. **Reemplaza los archivos originales:**

   ```bash
   # Backup de archivos originales
   mv templates/display.html templates/display_backup.html
   mv templates/upload.html templates/upload_backup.html
   mv templates/qr.html templates/qr_backup.html
   mv app.py app_backup.py
   
   # Instala los archivos corregidos
   cp display_fixed.html templates/display.html
   cp upload_fixed.html templates/upload.html
   cp qr_fixed.html templates/qr.html
   cp app_fixed.py app.py
   ```

2. **Ejecuta la aplicación:**

   ```bash
   python app.py
   ```

---

## 🧪 **Testing Recomendado**

### ✅ **Pruebas de Validación**

1. **CSS Container:** Verificar que el slideshow se centre perfectamente en pantalla
2. **Botón Cámara:** Probar ciclo abre → cierra → galería → cámara sin loops
3. **Cargas Masivas:** Intentar subir 900+ imágenes y verificar manejo controlado
4. **Performance:** Verificar que no hay lag del cursor en Mozilla Firefox
5. **Responsive:** Probar en móvil, tablet y desktop

### 🎯 **Características Nuevas para Probar**

- Botón de cámara funcional con captura directa
- Límite de 800 archivos con advertencia al usuario
- Tema oscuro consistente en todas las páginas
- Indicadores de progreso mejorados
- Health check endpoint en `/api/status`

---

## 📊 **Resultados Esperados**

| Issue Original | Estado | Resultado Esperado |
|---------------|--------|-------------------|
| Container CSS descentrado | ✅ Corregido | Slideshow perfectamente centrado |
| Loop botón cámara | ✅ Corregido | Sin bucles infinitos, flujo limpio |
| Crash +800 imágenes | ✅ Corregido | Límite controlado con mensajes claros |
| Gradiente lag cursor | ✅ Corregido | Performance fluido en todos los navegadores |
| Falta botón cámara | ✅ Implementado | Interfaz completa con captura directa |

---

## 🎨 **Mejoras Estéticas Implementadas**

- **Glassmorphism:** Efectos de cristal con blur y transparencias
- **Gradientes Animados:** Bordes que pulsan y brillan suavemente
- **Partículas de Fondo:** Animaciones sutiles para ambiente dinámico
- **Tipografía Monospace:** Consistencia en todas las interfaces
- **Micro-interacciones:** Hovers, transforms y transiciones suaves

---

## 🚀 **Próximos Pasos Sugeridos**

1. **Implementar los archivos corregidos**
2. **Probar cada issue reportado para confirmar las correcciones**
3. **Realizar testing de carga con 700-900 imágenes**
4. **Considerar asignación de nombres de dominio amigables** (punto de prioridad media)

## 🔧 **Corregir en `app.py` las referencias de:**

- *display_fixed.html*
- *qr_fixed.html*
- *upload_fixed.html*

La referenciacion correcta es sin `_fixed`

```python
✅ return render_template('qr.html', BLAH_PATH=BLAH_PATH, BLAH_URL=BLAH_URL)

👎🏽 return render_template('qr_fixed.html', BLAH_PATH=BLAH_PATH, BLAH_URL=BLAH_URL)
```
