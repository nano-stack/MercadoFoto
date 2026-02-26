import requests
from bs4 import BeautifulSoup
import re

HEADERS = {
    "User-Agent": "Mozilla/5.0"
}

def buscar_precios_mercadolibre(query):
    url = f"https://listado.mercadolibre.cl/{query.replace(' ', '-')}"
    response = requests.get(url, headers=HEADERS)

    soup = BeautifulSoup(response.text, "lxml")

    precios = []

    resultados = soup.find_all("span", class_="andes-money-amount__fraction")

    for r in resultados[:10]:
        try:
            precio = int(r.text.replace(".", ""))
            precios.append(precio)
        except:
            continue

    return precios
