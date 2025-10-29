# TODO - Digital Memoirs

**Versión actual:** 0.3.0
**Última actualización:** 2025-10-28

---

## 🎯 Estado del Proyecto - Versión 0.3.0

### ✅ Completado (28/10/2025)

#### **Auto-inicio Completo Implementado**
- ✅ Servicio systemd con timeout corregido (TimeoutStartSec=240)
- ✅ Browser autostart en kiosk mode desde desktop session
- ✅ Fix de Chromium keyring password (--password-store=basic)
- ✅ Scripts de instalación automatizados (install_service.sh, setup_autostart.sh)
- ✅ Herramientas de diagnóstico completas (diagnose_service.sh)

#### **Organización del Proyecto**
- ✅ Directorio scripts/ reorganizado con estructura clara
- ✅ testing/diagnostics/ - Herramientas de diagnóstico de servicio
- ✅ testing/network/ - Diagnóstico de red
- ✅ reference/ - Código histórico y experimental archivado
- ✅ Documentación completa en cada subdirectorio

#### **Funcionalidad Core**
- ✅ Sistema de 2 QR codes (WiFi + URL) funcional
- ✅ Slideshow con actualización en tiempo real
- ✅ Upload de hasta 800 fotos por batch
- ✅ Dark theme glassmorphism en todas las páginas
- ✅ Botón de cámara deshabilitado (requiere HTTPS)

---

## 📋 Tareas Pendientes

### 🔴 Prioridad Alta

#### 1. Configurar Almacenamiento en SSD Externo
**Estado:** Pendiente
**Descripción:** Configurar la aplicación para usar SSD externo como unidad de almacenamiento de fotos en lugar del SD card del Raspberry Pi.

**Tareas:**
- [ ] Identificar punto de montaje del SSD externo
- [ ] Configurar auto-mount del SSD al boot
- [ ] Actualizar path de `uploads/` en app.py
- [ ] Crear backup automático de fotos al SSD
- [ ] Verificar permisos del directorio
- [ ] Testing con watchdog para asegurar detección de nuevas fotos
- [ ] Documentar configuración en README.md

**Beneficios:**
- Mayor capacidad de almacenamiento
- Mejor performance de I/O
- Protege el SD card del Pi

---

### 🟡 Prioridad Media

#### 2. Implementar HTTPS para Habilitar Camera API
**Estado:** En pausa (funcionalidad deshabilitada)
**Descripción:** Configurar Flask con HTTPS para permitir uso de getUserMedia API (botón de cámara).

**Opciones:**
- Certificados self-signed con `ssl_context='adhoc'`
- Certificados Let's Encrypt con dominio
- Reverse proxy con nginx/apache

**Archivos a modificar:**
- `app.py` - Agregar ssl_context a app.run()
- `templates/upload.html` - Habilitar botón de cámara

#### 3. Optimizar Performance en Raspberry Pi 3
**Estado:** Continuo
**Tareas:**
- [ ] Profiling de Flask con 10+ usuarios simultáneos
- [ ] Optimizar tamaño de partículas animadas
- [ ] Considerar cache de thumbnails para slideshow
- [ ] Testing de carga con 500+ fotos
- [ ] Monitorear uso de memoria con múltiples uploads

#### 4. Mejorar UX de Conexión WiFi
**Estado:** Funcional pero mejorable
**Tareas:**
- [ ] Agregar instrucciones más visuales en QR page
- [ ] Considerar segundo idioma (inglés)
- [ ] Video tutorial corto para proyectar
- [ ] QR codes más grandes para mejor escaneabilidad

---

### 🟢 Prioridad Baja

#### 5. Estadísticas del Evento
**Descripción:** Dashboard con métricas en tiempo real

**Features sugeridas:**
- Total de fotos subidas
- Gráfico de uploads por hora
- Dispositivos conectados
- Fotos más vistas (slideshow)

#### 6. Galería de Fotos Subidas
**Descripción:** Vista de todas las fotos subidas para el host

