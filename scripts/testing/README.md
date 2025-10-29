# 🧪 Testing & Diagnostics - Digital Memoirs

Este directorio contiene herramientas de testing y diagnóstico para Digital Memoirs.

---

## 📁 Estructura

```
testing/
├── diagnostics/      # Diagnóstico del servicio systemd y Flask
│   ├── diagnose_service.sh
│   └── README.md
├── network/          # Diagnóstico de red y conectividad
│   ├── network_diagnostic.py
│   └── README.md
└── README.md         # Este archivo
```

---

## 🎯 Propósito

Estos scripts están diseñados para:
- ✅ Diagnosticar problemas del servicio systemd
- ✅ Verificar configuración de red (wlan0, dnsmasq)
- ✅ Probar conectividad y endpoints de Flask
- ✅ Generar reportes completos para troubleshooting

---

## 📋 Herramientas Disponibles

### 1. Diagnóstico del Servicio

**Ubicación**: `diagnostics/diagnose_service.sh`

**Propósito**: Diagnóstico exhaustivo del servicio systemd y Flask

**Uso**:
```bash
cd /home/pi/Downloads/repos/digital-memoirs/scripts/testing/diagnostics
./diagnose_service.sh > diagnosis_report.txt 2>&1
```

**Ver**: `diagnostics/README.md` para más detalles

---

### 2. Diagnóstico de Red

**Ubicación**: `network/network_diagnostic.py`

**Propósito**: Verificar configuración de red, interfaces y conectividad

**Uso**:
```bash
cd /home/pi/Downloads/repos/digital-memoirs/scripts/testing/network
python3 network_diagnostic.py
```

**Ver**: `network/README.md` para más detalles

---

## 🔧 Cuándo Usar Estos Scripts

### Usa `diagnostics/diagnose_service.sh` cuando:
- ❌ El servicio systemd no inicia
- ❌ Flask no responde
- ❌ Hay errores en los logs
- ❌ El navegador no se abre automáticamente

### Usa `network/network_diagnostic.py` cuando:
- ❌ El WiFi no funciona
- ❌ Los invitados no pueden conectarse
- ❌ dnsmasq tiene problemas
- ❌ Las IPs no se asignan correctamente

---

## 📝 Notas

- Estos scripts NO modifican ninguna configuración, solo diagnostican
- Los reportes generados pueden compartirse para análisis remoto
- Ejecutar con usuario `pi` para acceso completo

---

**Última actualización**: 2025-10-28
