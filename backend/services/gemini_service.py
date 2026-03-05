# backend/services/gemini_service.py
import os
import json
import re
from typing import Optional

from google import genai
from google.genai import types

MODEL = os.getenv("GEMINI_VISION_MODEL", "gemini-3-flash-preview")

_SYSTEM = (
    "Eres un clasificador de productos para un marketplace.\n"
    "Identifica el objeto físico principal de la foto.\n"
    "Reglas estrictas:\n"
    "1) Ignora TODO texto visible (no uses OCR para decidir marca o modelo).\n"
    "2) Si la MARCA es claramente reconocible por diseño (logo visible o forma icónica), "
    "inclúyela después del objeto.\n"
    "3) No inventes modelo ni versión.\n"
    "4) Máximo 2 palabras: <Objeto> o <Objeto Marca>.\n"
    "5) Español, sin explicación.\n"
)

_USER = 'Responde SOLO en JSON válido: {"titulo":"<MAXIMO_2_PALABRAS>"}'


def _extract_json_title(text: str) -> Optional[str]:
    if not text:
        return None

    # intenta parse directo
    try:
        data = json.loads(text)
        t = (data.get("titulo") or "").strip()
        return t or None
    except Exception:
        pass

    # fallback: encontrar el primer JSON en el texto
    m = re.search(r"\{.*\}", text, flags=re.DOTALL)
    if not m:
        return None
    try:
        data = json.loads(m.group(0))
        t = (data.get("titulo") or "").strip()
        return t or None
    except Exception:
        return None



def gemini_titulo_producto(image_bytes: bytes, mime_type: str) -> Optional[str]:
    """
    Devuelve <Objeto> o <Objeto Marca> en español.
    Máximo 2 palabras.
    Requiere env var: GEMINI_API_KEY
    """
    client = genai.Client()  # Usa GEMINI_API_KEY del entorno

    resp = client.models.generate_content(
        model=MODEL,
        contents=[
            types.Part.from_bytes(data=image_bytes, mime_type=mime_type),
            _USER,
        ],
        config=types.GenerateContentConfig(
            system_instruction=_SYSTEM,
            temperature=0,
        ),
    )

    raw = (resp.text or "").strip()
    titulo = _extract_json_title(raw)

    if not titulo:
        return None

    # Limpieza básica
    titulo = titulo.strip()

    # Limitar a máximo 2 palabras
    palabras = titulo.split()
    titulo = " ".join(palabras[:2])

    # Capitalizar correctamente (Ratón Apple)
    titulo = titulo.title()

    return titulo