import os
import socket
import segno
import uuid
import webbrowser
from flask import Flask, send_from_directory, render_template, request, redirect, url_for, jsonify
from werkzeug.utils import secure_filename

"""
Este script de Python crea una aplicación web utilizando el framework Flask para un "slideshow" de imágenes. La aplicación 
permite a los usuarios subir imágenes a través de un QR que se genera al iniciar el servidor, y luego 
muestra todas las imágenes subidas en una presentación de diapositivas.

- **`get_local_ip()`:** Obtiene la dirección IP local del servidor para que otros dispositivos en la misma red puedan acceder a la aplicación.
- **`generar_qr_evento(host_ip, port)`:** Genera y guarda un código QR en un archivo PNG. El código QR contiene la URL para subir imágenes al servidor.
- **`allowed_file(filename)`:** Valida la extensión de un archivo para asegurar que sea un tipo de imagen permitido.
- **`mostrar_qr()`:** Muestra una página con el código QR generado.
- **`serve_qr(filename)`:** Sirve el archivo del código QR desde su directorio.
- **`pagina_de_carga()`:** Maneja la lógica para la página de subida de imágenes, tanto para mostrar el formulario (`GET`) como para procesar la subida del archivo (`POST`).
- **`slideshow()`:** Renderiza la página que muestra todas las imágenes subidas en un formato de presentación de diapositivas.
- **`api_imagenes()`:** Sirve como un endpoint de API que devuelve una lista de los nombres de los archivos de imagen subidos en formato JSON.
- **`if __name__ == '__main__':`:** Es el punto de entrada de la aplicación. Configura la IP y el puerto, genera el QR, muestra las URLs de acceso y ejecuta la aplicación Flask.
"""

# --- Configuración ---
UPLOAD_FOLDER = "static/uploads"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif", "bmp", "heif", "webp"}

app = Flask(__name__)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

# --- Asegurar que exista la carpeta de imágenes ---
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# --- PASO 1: Obtener IP local ---
def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

# --- PASO 2: Generar QR ---
def generar_qr_evento(host_ip, port):
    qr_directory = "qr"
    qr_filename = "qr-evento.png"
    qr_filepath = os.path.join(qr_directory, qr_filename)

    if not os.path.exists(qr_directory):
        os.makedirs(qr_directory)

    if not os.path.exists(qr_filepath):
        upload_url = f"http://{host_ip}:{port}/subir"
        # ⚡ QR con color personalizado y bordes redondeados
        qrcode = segno.make(upload_url, error='h')
        qrcode.save(
            qr_filepath,
            scale=10,
            dark="navy",        # color azul oscuro
            light="#f5f5f5",    # fondo gris muy claro
            border=2           # borde más delgado
        )

    return qr_filename

# --- Helper: Validar extensión ---
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# --- Ruta raíz con QR ---
@app.route('/')
def mostrar_qr():
    return render_template("index.html", qr_filename="qr-evento.png")

# --- Servir QR ---
@app.route('/qr/<path:filename>')
def serve_qr(filename):
    return send_from_directory('qr', filename)

# --- Página de subida ---
@app.route('/subir', methods=["GET", "POST"])
def pagina_de_carga():
    if request.method == "POST":
        if "file" not in request.files:
            return "No se envió archivo", 400
        file = request.files["file"]
        if file.filename == "":
            return "Archivo no seleccionado", 400
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            # 👇️ Generar un nombre seguro con UUID
            extension = file.filename.rsplit('.', 1)[1].lower()
            nombre_unico = str(uuid.uuid4()) + '.' + extension
            filepath = os.path.join(app.config["UPLOAD_FOLDER"], nombre_unico)
            file.save(filepath)
            return redirect(url_for("pagina_de_carga"))
            filepath = os.path.join(app.config["UPLOAD_FOLDER"], filename)
            file.save(filepath)
            return redirect(url_for("pagina_de_carga"))
    return render_template("subir.html")

# --- Página de slideshow ---
@app.route('/slideshow')
def slideshow():
    # Obtener todas las imágenes en static/uploads
    imagenes = os.listdir(app.config["UPLOAD_FOLDER"])
    imagenes = [f"uploads/{img}" for img in imagenes]  # rutas relativas
    return render_template("slideshow.html", imagenes=imagenes)

# --- Nueva Ruta: API para obtener imágenes ---
@app.route('/api/imagenes')
def api_imagenes():
    imagenes = os.listdir(app.config["UPLOAD_FOLDER"])
    return jsonify({"imagenes": imagenes})

# --- PUNTO DE ENTRADA ---
if __name__ == '__main__':
    PORT = 5000
    HOST_IP = get_local_ip()
    generar_qr_evento(host_ip=HOST_IP, port=PORT)
    print(f"\n\tServidor listo 🚀")
    print(f"\tPágina con QR:      http://{HOST_IP}:{PORT}/")
    print(f"\tSubida de imágenes: http://{HOST_IP}:{PORT}/subir")
    print(f"\tSlideshow:          http://{HOST_IP}:{PORT}/slideshow\n")

    app.run(host='0.0.0.0', port=PORT, debug=True)

    # 👇️ Abrir el navegador automáticamente
    url_principal = f"http://{HOST_IP}:{PORT}/"
    webbrowser.open_new(url_principal)