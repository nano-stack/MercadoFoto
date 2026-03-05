import sqlite3
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "database", "publicaciones.db")


def init_publicaciones_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS publicaciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descripcion TEXT NOT NULL,
            precio REAL NOT NULL,
            imagen_url TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    conn.close()


def guardar_publicacion(titulo, descripcion, precio, imagen_url):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO publicaciones (titulo, descripcion, precio, imagen_url)
        VALUES (?, ?, ?, ?)
    """, (titulo, descripcion, precio, imagen_url))

    conn.commit()
    conn.close()


def obtener_publicaciones():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, titulo, descripcion, precio, imagen_url
        FROM publicaciones
        ORDER BY id DESC
    """)

    rows = cursor.fetchall()
    conn.close()

    publicaciones = []
    for row in rows:
        publicaciones.append({
            "id": row[0],
            "titulo": row[1],
            "descripcion": row[2],
            "precio": row[3],
            "imagen_url": row[4],
        })

    return publicaciones