from google.cloud import vision
import re
from services.description_service import generar_descripcion_corta
import difflib
from services.gemini_service import gemini_titulo_producto
from services.classification_rules import is_generic_or_low_confidence


DOMINIOS_CHILE = [
    "mercadolibre.cl",
    "falabella.com",
    "sodimac.cl",
    "paris.cl",
    "ripley.cl",
    "ikea.cl"
]


def limpiar_texto(texto):
    texto = re.sub(r"[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]", "", texto)
    return texto.strip()

def normalizar_titulo(titulo):
    traducciones = {
        "mug": "Taza",
        "cup": "Taza",
        "coffee cup": "Taza",
        "glass": "Vaso",
        "bottle": "Botella"
    }

    t = titulo.lower()

    if t in traducciones:
        return traducciones[t]

    return titulo

def detectar_producto(original_bytes):

    used_gemini = 0

    client = vision.ImageAnnotatorClient()
    image = vision.Image(content=original_bytes)

    titulo = None
    mejor_score = None

    # --------------------------------------------------
    # 1️⃣ OBJECT DETECTION (PRIORIDAD MÁXIMA)
    # --------------------------------------------------
    obj_response = client.object_localization(image=image)
    objetos = obj_response.localized_object_annotations

    print("OBJETOS DETECTADOS:")
    for obj in objetos:
        print(obj.name, obj.score)

    if objetos:
        objetos_ordenados = sorted(objetos, key=lambda x: x.score, reverse=True)
        mejor_objeto = objetos_ordenados[0]

        mejor_score = mejor_objeto.score

        if mejor_objeto.score > 0.5:
            titulo = limpiar_texto(mejor_objeto.name)

    # --------------------------------------------------
    # 2️⃣ WEB DETECTION
    # --------------------------------------------------
    if not titulo:
        web_response = client.web_detection(image=image)
        web = web_response.web_detection

        print("WEB ENTITIES:")
        if web and web.web_entities:
            for e in web.web_entities:
                print(e.description, e.score)

            entidades_validas = [
                e for e in web.web_entities
                if e.description and e.score and e.score > 0.5
            ]

            if entidades_validas:
                entidades_validas.sort(key=lambda x: x.score, reverse=True)
                mejor_entidad = entidades_validas[0]
                titulo = limpiar_texto(mejor_entidad.description)
                mejor_score = mejor_entidad.score

    # --------------------------------------------------
    # 3️⃣ OCR (ÚLTIMO RECURSO)
    # --------------------------------------------------
    if not titulo:
        text_response = client.text_detection(image=image)
        texts = text_response.text_annotations

        if texts:
            texto_detectado = texts[0].description
            lineas = texto_detectado.split("\n")

            lineas_validas = [
                limpiar_texto(l) for l in lineas
                if len(l.strip()) > 3
            ]

            if lineas_validas:
                titulo = lineas_validas[0]

    # --------------------------------------------------
    # 4️⃣ Fallback final
    # --------------------------------------------------
    if not titulo:
        titulo = "Producto no identificado"

    titulo = normalizar_titulo(titulo)

    print("Vision detectó:", titulo)

    # --------------------------------------------------
    # 5️⃣ DECISIÓN OPTIMIZADA GEMINI
    # --------------------------------------------------
    usar_gemini = is_generic_or_low_confidence(titulo, mejor_score)

    if usar_gemini:
        mime_type = "image/jpeg"
        titulo_gemini = gemini_titulo_producto(original_bytes, mime_type)

        print("Gemini detectó:", titulo_gemini)

        if titulo_gemini and titulo_gemini.strip():
            titulo = titulo_gemini.strip()
            used_gemini = 1

    descripcion = generar_descripcion_corta(titulo)

    return titulo, descripcion, used_gemini