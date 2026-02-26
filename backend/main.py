from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from services.vision_service import detectar_producto
from services.price_engine import obtener_rango_precios
from database.cache import init_db, guardar_cache, obtener_cache
import traceback
from services.background_service import quitar_fondo
from fastapi import HTTPException


app = FastAPI()

init_db()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.post("/analizar")
async def analizar_producto(file: UploadFile = File(...)):
    try:
        original_bytes = await file.read()

        #Imagen sin fondo solo para object detection
        image_sin_fondo = quitar_fondo(original_bytes)




        image_bytes = quitar_fondo(original_bytes)

        # 🔎 Detectar producto
        titulo, descripcion = detectar_producto(image_bytes,
                                                image_sin_fondo
                                                )

        # 🔄 Normalizar título para búsqueda
        titulo_busqueda = titulo.strip().lower()

        # 🔎 Buscar en cache
        cache = obtener_cache(titulo_busqueda)

        if cache:
            rango = cache
        else:
            rango = obtener_rango_precios(titulo_busqueda)

            # ✅ Guardar cache si vino rango
            if rango:
                # Soporta ambos formatos:
                # 1) {"min": 3990, "max": 12990, ...}
                # 2) {"min": {"precio": 3990}, "max": {"precio": 12990}}
                min_precio = rango["min"]["precio"] if isinstance(rango.get("min"), dict) else rango.get("min")
                max_precio = rango["max"]["precio"] if isinstance(rango.get("max"), dict) else rango.get("max")

                if min_precio is not None and max_precio is not None:
                    guardar_cache(titulo_busqueda, min_precio, max_precio)

        return {
            "titulo": titulo,
            "descripcion": descripcion,
            "rango_precios": rango
        }

    except Exception as e:
        print("ERROR EN /analizar:", repr(e))
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))