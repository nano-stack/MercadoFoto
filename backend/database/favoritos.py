import sqlite3
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB = os.path.join(BASE_DIR, "database", "publicaciones.db")


def init_favoritos_db():

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS favoritos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        publicacion_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    conn.commit()
    conn.close()


def guardar_favorito(user_id, publicacion_id):

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO favoritos (
            user_id,
            publicacion_id
        )
        VALUES (?, ?)
    """, (
        user_id,
        publicacion_id
    ))

    conn.commit()
    conn.close()


def obtener_favoritos(user_id):

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT publicacion_id
        FROM favoritos
        WHERE user_id = ?
    """, (user_id,))

    rows = cursor.fetchall()
    conn.close()

    return [r[0] for r in rows]


# --------------------------------------------------
# USUARIOS QUE GUARDARON PUBLICACION
# --------------------------------------------------

def obtener_usuarios_favorito(publicacion_id):

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT user_id
        FROM favoritos
        WHERE publicacion_id = ?
    """, (publicacion_id,))

    rows = cursor.fetchall()

    conn.close()

    return [r[0] for r in rows]