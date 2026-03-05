import re
from typing import Optional


_CONNECTOR_RE = re.compile(r"\b(de|del|en|y|para|con)\b", re.IGNORECASE)

def is_generic_or_low_confidence(label: str, score: Optional[float]):
    if not label:
        return True

    words = label.strip().split()

    # Si score bajo → dudoso
    if score is not None and score < 0.65:
        return True

    # Si es frase larga → probablemente categoría
    if len(words) > 2:
        return True

    # Si contiene conectores típicos de categorías
    if _CONNECTOR_RE.search(label):
        return True

    return False