from google.cloud import vision
import re
from services.description_service import generar_descripcion_corta
import difflib


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
def detectar_producto(original_bytes, image_sin_fondo):

    client = vision.ImageAnnotatorClient()

    image_original = vision.Image(content=original_bytes)
    image_clean = vision.Image(content=image_sin_fondo)

    titulo = None

    # OCR en imagen ORIGINAL
    text_response = client.text_detection(image=image_original)
    texts = text_response.text_annotations

    if texts:
        texto_detectado = texts[0].description
        lineas = texto_detectado.split("\n")

        lineas_validas = [
            limpiar_texto(l) for l in lineas
            if len(l.strip()) > 3
        ]

        if len(lineas_validas) >= 2:
            posible_titulo = " ".join(lineas_validas[:2])
        elif len(lineas_validas) == 1:
            posible_titulo = lineas_validas[0]
        else:
            posible_titulo = None

        #Filtro de calidad
        if posible_titulo and len(posible_titulo.split()) >=2:
            titulo = posible_titulo

    # Web detection en imagen ORIGINAL
    web_response = client.web_detection(image=image_original)
    web = web_response.web_detection

    if web.web_entities:
        entidades_validas = [
            e for e in web.web_entities
            if e.description and e.score and e.score > 0.6
        ]

        if entidades_validas:
            entidades_validas.sort(key=lambda x: x.score, reverse=True)
            mejor_entidad = limpiar_texto(entidades_validas[0].description)

            if titulo:
                similitud = difflib.SequenceMatcher(
                    None,
                    titulo.lower(),
                    mejor_entidad.lower()
                ).ratio()

                # 🔥 Si OCR es parecido pero mal escrito → corregir
                if similitud > 0.75:
                    titulo = mejor_entidad
            else:
                titulo = mejor_entidad

    # Object detection en imagen SIN fondo (último recurso)
    if not titulo:
        obj_response = client.object_localization(image=image_clean)
        objetos = obj_response.localized_object_annotations
        if objetos:
            titulo = limpiar_texto(objetos[0].name)

    if not titulo:
        titulo = "Producto no identificado"

    descripcion = generar_descripcion_corta(titulo)

    return titulo, descripcion