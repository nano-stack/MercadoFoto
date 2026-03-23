import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  // --------------------------------------------------
  // 🔐 GUARDAR SESIÓN COMPLETA
  // --------------------------------------------------
  static Future<void> guardarSesion({
    required int userId,
    required String nombre,
    String? email,
    String? rut,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("user_id", userId);
    await prefs.setString("nombre", nombre);

    if (email != null) await prefs.setString("email", email);
    if (rut != null) await prefs.setString("rut", rut);
  }

  // --------------------------------------------------
  // 👤 USER
  // --------------------------------------------------
  static Future<void> guardarUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("user_id", userId);
  }

  static Future<int?> obtenerUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  // --------------------------------------------------
  // 🧑‍💻 NOMBRE (CLAVE PARA UI)
  // --------------------------------------------------
  static Future<String?> obtenerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("nombre");
  }

  // --------------------------------------------------
  // 👻 GUEST
  // --------------------------------------------------
  static Future<void> guardarGuest(String guestId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("guest_id", guestId);
  }

  static Future<String?> obtenerGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("guest_id");
  }

  // --------------------------------------------------
  // 🚪 CERRAR SESIÓN
  // --------------------------------------------------
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("user_id");
    await prefs.remove("nombre");
    await prefs.remove("email");
    await prefs.remove("rut");

    // 🔥 IMPORTANTE: mantener guest
    // para no romper navegación
  }

  // --------------------------------------------------
  // 📦 OBTENER TODO
  // --------------------------------------------------
  static Future<Map<String, dynamic>> obtenerSesion() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "user_id": prefs.getInt("user_id"),
      "nombre": prefs.getString("nombre"),
      "guest_id": prefs.getString("guest_id"),
    };
  }
}
