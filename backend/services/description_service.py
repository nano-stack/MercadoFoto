import google.generativeai as genai
import os

genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

def generar_descripcion_corta(titulo):

    prompt = f"""
Genera una descripción clara y directa del siguiente producto.

Producto: {titulo}

Reglas:
- Máximo 60 caracteres
- Sin sentimentalismo
- Sin frases comerciales
- Sin emojis
- Solo descripción técnica precisa
- No repitas el título literalmente
- Responde solo con la descripción
"""

    model = genai.GenerativeModel("gemini-2.5-flash")
    response = model.generate_content(prompt)

    descripcion = response.text.strip()

    # Seguridad extra: limitar longitud
    return descripcion[:60]
