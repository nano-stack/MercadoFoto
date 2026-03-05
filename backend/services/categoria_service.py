import json
from typing import Optional
from google import genai
from google.genai import types
from database.categorias import get_or_create_categoria

MODEL = "gemini-3-flash-preview"

_SYSTEM_CAT = (
    "Eres un clasificador de categorías de marketplace.\n"
    "Devuelve la categoría jerárquica estructurada del producto.\n"
    "Formato obligatorio: Nivel1 > Nivel2 > Nivel3 > Nivel4\n"
    "Máximo 4 niveles.\n"
    "Sin explicación.\n"
)

_USER_CAT = 'Responde SOLO en JSON válido: {"categoria":"Nivel1 > Nivel2 > Nivel3 > Nivel4"}'


def clasificar_categoria(titulo: str) -> Optional[int]:
    client = genai.Client()

    resp = client.models.generate_content(
        model=MODEL,
        contents=[f"Producto: {titulo}", _USER_CAT],
        config=types.GenerateContentConfig(
            system_instruction=_SYSTEM_CAT,
            temperature=0
        ),
    )

    raw = (resp.text or "").strip()

    try:
        data = json.loads(raw)
        categoria_path = data.get("categoria")
    except:
        return None

    if not categoria_path:
        return None

    niveles = [n.strip() for n in categoria_path.split(">")]
    parent_id = None
    nivel = 1

    for nombre in niveles:
        parent_id = get_or_create_categoria(nombre, parent_id, nivel)
        nivel += 1

    return parent_id  # id del último nivel