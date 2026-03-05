# backend/database/analisis_cache.py
import sqlite3
from datetime import datetime
from typing import Optional, Tuple

DB_PATH = "database/analisis_cache.db"

def init_cache_db():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS analisis_cache (
            image_hash TEXT PRIMARY KEY,
            titulo TEXT NOT NULL,
            descripcion TEXT NOT NULL,
            used_gemini INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
        )
    """)
    conn.commit()
    conn.close()

def get_cached_analisis(image_hash: str) -> Optional[Tuple[str, str, int]]:
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute(
        "SELECT titulo, descripcion, used_gemini FROM analisis_cache WHERE image_hash = ?",
        (image_hash,)
    )
    row = cur.fetchone()
    conn.close()
    if not row:
        return None
    return row[0], row[1], int(row[2])

def save_cached_analisis(image_hash: str, titulo: str, descripcion: str, used_gemini: int):
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute("""
        INSERT OR REPLACE INTO analisis_cache (image_hash, titulo, descripcion, used_gemini, created_at)
        VALUES (?, ?, ?, ?, ?)
    """, (image_hash, titulo, descripcion, int(used_gemini), datetime.utcnow().isoformat()))
    conn.commit()
    conn.close()