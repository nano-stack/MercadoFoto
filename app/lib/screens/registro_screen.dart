import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/session_service.dart';
import '../services/api_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final nombre = TextEditingController();
  final apellido = TextEditingController();
  final rut = TextEditingController();
  final direccion = TextEditingController();
  final comuna = TextEditingController();
  final ciudad = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController(); // 🔥 NUEVO

  bool esEmailValido(String value) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value);
  }

  bool esPasswordValido(String value) {
    return RegExp(r'^(?=.*[!@#\$%^&*(),.?":{}|<>]).{6,}$').hasMatch(value);
  }

  Future<void> registrar() async {
    /// ✅ VALIDACIONES
    if (!esEmailValido(email.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correo electrónico inválido")),
      );
      return;
    }

    if (!esPasswordValido(password.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La contraseña debe tener al menos 6 caracteres y 1 carácter especial",
          ),
        ),
      );
      return;
    }

    if (nombre.text.isEmpty || apellido.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa nombre y apellido")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/registro"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre.text,
          "apellido": apellido.text,
          "rut": rut.text,
          "email": email.text,
          "password": password.text, // 🔥 NUEVO
          "direccion": direccion.text,
          "comuna": comuna.text,
          "ciudad": ciudad.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final userId = data["user_id"];

        /// 🔥 GUARDAR SESIÓN
        await SessionService.guardarUser(userId);

        /// 🔥 GUARDAR TODOS LOS DATOS (para Mi Cuenta)
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("nombre", nombre.text);
        await prefs.setString("apellido", apellido.text);
        await prefs.setString("email", email.text);
        await prefs.setString("rut", rut.text);
        await prefs.setString("direccion", direccion.text);
        await prefs.setString("comuna", comuna.text);
        await prefs.setString("ciudad", ciudad.text);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cuenta creada correctamente")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al registrar usuario")),
        );
      }
    } catch (e) {
      debugPrint("ERROR REGISTRO: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error de conexión")));
    }
  }

  Widget campo({
    required IconData icono,
    required String label,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icono),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Registro de usuario"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Crea tu cuenta",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ingresa tus datos para comenzar a vender.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            campo(icono: Icons.person, label: "Nombre", controller: nombre),
            campo(
              icono: Icons.person_outline,
              label: "Apellido",
              controller: apellido,
            ),
            campo(
              icono: Icons.email,
              label: "Correo electrónico",
              controller: email,
            ),
            campo(
              icono: Icons.lock,
              label: "Contraseña",
              controller: password,
              obscure: true,
            ),
            campo(icono: Icons.badge, label: "RUT", controller: rut),
            campo(icono: Icons.home, label: "Dirección", controller: direccion),
            campo(
              icono: Icons.location_city,
              label: "Comuna",
              controller: comuna,
            ),
            campo(icono: Icons.map, label: "Ciudad", controller: ciudad),
            const SizedBox(height: 20),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: registrar,
                child: const Text(
                  "Crear cuenta",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
