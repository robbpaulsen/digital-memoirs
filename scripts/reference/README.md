# 📚 Reference Code - Digital Memoirs

Este directorio contiene **código de referencia** de versiones anteriores, experimentos y features que no están actualmente en uso pero se conservan para futuros desarrollos o como referencia histórica.

---

## ⚠️ Advertencia

**Los archivos en este directorio NO están en uso activo en la aplicación.**

- ❌ NO ejecutes estos scripts directamente
- ❌ NO copies estos archivos al proyecto principal sin revisar
- ✅ Úsalos como referencia para ideas de diseño/funcionalidad
- ✅ Pueden contener código útil para futuros features

---

## 📁 Estructura

```
reference/
├── hotfixes/         # Versiones anteriores con diferentes fixes/mejoras
│   ├── app-*.py      # Versiones de app.py con diferentes approaches
│   ├── upload-*.html # Versiones de upload.html con mejoras de UI
│   └── README.md
│
├── templates/        # Templates HTML antiguos/experimentales
│   ├── display_original.html
│   ├── qr_original.html
│   ├── upload_original.html
│   ├── upload2.html
│   ├── qr_option_b.html
│   ├── qr_option_c.html
│   └── README.md
│
├── services/         # Archivos de servicio systemd antiguos
│   ├── digital-memoirs.service (versión original con bug)
│   └── README.md
│
└── README.md         # Este archivo
```

---

## 🎯 Propósito de Cada Subdirectorio

### 1. `hotfixes/`
Contiene versiones de `app.py` y `upload.html` con diferentes:
- Bug fixes aplicados
- Mejoras de UI/UX
- Experimentos de funcionalidad
- Cambios de tema de colores

**Por qué se conservan**: Diseños, estilos CSS y funcionalidades que nos gustaron pero no pudimos usar en ese momento (ej: botón de cámara, temas de color alternativos).

### 2. `templates/`
Templates HTML de versiones anteriores que se reemplazaron por mejoras pero contienen:
- Diseños alternativos
- Funcionalidades experimentales
- Features que no funcionaron en ese momento (ej: cámara en HTTP)

**Por qué se conservan**: Ideas de diseño, componentes UI reutilizables, referencia histórica del desarrollo.

### 3. `services/`
Archivos de configuración de systemd que tenían bugs o se reemplazaron:
- Versión original con timeout bug
- Configuraciones experimentales

**Por qué se conservan**: Documentación de problemas resueltos, referencia para troubleshooting.

---

## 📖 Cómo Usar Este Código de Referencia

### Escenario 1: Quieres reutilizar un diseño

1. Navega al subdirectorio apropiado (ej: `templates/`)
2. Lee el README específico de ese directorio
3. Revisa el código del archivo que te interesa
4. Copia **solo las partes necesarias** (CSS, componentes, funciones)
5. Adapta al código actual del proyecto

### Escenario 2: Estás desarrollando una nueva feature

1. Busca en `hotfixes/` si ya experimentamos con algo similar
2. Revisa qué approach se intentó
3. Aprende de los errores/limitaciones anteriores
4. Implementa una versión mejorada

### Escenario 3: Debugging de problemas históricos

1. Revisa `services/` si el problema es de systemd
2. Compara configuraciones antiguas vs actuales
3. Identifica qué cambió y por qué

---

## ⚠️ Advertencias Importantes

### NO hacer:
- ❌ Copiar archivos completos sin revisar
- ❌ Ejecutar scripts directamente
- ❌ Asumir que el código está actualizado
- ❌ Usar sin entender el contexto histórico

### SÍ hacer:
- ✅ Leer los README específicos de cada subdirectorio
- ✅ Entender por qué se archivó ese código
- ✅ Extraer solo ideas/componentes específicos
- ✅ Adaptar al estado actual del proyecto

---

## 📝 Notas Históricas

### Por qué existe este directorio

Durante el desarrollo de Digital Memoirs, hubo múltiples iteraciones de:
- **UI/UX**: Probamos diferentes temas de colores, layouts, componentes
- **Funcionalidad**: Features que no funcionaron en ese momento (cámara en HTTP, captive portal)
- **Configuración**: Diferentes approaches de systemd, autostart, red

En lugar de perder ese trabajo, lo archivamos como referencia para:
- Reutilizar buenos diseños en el futuro
- Aprender de errores pasados
- Documentar la evolución del proyecto

---

## 🗂️ Mantenimiento de este Directorio

### Cuándo agregar archivos aquí:
- Cuando una feature se depreca pero el código es valioso
- Cuando cambias radicalmente un approach pero quieres conservar el anterior
- Cuando tienes múltiples versiones experimentales

### Cuándo eliminar archivos:
- Cuando el código ya NO es relevante para futuros desarrollos
- Cuando existe una versión claramente superior
- Cuando ocupa espacio innecesariamente

---

## 📊 Versiones Documentadas

### app.py
- `hotfixes/app-corregido-1.py` - Primera versión con correcciones
- `hotfixes/app-fixed-1.py` - Fix de bugs críticos
- `hotfixes/app-fixed-2.py` - Mejoras de performance
- `hotfixes/app-fixed-3.py` - Versión con nuevos endpoints

### upload.html
- `hotfixes/upload-fixed-1.py` - Fix de camera loop
- `hotfixes/upload-fixed-2.html` - Mejoras de UI
- `hotfixes/upload-fixed-3.html` - Dark theme mejorado
- `hotfixes/upload-primerui-mejorado.html` - Primera UI con glassmorphism

### Templates
- Ver `templates/README.md` para detalles de cada versión

---

## 🔗 Ver También

- **Documentación principal**: `/README.md`
- **Historial de cambios**: `/CHANGELOG.md`
- **Issues resueltos**: `/TODO.md`
- **Documentación técnica**: `/.github/CLAUDE.md`

---

**Última actualización**: 2025-10-28
**Versión actual del proyecto**: 0.3.0
