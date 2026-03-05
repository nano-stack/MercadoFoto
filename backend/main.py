from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import traceback

from services.translation_service import traducir_a_es
from database.analisis_cache import init_cache_db, get_cached_analisis, save_cached_analisis
import hashlib

from services.vision_service import detectar_producto
from services.background_service import quitar_fondo
from services.storage_service import guardar_imagen_procesada

from fastapi import Request

from database.publicaciones import (
    init_publicaciones_db,
    guardar_publicacion,
    obtener_publicaciones
)

# --------------------------------------------------
# APP
# --------------------------------------------------

app = FastAPI()

# Exponer carpeta uploads como pública
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Inicializar base de datos de publicaciones
init_publicaciones_db()
init_cache_db()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------------------------------------
# ANALIZAR IMAGEN
# --------------------------------------------------

@app.post("/analizar")
async def analizar_producto(file: UploadFile = File(...)):
    try:
        # 1. Leer imagen original
        original_bytes = await file.read()
        image_hash = hashlib.sha256(original_bytes).hexdigest()

        # 2. Revisar cache
        cached = get_cached_analisis(image_hash)

        if cached:
            titulo, descripcion, used_gemini = cached
            print("CACHE HIT - Gemini usado:", used_gemini)
        else:
            titulo, descripcion, used_gemini = detectar_producto(original_bytes)
            save_cached_analisis(image_hash, titulo, descripcion, used_gemini)
            print("CACHE MISS - Gemini usado:", used_gemini)

        # 3. Traducir primero
        if titulo and titulo.strip():
            palabras_no_objeto = ["endpoint", "function", "api", "http", "json"]

            if titulo.lower() not in palabras_no_objeto:
                try:
                    titulo_traducido = traducir_a_es(titulo)
                    if titulo_traducido and titulo_traducido.strip():
                        titulo = titulo_traducido
                except Exception:
                    pass

        # 4. Quitar fondo después del análisis
        imagen_procesada = quitar_fondo(original_bytes)

        # 5. Guardar imagen procesada
        imagen_url = guardar_imagen_procesada(imagen_procesada)

        return {
            "titulo": titulo,
            "descripcion": descripcion,
            "imagen_url": imagen_url
        }

    except Exception as e:
        print("ERROR EN /analizar:", repr(e))
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


# --------------------------------------------------
# MODELO PUBLICACIÓN
# --------------------------------------------------

class Publicacion(BaseModel):
    titulo: str
    descripcion: str
    precio: float
    imagen_url: str



# --------------------------------------------------
# PUBLICAR PRODUCTO
# --------------------------------------------------

@app.post("/publicar")
def publicar_producto(publicacion: Publicacion):
    print("DATA RECIBIDA:", publicacion)

    try:
        guardar_publicacion(
            publicacion.titulo,
            publicacion.descripcion,
            publicacion.precio,
            publicacion.imagen_url
        )

        return {"mensaje": "Producto publicado correctamente"}

    except Exception as e:
        print("ERROR EN /publicar:", repr(e))
        raise HTTPException(status_code=500, detail=str(e))


# --------------------------------------------------
# LISTAR PUBLICACIONES
# --------------------------------------------------

@app.get("/publicaciones")
def listar_publicaciones():
    try:
        return obtener_publicaciones()
    except Exception as e:
        print("ERROR EN /publicaciones:", repr(e))
        raise HTTPException(status_code=500, detail=str(e))