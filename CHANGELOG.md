# Changelog - Digital Memoirs

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [Unreleased]

### En Desarrollo
- Configuración de SSD externo para almacenamiento de fotos
- Implementación HTTPS para habilitar Camera API

---

## [0.3.0] - 2025-10-28

### 🚀 Added - Deployment Automation

#### systemd Service Auto-Start
- **Feature**: Flask inicia automáticamente al boot del Raspberry Pi
- **Configuración**:
  - Delay de 180 segundos para esperar red y dnsmasq
  - `TimeoutStartSec=240` para evitar timeout de systemd
  - Auto-restart en caso de fallo
  - Logs centralizados en journalctl
- **Scripts creados**:
  - `scripts/digital-memoirs-FIXED.service` - Servicio con timeout corregido (180s delay)
  - `scripts/digital-memoirs-NO-DELAY.service` - Alternativa rápida (10s delay)
  - `scripts/install_service.sh` - Instalador interactivo automatizado
  - `scripts/SOLUCION_TIMEOUT.md` - Documentación del fix de timeout
- **Archivos modificados**: Scripts directory
- **Beneficios**:
  - Plug & Play para eventos (solo enchufar Pi)
  - No requiere SSH ni laptop el día del evento
  - Recovery automático si Flask crashea

#### Browser Autostart en Kiosk Mode
- **Feature**: Chromium abre automáticamente mostrando slideshow en pantalla completa
- **Configuración**:
  - LXDE autostart desktop file
  - Wait loop hasta que Flask esté disponible (timeout 5 minutos)
  - Kiosk mode sin distracciones
  - Fix de Chromium keyring password (`--password-store=basic`)
- **Scripts creados**:
  - `scripts/autostart_browser.sh` - Script de autostart con health checks
  - `scripts/setup_autostart.sh` - Instalador automatizado
  - `scripts/digital-memoirs-autostart.desktop` - Desktop entry file
  - `scripts/AUTOSTART_BROWSER.md` - Documentación completa
- **Archivos modificados**: Scripts directory, user autostart config
- **Beneficios**:
  - Interface lista para proyectar automáticamente
  - Sin intervención manual requerida
  - Sin prompts de contraseñas

#### Herramientas de Diagnóstico
- **Feature**: Scripts para troubleshooting y debugging
- **Scripts creados**:
  - `scripts/testing/diagnostics/diagnose_service.sh` - Diagnóstico completo de systemd y Flask
  - `scripts/testing/network/network_diagnostic.py` - Diagnóstico de configuración de red
- **Output**: Reportes detallados con estado del sistema
- **Beneficios**:
  - Identificación rápida de problemas
  - Información completa para debugging
  - Verificación de configuración

### 🗂️ Changed - Project Organization

#### Scripts Directory Restructure
- **Cambio**: Reorganización completa del directorio scripts/
- **Nueva estructura**:
  ```
  scripts/
  ├── testing/
  │   ├── diagnostics/       # Herramientas de diagnóstico
  │   └── network/           # Diagnóstico de red
  └── reference/
      ├── hotfixes/          # Versiones anteriores de código
      ├── templates/         # Templates experimentales
      └── services/          # Archivos de servicio obsoletos
  ```
- **Documentación**: README.md en cada subdirectorio explicando propósito y contenido
- **Beneficios**:
  - Separación clara entre código activo y referencia
  - Testing tools organizados
  - Histórico preservado para futura referencia

#### Documentation Overhaul
- **Actualizado**: README.md completo con nueva arquitectura
- **Actualizado**: TODO.md con estado de versión 0.3.0
- **Actualizado**: CHANGELOG.md (este archivo)
- **Pendiente**: CLAUDE.md con documentación técnica actualizada
- **Agregado**: READMEs específicos en subdirectorios de scripts/
- **Beneficios**:
  - Documentación sincronizada con estado actual
  - Guías claras de troubleshooting
  - Histórico de decisiones técnicas

### 🗑️ Removed - Cleanup

#### Obsolete Scripts Deleted
- **Eliminados**:
  - `setup-captive-portal.sh` - Captive portal pausado
  - `simple_hotspot.sh` - Approach obsoleto de hotspot
  - `CAPTIVE_PORTAL_SETUP.md` - Documentación obsoleta
  - Múltiples versiones experimentales de templates
- **Razón**: Código no en uso, approaches abandonados
- **Preservado**: Código valioso movido a `scripts/reference/` para futura referencia

### 🔧 Fixed - Critical Bugs

