from google.cloud import translate_v3 as translate

PROJECT_ID = "gen-lang-client-0075779061"


def traducir_a_es(texto: str) -> str:
    """
    Traduce texto a español usando Cloud Translation API v3.
    Usa el mismo service account que ya usas para Vision.
    """
    if not texto or not texto.strip():
        return texto

    client = translate.TranslationServiceClient()
    parent = f"projects/{PROJECT_ID}/locations/global"

    response = client.translate_text(
        request={
            "parent": parent,
            "contents": [texto],
            "mime_type": "text/plain",
            "target_language_code": "es",
        }
    )

    return response.translations[0].translated_text