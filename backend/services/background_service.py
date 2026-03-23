from rembg import remove
from PIL import Image
import io

def quitar_fondo(image_bytes):

    input_image = Image.open(io.BytesIO(image_bytes)).convert("RGBA")

    # remover fondo
    output_image = remove(input_image)

    # crear fondo blanco
    fondo_blanco = Image.new("RGBA", output_image.size, (255, 255, 255, 255))

    # pegar producto encima
    fondo_blanco.paste(output_image, mask=output_image)

    # guardar resultado
    buffer = io.BytesIO()
    fondo_blanco.convert("RGB").save(buffer, format="PNG")

    return buffer.getvalue()