#### systemd Service Timeout Bug
- **Problema**: Servicio colgaba 90s y fallaba con "Start operation timed out"
- **Causa raíz**: `ExecStartPre=/bin/sleep 180` excedía timeout default de systemd (~90s)
- **Solución**: Agregado `TimeoutStartSec=240` (180s delay + 60s margen)
- **Archivos modificados**: `scripts/digital-memoirs-FIXED.service`
- **Testing**: Verificado funcionando en Raspberry Pi
- **Documentación**: `scripts/SOLUCION_TIMEOUT.md`

#### Browser Auto-Open Failure
- **Problema**: Flask iniciaba pero navegador no se abría, `webbrowser.open()` fallaba silenciosamente
- **Causa raíz**: systemd service corre headless (sin X11 display session)
- **Solución**: Autostart separado usando LXDE desktop session con health checks
- **Archivos creados**: `scripts/autostart_browser.sh`, `scripts/setup_autostart.sh`
- **Testing**: Verificado funcionando después de reboot
- **Documentación**: `scripts/AUTOSTART_BROWSER.md`

#### Chromium Keyring Password Prompt
- **Problema**: Chromium pedía password de keyring en cada inicio
- **Causa raíz**: Chromium intenta usar gnome-keyring por defecto
- **Solución**: Flag `--password-store=basic` en chromium flags
- **Archivos modificados**: `scripts/autostart_browser.sh`
- **Testing**: Sin prompts de password después del fix

### 📝 Documentation

#### Comprehensive README Files
- **Creados**:
  - `scripts/README.md` - Overview de scripts y subdirectorios
  - `scripts/testing/README.md` - Herramientas de testing
  - `scripts/testing/diagnostics/README.md` - Uso de diagnose_service.sh
  - `scripts/testing/network/README.md` - Uso de network_diagnostic.py
  - `scripts/reference/README.md` - Propósito del código de referencia
  - `scripts/reference/hotfixes/README.md` - Documentación de versiones anteriores
  - `scripts/reference/templates/README.md` - Templates experimentales
  - `scripts/reference/services/README.md` - Historia del bug de timeout
- **Contenido**: Explicaciones detalladas, ejemplos de uso, advertencias

#### Troubleshooting Guides
- **Creados**:
  - `scripts/SOLUCION_TIMEOUT.md` - Fix completo del timeout bug
  - `scripts/AUTOSTART_BROWSER.md` - Setup y troubleshooting de autostart
- **Actualizado**: README.md principal con sección de troubleshooting

### ⚡ Performance

#### Startup Optimization
- **Servicio systemd**: Espera controlada de 180s para estabilidad de red
- **Health checks**: Browser espera a que Flask esté ready antes de abrir
- **Logging**: Todos los componentes logueando para debugging

### 🎯 Testing

#### Event Day Workflow Validated
- **Flujo confirmado**:
  1. Enchufar Raspberry Pi ✅
  2. Login en desktop (usuario 'pi') ✅
  3. Esperar 3-5 minutos ✅
  4. Flask corriendo automáticamente ✅
  5. Chromium mostrando slideshow en kiosk ✅
  6. QR codes generados y listos ✅
- **Testing real**: Verificado en Raspberry Pi después de reboot completo

### 📊 Deployment Status

- **systemd service**: ✅ Funcional en producción
- **Browser autostart**: ✅ Funcional en producción
- **Documentation**: ✅ Completa y actualizada
- **Testing tools**: ✅ Disponibles y documentados
- **Event ready**: ✅ Plug & Play sin intervención manual

### 🔄 Migration Notes

#### Upgrading from 0.2.0 to 0.3.0

1. **Instalar servicio systemd**:
   ```bash
   cd /home/pi/Downloads/repos/digital-memoirs/scripts
   chmod +x install_service.sh
   ./install_service.sh
   # Elegir Opción 1 (con delay 180s)
   ```

2. **Instalar browser autostart**:
   ```bash
   cd /home/pi/Downloads/repos/digital-memoirs/scripts
   chmod +x setup_autostart.sh
   ./setup_autostart.sh
   # Responder 'Y' para probar inmediatamente
   ```

3. **Verificar instalación**:
   ```bash
   sudo reboot
   # Después del reboot:
   # - Login en desktop
   # - Esperar 3-5 minutos
   # - Todo debe iniciar automáticamente
   ```

4. **Troubleshooting** (si es necesario):
   ```bash
   cd scripts/testing/diagnostics
   ./diagnose_service.sh > report.txt
   cat report.txt
   ```

---

## [0.2.0] - 2025-10-25

### 🔧 Fixed - CRÍTICO

