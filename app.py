from flask import Flask, render_template, request, redirect, url_for, jsonify, send_from_directory
import os
import uuid
import qrcode
from PIL import Image
import threading
import time
import webbrowser
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from datetime import datetime
import json

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
# No file size limits - extension validation provides protection

# Create uploads directory if it doesn't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Global variables for slideshow
current_images = []
current_image_index = 0
slideshow_lock = threading.Lock()

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

class UploadHandler(FileSystemEventHandler):
    """Handles new file uploads and renames them with UUID"""
    
    def on_created(self, event):
        if not event.is_directory:
            file_path = event.src_path
            filename = os.path.basename(file_path)
            
            # Wait a moment to ensure file is fully written
            time.sleep(0.5)
            
            if allowed_file(filename):
                # Generate UUID filename while keeping extension
                file_ext = filename.rsplit('.', 1)[1].lower()
                new_filename = f"{uuid.uuid4()}.{file_ext}"
                new_path = os.path.join(app.config['UPLOAD_FOLDER'], new_filename)
                
                try:
                    os.rename(file_path, new_path)
                    print(f"Renamed {filename} to {new_filename}")
                    update_image_list()
                except Exception as e:
                    print(f"Error renaming file: {e}")

def update_image_list():
    """Update the global image list for slideshow"""
    global current_images
    with slideshow_lock:
        current_images = [f for f in os.listdir(app.config['UPLOAD_FOLDER']) 
                         if allowed_file(f)]
        current_images.sort(key=lambda x: os.path.getctime(
            os.path.join(app.config['UPLOAD_FOLDER'], x)
        ), reverse=True)

def generate_qr_code(url):
    """Generate QR code for the upload URL"""
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(url)
    qr.make(fit=True)
    
    qr_img = qr.make_image(fill_color="navy", back_color="white")
    qr_path = "static/qr_code.png"
    os.makedirs("static", exist_ok=True)
    qr_img.save(qr_path)
    return qr_path

@app.route('/')
@app.route('/display')
def display():
    """Main display screen with QR code and slideshow"""
    # Generate QR code for upload URL (replace with your Pi's IP)
    upload_url = request.url_root + 'upload'
    qr_path = generate_qr_code(upload_url)
    
    return render_template('display.html', qr_path=qr_path, upload_url=upload_url)

@app.route('/qr')
def qr():
    """QR code only page - cleaner for guests to read"""
    upload_url = request.url_root + 'upload'
    qr_path = generate_qr_code(upload_url)
    
    return render_template('qr.html', qr_path=qr_path, upload_url=upload_url)

@app.route('/upload')
def upload_page():
    """Upload page for guests"""
    return render_template('upload.html')

@app.route('/upload', methods=['POST'])
def upload_files():
    """Handle file uploads"""
    if 'files' not in request.files:
        return jsonify({'error': 'No files selected'}), 400
    
    files = request.files.getlist('files')
    uploaded_count = 0
    
    for file in files:
        if file and file.filename and allowed_file(file.filename):
            # Save with original filename first, handler will rename with UUID
            filename = file.filename
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(file_path)
            uploaded_count += 1
    
    if uploaded_count > 0:
        return jsonify({'success': f'{uploaded_count} photos uploaded successfully!'})
    else:
        return jsonify({'error': 'No valid files uploaded'}), 400

@app.route('/api/images')
def get_images():
    """API endpoint to get current images for slideshow"""
    with slideshow_lock:
        return jsonify({
            'images': current_images,
            'count': len(current_images)
        })

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    """Serve uploaded files"""
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/api/next_image')
def next_image():
    """Get next image for slideshow"""
    global current_image_index
    
    with slideshow_lock:
        if not current_images:
            return jsonify({'image': None})
        
        image = current_images[current_image_index]
        current_image_index = (current_image_index + 1) % len(current_images)
        
        return jsonify({
            'image': url_for('uploaded_file', filename=image),
            'filename': image,
            'total': len(current_images)
        })

def setup_file_watcher():
    """Setup file system watcher for uploads directory"""
    event_handler = UploadHandler()
    observer = Observer()
    observer.schedule(event_handler, app.config['UPLOAD_FOLDER'], recursive=False)
    observer.start()
    return observer

def open_browser():
    """Open browser after 3 seconds delay"""
    time.sleep(3)
    webbrowser.open('http://localhost:5000/qr')

if __name__ == '__main__':
    # Initialize image list
    update_image_list()
    
    # Start file watcher
    observer = setup_file_watcher()
    
    # Start browser opening thread
    browser_thread = threading.Thread(target=open_browser, daemon=True)
    browser_thread.start()
    
    try:
        # Run Flask app
        print("Starting Flask app...")
        print("Display will open in browser in 3 seconds...")
        app.run(host='0.0.0.0', port=5000, debug=True)
    except KeyboardInterrupt:
        observer.stop()
    
    observer.join()