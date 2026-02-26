from scraper.mercadolibre import buscar_precios_mercadolibre

def obtener_rango_precios(titulo):

    precios = buscar_precios_mercadolibre(titulo)

    if not precios:
        return None

    min_price = min(precios)
    max_price = max(precios)

    return {
        "moneda": "CLP",
        "min": {
            "precio": min_price,
            "tienda": "MercadoLibre"
        },
        "max": {
            "precio": max_price,
            "tienda": "MercadoLibre"
        }
    }