**Features sugeridas:**
- Grid view de thumbnails
- Descargar todas las fotos (ZIP)
- Eliminar fotos individuales
- Marcar fotos como favoritas

#### 7. Configuración Dinámica
**Descripción:** Interface para cambiar settings sin editar código

**Settings sugeridos:**
- Nombre de WiFi
- Duración de slideshow por foto
- Límite de batch upload
- Habilitar/deshabilitar camera

---

## 📚 Backlog - Ideas Futuras

### Networking
- [ ] Captive portal funcional para Android (investigar HTTP 302 + CNA)
- [ ] Dominio .local amigable (digital-memoirs.local)
- [ ] Modo "hotspot standalone" sin conexión a internet

### Funcionalidad
- [ ] Filtros de fotos (B&W, sepia, vintage)
- [ ] Collage automático de fotos
- [ ] Video support (MP4, MOV)
- [ ] Música de fondo en slideshow

### Deployment
- [ ] Docker container para desarrollo
- [ ] Imagen completa de Raspberry Pi OS preconfigurada
- [ ] Script de actualización OTA (over-the-air)

### UX/UI
- [ ] Animaciones de entrada/salida de fotos
- [ ] Efectos de transición personalizables
- [ ] Tema claro/oscuro toggle
- [ ] Modo presentación con controles remotos

---

## 🗄️ Histórico - Issues Resueltos

### Versión 0.3.0 (28/10/2025)

#### ✅ Servicio systemd Timeout Bug
**Problema:** Service colgaba 90s y fallaba con "Start operation timed out"
**Causa:** `ExecStartPre=/bin/sleep 180` excedía timeout default (~90s)
**Solución:** Agregado `TimeoutStartSec=240` en digital-memoirs-FIXED.service
**Archivos:** scripts/digital-memoirs-FIXED.service, scripts/SOLUCION_TIMEOUT.md

#### ✅ Browser No Abre Automáticamente
**Problema:** Flask iniciaba pero navegador no se abría, `webbrowser.open()` fallaba
**Causa:** systemd service corre headless (sin X11 display)
**Solución:** Autostart separado con LXDE .desktop file + autostart_browser.sh
**Archivos:** scripts/autostart_browser.sh, scripts/setup_autostart.sh

#### ✅ Chromium Keyring Password Prompt
**Problema:** Chromium pedía password de keyring en cada inicio
**Causa:** Chromium usa gnome-keyring por defecto
**Solución:** Flag `--password-store=basic` en autostart_browser.sh
**Archivos:** scripts/autostart_browser.sh

#### ✅ Scripts Directory Desorganizado
**Problema:** Mezcla de scripts activos, testing tools y código obsoleto
**Solución:** Reorganización en testing/ y reference/ subdirectorios
**Archivos:** Ver scripts/README.md para estructura completa

---

### Versión 0.2.0 (25/10/2025)

#### ✅ Sistema de 2 QR Codes Implementado
**Solución:** QR WiFi + QR URL separados, captive portal deshabilitado
**Razón:** Android mostraba "sin internet" con captive portal activo
**Estado:** Funcional, usuarios conectan sin problemas

#### ✅ Captive Portal Investigación
**Problema:** Android CNA (Captive Network Assistant) se cerraba inmediatamente
**Intentos:** HTTP 200, HTTP 302, DNS hijacking, iptables
**Resultado:** Captive portal pausado, se usa sistema de 2 QR codes

---

### Versión 0.1.0 (17-21/10/2025)

#### ✅ Camera Loop Bug
**Problema:** Bucle infinito cuando se abre/cierra cámara y luego se abre galería
**Solución:** Control de estado `isCameraOpen`, cleanup de streams, timeout 300ms
**Archivos:** templates/upload.html

#### ✅ CSS Container Desalineado
**Problema:** Slideshow no centraba correctamente, gradiente causaba lag
**Solución:** `position: fixed`, `transform: translate(-50%, -50%)`, gradiente simplificado
**Archivos:** templates/display.html

