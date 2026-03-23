from automation.email_reader import obtener_emails_publicaciones
from automation.excel_parser import leer_excel_productos
from automation.publicar_productos import publicar


def run():

    archivos = obtener_emails_publicaciones()

    for archivo in archivos:

        productos = leer_excel_productos(archivo)

        publicar(productos)

        print("Productos publicados:", len(productos))


if __name__ == "__main__":
    run()