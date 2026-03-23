import imaplib
import email
from email.header import decode_header
import os

EMAIL = "publicaciones@mercadofoto.cl"
PASSWORD = "TU_PASSWORD"
IMAP_SERVER = "imap.gmail.com"


def obtener_emails_publicaciones():

    mail = imaplib.IMAP4_SSL(IMAP_SERVER)
    mail.login(EMAIL, PASSWORD)
    mail.select("inbox")

    status, messages = mail.search(None, '(SUBJECT "PUBLICACIONES MERCADO FOTO")')

    email_ids = messages[0].split()

    archivos = []

    for email_id in email_ids:

        res, msg = mail.fetch(email_id, "(RFC822)")
        raw_email = msg[0][1]

        mensaje = email.message_from_bytes(raw_email)

        for part in mensaje.walk():

            if part.get_content_disposition() == "attachment":

                filename = part.get_filename()

                if filename.endswith(".xlsx"):

                    filepath = os.path.join("uploads", filename)

                    with open(filepath, "wb") as f:
                        f.write(part.get_payload(decode=True))

                    archivos.append(filepath)

    return archivos