#### Android Captive Portal HTTP 302 Redirect
- **Problema**: Android CNA (Captive Network Assistant) se cerraba inmediatamente al conectar al WiFi
- **Solución**: Cambio de `HTTP 200 OK` → `HTTP 302 Redirect` en endpoints de captive portal
- **Endpoints modificados**:
  - `/hotspot-detect.html` - iOS
  - `/generate_204` - Android
  - `/connecttest.txt` - Windows
- **Cambio de código**: `render_template('upload.html')` → `redirect(url_for('upload_page'))`
- **Resultado esperado**: Android mantiene CNA abierto automáticamente sin requerir "USE AS IS"
- **Archivos modificados**: `app.py:398-423`

### 📝 Changed
- Actualizada documentación en `TODO.md` con nueva sección "FIX IMPLEMENTADO"
- Actualizada documentación técnica en `CLAUDE.md` con estrategia HTTP 302
- Creado `CHANGELOG.md` para tracking de cambios del proyecto

---

## [0.1.5] - 2025-10-24

### ⚙️ Added - Configuración Captive Portal

#### Implementación Captive Portal WiFi
- **dnsmasq**: Configurado DNS hijacking para dominios de conectividad
  - `captive.apple.com` → `10.0.17.1`
  - `connectivitycheck.gstatic.com` → `10.0.17.1`
  - Wildcards: `*.google.com`, `*.gstatic.com`
- **iptables**: Redirección de tráfico HTTP y DNS
  - HTTP puerto 80 → Flask puerto 5000
  - DNS puerto 53 → dnsmasq
  - Reglas persistentes en `/etc/iptables/rules.v4`
- **Flask endpoints**: Agregados endpoints de detección captive portal
  - iOS: `/hotspot-detect.html`, `/library/test/success.html`
  - Android: `/generate_204`, `/gen_204`
  - Windows: `/connecttest.txt`, `/ncsi.txt`

### 📝 Changed
- Documentación completa en `TODO.md` con comandos de configuración
- Backup de configuraciones anteriores guardados

### ⚠️ Known Issues
- Android requiere presionar "USE AS IS" manualmente (resuelto en v0.2.0)

---

## [0.1.4] - 2025-10-21

### 🔧 Fixed

#### Camera Functionality - getUserMedia API
- **Status**: Feature deshabilitada (no es un bug)
- **Problema**: Camera API bloqueada por navegadores en contexto HTTP insecure
- **Solución**: Botón de cámara deshabilitado con mensaje informativo
- **Archivos modificados**:
  - `templates/upload.html:278-304` - CSS disabled state
  - `templates/upload.html:671-675` - Disabled button markup
  - `templates/upload.html:741-794` - getUserMedia polyfill
  - `templates/upload.html:1235-1244` - Error message handler

#### Widget Orientation Fix
- **Problema**: Status widgets horizontales mientras slideshow rotado 90°
- **Solución**: Aplicado `transform: rotate(90deg)` a ambos widgets
  - Left widget: `translateY(-100%)`
  - Right widget: `translateX(100%)`
- **Archivos modificados**:
  - `templates/display.html:111-116` - Header widget
  - `templates/display.html:153-158` - Photo counter

### 📝 Added
- `CLAUDE.md` - Documentación técnica completa del proyecto
- Polyfill completo para detección de getUserMedia APIs

---

## [0.1.3] - 2025-10-19

### 🔧 Fixed

#### Template Mismatch Bug
- **Problema**: Botón de cámara no ejecutaba ninguna acción
- **Causa raíz**: `app.py` referenciaba archivos inexistentes
  - `upload_fixed.html`, `display_fixed.html`, `qr_fixed.html`
- **Solución**: Corregidos nombres a archivos reales
  - `upload.html`, `display.html`, `qr.html`
- **Archivos modificados**: `app.py:162, 176, 185`

---

## [0.1.2] - 2025-10-17

### 🔧 Fixed - Bugs Críticos de Performance y UX

#### CSS Container Misalignment
- **Problema**: Slideshow no se centraba correctamente en display
- **Solución**:
  - Cambio de `position: relative` → `position: fixed`
  - Reemplazo de margins por `transform: translate(-50%, -50%)`
- **Performance**: Simplificado gradiente de fondo para evitar lag en Firefox
- **Archivos modificados**: `templates/display.html:179-196`

#### Infinite Camera Loop
- **Problema**: Bucle infinito al abrir/cerrar cámara y luego abrir galería
- **Solución**:
  - Agregado flag `isCameraOpen` para state management
  - Implementado `cameraCloseTimeout` con cleanup
  - Función `closeCamera()` con limpieza completa de streams
- **Archivos modificados**: `templates/upload.html:712, 869-885`

