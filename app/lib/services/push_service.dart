import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_service.dart';
import 'session_service.dart';

/// Maneja permisos, token FCM y recepción de notificaciones push.
class PushService {
  static final _messaging = FirebaseMessaging.instance;

  /// Inicializar: pedir permiso, obtener token y enviarlo al backend.
  static Future<void> init() async {
    // 1. Solicitar permiso (iOS muestra el diálogo nativo)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // 2. Obtener token FCM
    final token = await _messaging.getToken();
    if (token != null) {
      await _enviarTokenAlBackend(token);
    }

    // 3. Si el token se renueva, reenviarlo
    _messaging.onTokenRefresh.listen(_enviarTokenAlBackend);

    // 4. Manejar notificaciones en foreground (app abierta)
    FirebaseMessaging.onMessage.listen(_manejarMensajeForeground);
  }

  /// Envía el FCM token al backend para que pueda mandar notificaciones.
  static Future<void> _enviarTokenAlBackend(String token) async {
    try {
      final userId = await SessionService.obtenerUser();
      if (userId == null) return;

      await http.post(
        Uri.parse('${ApiService.baseUrl}/usuarios/$userId/fcm_token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
    } catch (e) {
      debugPrint('PushService: error enviando token: $e');
    }
  }

  /// Cuando llega una notificación con la app abierta, mostrar un banner.
  static void _manejarMensajeForeground(RemoteMessage message) {
    debugPrint('Push foreground: ${message.notification?.title}');
    // La UI la manejará con el stream público de abajo
  }

  /// Stream para que la UI pueda mostrar un banner cuando la app está abierta.
  static Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
}
