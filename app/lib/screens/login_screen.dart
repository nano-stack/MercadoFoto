import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.text, "password": password.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await SessionService.guardarUser(data["user_id"]);

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Credenciales incorrectas")),
        );
      }
    } catch (e) {
      debugPrint("ERROR LOGIN: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error de conexión")));
    }
  }

  Widget campo(String label, TextEditingController controller, bool obscure) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
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

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 LOGO ARRIBA IZQUIERDA
              Image.asset('assets/images/logo.png', height: 50),

              const SizedBox(height: 30),

              const Text(
                "Ingresar",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Accede a tu cuenta",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 30),

              campo("Correo electrónico", email, false),
              campo("Contraseña", password, true),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: login,
                  child: const Text("Ingresar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
