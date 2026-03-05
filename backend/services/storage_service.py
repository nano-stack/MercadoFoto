import os
import uuid

# Ruta base del backend
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Carpeta uploads dentro de backend
UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")


def guardar_imagen_procesada(image_bytes: bytes) -> str:
    """
    Guarda la imagen procesada en la carpeta uploads
    y devuelve la ruta pública relativa.
    """

    # Crear carpeta uploads si no existe
    os.makedirs(UPLOAD_DIR, exist_ok=True)

    # Generar nombre único
    filename = f"{uuid.uuid4().hex}.png"
    file_path = os.path.join(UPLOAD_DIR, filename)

    # Guardar archivo
    with open(file_path, "wb") as f:
        f.write(image_bytes)

    # Retornar ruta pública (usada por FastAPI StaticFiles)
    return f"/uploads/{filename}"