#### ✅ Widget Orientation Mismatch
**Problema:** Widgets horizontales no alineaban con slideshow rotado 90°
**Solución:** `transform: rotate(90deg)` en ambos widgets
**Archivos:** templates/display.html

#### ✅ Cargas Masivas +800 Imágenes
**Problema:** Falla al cargar más de 800 imágenes simultáneas
**Solución:** `BATCH_UPLOAD_LIMIT = 800`, `ThreadPoolExecutor`, timeout 30s/archivo
**Archivos:** app.py

#### ✅ Camera Functionality Blocked
**Problema:** getUserMedia API undefined en HTTP context
**Causa:** Browsers bloquean camera API en HTTP (no localhost)
**Solución:** Botón deshabilitado visualmente, requiere HTTPS para habilitar
**Archivos:** templates/upload.html

#### ✅ Template Mismatch
**Problema:** app.py intentaba servir `upload_fixed.html`, `display_fixed.html` (no existen)
**Solución:** Corregidos nombres a upload.html, display.html, qr.html
**Archivos:** app.py

---

## 🧪 Testing Checklist

### Pre-Evento (2 horas antes)
- [ ] Raspberry Pi enciende correctamente
- [ ] Servicio systemd inicia Flask automáticamente (esperar 3-5 min)
- [ ] Chromium abre en kiosk mode mostrando slideshow
- [ ] WiFi "MomentoMarco" está activo y visible
- [ ] QR codes se muestran correctamente en /qr
- [ ] Proyector/TV conectado y funcionando

### Testing con Dispositivo Real
- [ ] Escanear QR WiFi → Conecta automáticamente
- [ ] Escanear QR URL → Abre navegador en /upload
- [ ] Subir 1 foto de prueba → Aparece en slideshow
- [ ] Subir 10 fotos batch → Todas se procesan
- [ ] Verificar performance del slideshow con 50+ fotos

### Durante el Evento
- [ ] Monitorear logs de Flask (journalctl -u digital-memoirs -f)
- [ ] Verificar slideshow actualiza con fotos nuevas
- [ ] Tener laptop con SSH al Pi por si surge problema
- [ ] Documentar cualquier issue para post-mortem

### Post-Evento
- [ ] Backup de todas las fotos del directorio uploads/
- [ ] Revisar logs para errores o warnings
- [ ] Documentar issues encontrados en TODO.md
- [ ] Actualizar CHANGELOG.md con lecciones aprendidas

---

## 🚨 Troubleshooting Rápido

### Servicio no inicia después de reboot
```bash
sudo systemctl status digital-memoirs
sudo journalctl -u digital-memoirs -n 50
cd scripts/testing/diagnostics
./diagnose_service.sh > report.txt
```

### Browser no se abre automáticamente
```bash
ls ~/.config/autostart/digital-memoirs-autostart.desktop
tail -f ~/.digital-memoirs-autostart.log
cd /home/pi/Downloads/repos/digital-memoirs/scripts
./autostart_browser.sh
```

### WiFi no visible
```bash
ip addr show wlan0
sudo systemctl status dnsmasq
cd scripts/testing/network
python3 network_diagnostic.py
```

### Flask crashea
```bash
sudo journalctl -u digital-memoirs -n 100
df -h  # Verificar espacio en disco
ls -la uploads/  # Verificar permisos
```

---

## 📖 Documentación Relacionada

- **README.md** - Instalación y uso general
- **CHANGELOG.md** - Historial de versiones
- **.github/CLAUDE.md** - Documentación técnica completa
- **scripts/README.md** - Guía de scripts
- **scripts/SOLUCION_TIMEOUT.md** - Detalles del bug de timeout
- **scripts/AUTOSTART_BROWSER.md** - Setup de autostart completo

---

**Última revisión:** 2025-10-28
**Estado del proyecto:** Funcional en producción
**Próximo milestone:** SSD external storage configuration
