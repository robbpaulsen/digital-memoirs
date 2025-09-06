import os
import socket
import segno
import uuid
import webbrowser
from flask import Flask, send_from_directory, render_template, request, redirect, url_for, jsonify
from werkzeug.utils import secure_filename

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