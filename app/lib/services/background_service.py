from rembg import remove
from PIL import Image
import io


def quitar_fondo(image_bytes: bytes) -> bytes:
    """
    Recibe imagen en bytes.
    Qita el fondo usando rembg.
    Coloca fondo blanco.
    Devuelve imagen final en formato PNG (bytes).
    """

    # 1. Quitar fondo (queda PNG con transparencia)
    output_bytes = remove(image_bytes)

    # 2. Abrir como imagen PIL
    image = Image.open(io.BytesIO(output_bytes)).convert("RGBA")

    # 3. Crear fondo blanco
    fondo_blanco = Image.new("RGBA", image.size, (255, 255, 255, 255))

    # 4. Combinar imagen con fondo blanco
    imagen_final = Image.alpha_composite(fondo_blanco, image)

    # 5. Convertir a RGB (sin canal alfa)
    imagen_final = imagen_final.convert("RGB")

    # 6. Guardar en memoria como PNG
    buffer = io.BytesIO()
    imagen_final.save(buffer, format="PNG")

    return buffer.getvalue()