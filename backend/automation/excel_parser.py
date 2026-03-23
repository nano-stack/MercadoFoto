import pandas as pd


def leer_excel_productos(path):

    df = pd.read_excel(path)

    productos = []

    for _, row in df.iterrows():

        producto = {
            "titulo": row["titulo"],
            "descripcion": row["descripcion"],
            "precio": float(row["precio"]),
            "categoria": row.get("categoria", "otros")
        }

        productos.append(producto)

    return productos