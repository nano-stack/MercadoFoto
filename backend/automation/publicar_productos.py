import sqlite3
import os
import uuid

from services.background_service import quitar_fondo


DB = "database/publicaciones.db"
UPLOAD_DIR = "uploads"


def publicar(productos):

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    os.makedirs(UPLOAD_DIR, exist_ok=True)

    for p in productos:

        imagen_url = None

        # procesar imagen si existe
        if "imagen_path" in p and p["imagen_path"]:

            with open(p["imagen_path"], "rb") as f:
                image_bytes = f.read()

            imagen_procesada = quitar_fondo(image_bytes)

            filename = f"{uuid.uuid4().hex}.png"
            output_path = os.path.join(UPLOAD_DIR, filename)

            with open(output_path, "wb") as f:
                f.write(imagen_procesada)

            imagen_url = f"/uploads/{filename}"

        cursor.execute("""
        INSERT INTO publicaciones (titulo, descripcion, precio, imagen_url)
        VALUES (?, ?, ?, ?)
        """, (
            p["titulo"],
            p["descripcion"],
            p["precio"],
            imagen_url
        ))

    conn.commit()
    conn.close()