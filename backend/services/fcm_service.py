"""
fcm_service.py
==============
Envío de notificaciones push via Firebase Cloud Messaging (FCM HTTP v1).
Usa la variable de entorno FIREBASE_SERVICE_ACCOUNT_B64 (JSON de cuenta
de servicio codificado en base64) disponible en Render.
"""

import base64
import json
import os
import logging

logger = logging.getLogger(__name__)

_fcm_app = None


def _init_firebase():
    global _fcm_app
    if _fcm_app is not None:
        return _fcm_app

    b64 = os.environ.get("FIREBASE_SERVICE_ACCOUNT_B64")
    if not b64:
        logger.warning("FCM: FIREBASE_SERVICE_ACCOUNT_B64 no configurada — push desactivado")
        return None

    try:
        import firebase_admin
        from firebase_admin import credentials

        cred_dict = json.loads(base64.b64decode(b64).decode("utf-8"))
        cred = credentials.Certificate(cred_dict)

        # Evitar doble inicialización
        if not firebase_admin._apps:
            _fcm_app = firebase_admin.initialize_app(cred)
        else:
            _fcm_app = firebase_admin.get_app()

        logger.info("FCM: Firebase Admin inicializado OK")
        return _fcm_app
    except Exception as e:
        logger.error(f"FCM: Error al inicializar Firebase Admin: {e}")
        return None


def enviar_push(fcm_token: str, titulo: str, cuerpo: str, data: dict = None) -> bool:
    """
    Envía una notificación push al dispositivo con el token dado.
    Retorna True si se envió correctamente, False si falló.
    """
    app = _init_firebase()
    if app is None:
        return False

    try:
        from firebase_admin import messaging

        msg = messaging.Message(
            token=fcm_token,
            notification=messaging.Notification(
                title=titulo,
                body=cuerpo,
            ),
            data={k: str(v) for k, v in (data or {}).items()},
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        sound="default",
                        badge=1,
                    )
                )
            ),
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    sound="default",
                ),
            ),
        )

        messaging.send(msg)
        logger.info(f"FCM: Notificación enviada a token {fcm_token[:20]}...")
        return True

    except Exception as e:
        logger.error(f"FCM: Error enviando notificación: {e}")
        return False