#### Bulk Upload Crashes (>800 images)
- **Problema**: Falla al cargar más de 800 imágenes simultáneas
- **Solución**:
  - Implementado `BATCH_UPLOAD_LIMIT = 800`
  - `ThreadPoolExecutor` para procesamiento concurrente (8 workers)
  - Timeout de 30 segundos por archivo
  - Validación previa con advertencia al usuario
- **Archivos modificados**: `app.py:25, 199-204, 237-258`

### ⚡ Performance

#### Optimizaciones de Renderizado
- Reducido particle count de 20 → 15
- Agregado `will-change: auto` y `backface-visibility: hidden`
- GPU acceleration con `transform-style: preserve-3d`
- `@media (prefers-reduced-motion: reduce)` para accesibilidad

### 🎨 UI/UX

#### Dark Theme Implementation
- Fuentes monoespaciadas: `'Fira Code', 'Consolas', 'Monaco', monospace`
- Paleta de colores oscuros con variables CSS
- Efectos glassmorphism y gradientes modernos
- Mejor contraste y jerarquía visual

### 📝 Added
- Endpoint `/api/status` para health checks
- Soporte HEIC/HEIF para fotos de iPhone
- Error handlers HTTP (413, 500)
- Logging mejorado con niveles INFO/ERROR

---

## [0.1.1] - 2025-10-15

### 🔧 Fixed

#### Duplicate Browser Tab Opening
- **Problema**: Flask abría 2 tabs del navegador al iniciar
- **Causa raíz**: `debug=True` causaba que reloader lanzara proceso doble
- **Solución**: Cambio a `debug=False`
- **Archivos modificados**: `app.py:508`

#### Raspberry Pi Access Point Stability
- **Problema**: Conexión inestable en subnet `192.168.10.0/24`
- **Solución**: Migración a subnet `10.0.17.0/24`
- **Nueva configuración**:
  - Gateway: `10.0.17.1`
  - DHCP range: `10.0.17.2 - 10.0.17.254`
  - Subnet mask: `255.255.255.0` (/24)

### 📝 Changed
- Actualizada configuración hostapd y dnsmasq
- Documentación de red en README.md

---

## [0.1.0] - 2025-10-01

### 🎉 Initial Release

#### Core Features
- **QR Code Generation**: Auto-genera QR con IP local para WiFi connection
- **Photo Upload**: Multi-file upload con soporte de galería y cámara
- **Real-time Slideshow**: Auto-refresh cada 2 segundos con rotación 90°
- **Batch Processing**: ThreadPoolExecutor para hasta 800 imágenes por batch
- **UUID File Naming**: Prevención de conflictos de nombres
- **Dark Theme UI**: Glassmorphism design con Fira Code font

#### Technical Stack
- **Framework**: Flask 3.1.2
- **Python**: >=3.11
- **Dependencies**:
  - qrcode 8.2 - QR generation
  - Pillow 11.3.0 - Image processing
  - watchdog 6.0.0 - File system monitoring
  - netifaces 0.11.0 - Network info

#### File Structure
```
digital-memoirs/
├── app.py                 # Flask application (500+ lines)
├── templates/
│   ├── display.html       # Slideshow (680 lines)
│   ├── qr.html            # QR display (669 lines)
│   └── upload.html        # Upload interface (1117 lines)
├── static/
│   └── qr_code.png        # Auto-generated QR
└── uploads/               # User photos (UUID-named)
```

#### API Endpoints
- `GET /` - Main display
- `GET /qr` - QR code page
- `GET /upload` - Upload form
- `POST /upload` - File upload handler
- `GET /api/images` - Current image list
- `GET /api/next_image` - Slideshow next image
- `GET /api/stats` - Application statistics
- `GET /uploads/<filename>` - Serve uploaded files

#### Configuration
- Max upload size: 500MB
- Allowed extensions: png, jpg, jpeg, gif, webp, heic, heif
- Port: 5000
- Host: 0.0.0.0 (all interfaces)

---

## Notas de Versiones

### Sistema de Versionado

Este proyecto usa [Semantic Versioning](https://semver.org/lang/es/):
- **MAJOR version** (X.0.0): Cambios incompatibles de API
- **MINOR version** (0.X.0): Funcionalidad nueva compatible hacia atrás
- **PATCH version** (0.0.X): Bug fixes compatibles hacia atrás

### Categorías de Cambios

- **Added**: Nuevas funcionalidades
- **Changed**: Cambios en funcionalidad existente
- **Deprecated**: Funcionalidad que será removida
- **Removed**: Funcionalidad removida
- **Fixed**: Bug fixes
- **Security**: Parches de seguridad

---

**Última actualización**: 2025-10-28
**Versión actual**: 0.3.0 (en producción)
**Estado**: Plug & Play deployment listo para eventos
