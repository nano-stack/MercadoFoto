import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para autenticación biométrica (Face ID / Touch ID).
///
/// Uso:
///   1. Verificar disponibilidad: `await BiometricService.isAvailable()`
///   2. Verificar si el usuario lo activó: `await BiometricService.isEnabled()`
///   3. Activar/desactivar: `await BiometricService.setEnabled(true)`
///   4. Autenticar: `await BiometricService.authenticate()`
class BiometricService {
  static final _auth = LocalAuthentication();
  static const _prefKey = 'biometric_enabled';

  // ── Disponibilidad ───────────────────────────────────────────────────────

  /// Retorna true si el dispositivo tiene biometría configurada y habilitada.
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;

      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ── Preferencia guardada ─────────────────────────────────────────────────

  /// Retorna true si el usuario activó el inicio con Face ID.
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Activa o desactiva el inicio con Face ID.
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  // ── Autenticación ────────────────────────────────────────────────────────

  /// Muestra el diálogo de Face ID / Touch ID.
  /// Retorna true si la autenticación fue exitosa.
  static Future<bool> authenticate({
    String reason = 'Verifica tu identidad para continuar',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite PIN como fallback
          stickyAuth: true,     // Mantiene el diálogo si el usuario cambia de app
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
