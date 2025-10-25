¡Ah, perfecto\! Gracias por la aclaración.

Esa información (que el Pi *tiene* internet en `eth0` pero *no* la comparte) confirma al 100% mi diagnóstico anterior.

**Tu idea de los dos QR no es necesaria. Tu "selling point" de un solo QR SÍ es posible y tu código está al 99% de lograrlo.**

El problema es exactamente el que te describí: tu `app.py` está respondiendo `HTTP 200 OK` a las peticiones de verificación del sistema operativo. El sistema operativo ve ese "OK" y piensa "¡Perfecto, ya inicié sesión\!" y cierra el mini-navegador (el CNA).

La solución sigue siendo la misma que te propuse en mi mensaje anterior. Es un cambio muy pequeño en tu `app.py`.

-----

## La Solución (Confirmada)

No se necesitas tocar `dnsmasq.conf`. Déjarlo tal como se tiene en `CAPTIVE_PORTAL_SETUP.md` (interceptando `gstatic.com`, `apple.com`, etc.). El único cambio que se necesita es en las **rutas del portal cautivo** dentro de `app.py`.

### Posible bloque de codigo Erróneo (La versión actual)

En tu `app.py` (línea 348 aprox), tienes esto:

```python
# ============================================================
# CAPTIVE PORTAL DETECTION ENDPOINTS
# ============================================================

@app.route('/hotspot-detect.html')
# ...
def ios_captive_portal():
    logger.info("🍎 iOS captive portal detected - showing /upload")
    return render_template('upload.html') # <-- PROBLEMA 1: Devuelve 200 OK

@app.route('/generate_204')
# ...
def android_captive_portal():
    logger.info("🤖 Android captive portal detected - showing /upload")
    # ... (tu código de meta-refresh) ...
    resp = make_response(response, 200) # <-- PROBLEMA 2: Devuelve 200 OK
    return resp

@app.route('/connecttest.txt')
# ...
def windows_captive_portal():
    logger.info("🪟 Windows captive portal detected - showing /upload")
    return render_template('upload.html') # <-- PROBLEMA 3: Devuelve 200 OK
```

### El Código Correcto (La Solución)

Se debe cambiar esas rutas para que **no respondan con la página**, sino que **redirijan** (`HTTP 302`) a la página de `/upload`.

Reemplaza toda esa sección por esto:

```python
# ============================================================
# CAPTIVE PORTAL DETECTION ENDPOINTS
# ============================================================

@app.route('/hotspot-detect.html')
@app.route('/library/test/success.html')
def ios_captive_portal():
    """iOS captive portal detection - REDIRECTS to upload page"""
    logger.info("🍎 iOS captive portal detected - redirecting to /upload")
    # CORRECTO: Devuelve 302 Redirect
    return redirect(url_for('upload_page'))

@app.route('/generate_204')
@app.route('/gen_204')
def android_captive_portal():
    """Android captive portal detection - REDIRECTS to upload page"""
    logger.info("🤖 Android captive portal detected - redirecting to /upload")
    # CORRECTO: Devuelve 302 Redirect
    return redirect(url_for('upload_page'))

@app.route('/connecttest.txt')
@app.route('/ncsi.txt')
def windows_captive_portal():
    """Windows captive portal detection - REDIRECTS to upload page"""
    logger.info("🪟 Windows captive portal detected - redirecting to /upload")
    # CORRECTO: Devuelve 302 Redirect
    return redirect(url_for('upload_page'))
```

-----

### Por qué esto funciona

Al responder con una redirección `HTTP 302` en lugar de un `HTTP 200`:

1.  El servicio de fondo de Android pide `/generate_204`.
2.  La app le responde: "No estoy listo, ve a `/upload`" (con el `HTTP 302`).
3.  El sistema operativo entiende el mensaje y dice: "OK, es un portal. La página de inicio es `/upload`".
4.  Lanza el mini-navegador (CNA) y le ordena ir directamente a `/upload`.
5.  El servicio de fondo *sigue* preguntando por `/generate_204` para ver si el inicio de sesión se completó.
6.  La app *sigue* respondiéndole "No, ve a `/upload`" (con el `302`).

Como el servicio de fondo **nunca** recibe la señal de "éxito" (un `200` o `204`), el sistema operativo asume que sigues "iniciando sesión" y **deja el mini-navegador abierto en la página `/upload`**.

7.  En **`app.py`**: Aplicar los cambios de `render_template` por `redirect` en las rutas del portal.
