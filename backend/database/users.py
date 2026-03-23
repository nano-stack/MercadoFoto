import sqlite3
import os

# --------------------------------------------------
# DB PATH (CORRECTO → users.db)
# --------------------------------------------------

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB = os.path.join(BASE_DIR, "database", "users.db")


# --------------------------------------------------
# INIT USERS TABLE
# --------------------------------------------------

def init_users_db():

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rut TEXT UNIQUE,
        nombre TEXT,
        email TEXT UNIQUE,
        password TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    conn.commit()
    conn.close()


# --------------------------------------------------
# NORMALIZAR RUT
# --------------------------------------------------

def normalizar_rut(rut):
    return rut.replace(".", "").replace("-", "").upper()


# --------------------------------------------------
# VALIDAR RUT (MODULO 11)
# --------------------------------------------------

def validar_rut(rut):

    rut = normalizar_rut(rut)

    if len(rut) < 2:
        return False

    cuerpo = rut[:-1]
    dv = rut[-1]

    if not cuerpo.isdigit():
        return False

    suma = 0
    multiplo = 2

    for c in reversed(cuerpo):
        suma += int(c) * multiplo
        multiplo += 1
        if multiplo > 7:
            multiplo = 2

    resto = 11 - (suma % 11)

    if resto == 11:
        dv_calc = "0"
    elif resto == 10:
        dv_calc = "K"
    else:
        dv_calc = str(resto)

    return dv == dv_calc


# --------------------------------------------------
# CREAR USUARIO
# --------------------------------------------------

def crear_usuario(rut, nombre, email, password):

    rut = normalizar_rut(rut)

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO users (rut, nombre, email, password)
            VALUES (?, ?, ?, ?)
        """, (rut, nombre, email, password))

        conn.commit()
        user_id = cursor.lastrowid

        return user_id

    except sqlite3.IntegrityError as e:
        error_msg = str(e).lower()

        if "rut" in error_msg:
            raise ValueError("El RUT ya está registrado")

        elif "email" in error_msg:
            raise ValueError("El correo ya está registrado")

        else:
            raise ValueError("Error de integridad en la base de datos")

    finally:
        conn.close()


# --------------------------------------------------
# LOGIN USUARIO (POR RUT)
# --------------------------------------------------

def obtener_usuario_por_rut(rut):

    rut = normalizar_rut(rut)

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, rut, nombre, email, password
        FROM usuarios
        WHERE rut = ?
    """, (rut,))

    row = cursor.fetchone()
    conn.close()

    if not row:
        return None

    return {
        "id": row[0],
        "rut": row[1],
        "nombre": row[2],
        "email": row[3],
        "password": row[4]
    }


# --------------------------------------------------
# LOGIN USUARIO (POR EMAIL)
# --------------------------------------------------

def obtener_usuario_por_email(email):

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, rut, nombre, email, password
        FROM usuarios
        WHERE email = ?
    """, (email,))

    row = cursor.fetchone()
    conn.close()

    if not row:
        return None

    return {
        "id": row[0],
        "rut": row[1],
        "nombre": row[2],
        "email": row[3],
        "password": row[4]
    }


# --------------------------------------------------
# OBTENER USUARIO POR ID
# --------------------------------------------------

def obtener_usuario_por_id(user_id):

    conn = sqlite3.connect(DB)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, nombre, email
        FROM usuarios
        WHERE id = ?
    """, (user_id,))

    row = cursor.fetchone()
    conn.close()

    if not row:
        return None

    return {
        "id": row[0],
        "nombre": row[1],
        "email": row[2]
    }