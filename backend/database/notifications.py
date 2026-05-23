import sqlite3
import os
from config import PUBLICACIONES_DB as DB


def init_notifications_db():

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        tipo TEXT,
        mensaje TEXT,
        leido INTEGER DEFAULT 0,
        publicacion_id INTEGER DEFAULT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # Migración: agregar columna si no existe
    try:
        cursor.execute("ALTER TABLE notifications ADD COLUMN publicacion_id INTEGER DEFAULT NULL")
    except Exception:
        pass

    conn.commit()
    conn.close()


def crear_notificacion(user_id, tipo, mensaje, publicacion_id=None):

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO notifications (user_id, tipo, mensaje, publicacion_id)
        VALUES (?, ?, ?, ?)
    """, (user_id, tipo, mensaje, publicacion_id))

    conn.commit()
    conn.close()


def obtener_notificaciones(user_id):

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, tipo, mensaje, leido, created_at, publicacion_id
        FROM notifications
        WHERE user_id = ?
        ORDER BY id DESC
        LIMIT 50
    """, (user_id,))

    rows = cursor.fetchall()
    conn.close()

    data = []
    for r in rows:
        data.append({
            "id":             r[0],
            "tipo":           r[1],
            "mensaje":        r[2],
            "leido":          r[3],
            "fecha":          r[4],
            "publicacion_id": r[5],
        })

    return data