import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/session_service.dart';

class MiCuentaScreen extends StatefulWidget {
  const MiCuentaScreen({super.key});

  @override
  State<MiCuentaScreen> createState() => _MiCuentaScreenState();
}

class _MiCuentaScreenState extends State<MiCuentaScreen> {
  String nombre = "";
  String apellido = "";
  String email = "";
  String rut = "";
  String direccion = "";
  String comuna = "";
  String ciudad = "";

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nombre = prefs.getString("nombre") ?? "";
      apellido = prefs.getString("apellido") ?? "";
      email = prefs.getString("email") ?? "";
      rut = prefs.getString("rut") ?? "";
      direccion = prefs.getString("direccion") ?? "";
      comuna = prefs.getString("comuna") ?? "";
      ciudad = prefs.getString("ciudad") ?? "";
    });
  }

  Widget fila(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> cerrarSesion() async {
    await SessionService.cerrarSesion();

    if (!mounted) return;

    Navigator.pop(context);
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
              /// 🔥 HEADER CON LOGO (CONSISTENTE CON TODA LA APP)
              Row(
                children: [Image.asset('assets/images/logo.png', height: 50)],
              ),

              const SizedBox(height: 20),

              const Text(
                "Mi Cuenta",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// 🔥 DATOS (SCROLLABLE)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      fila("Nombre", nombre),
                      fila("Apellido", apellido),
                      fila("Email", email),
                      fila("RUT", rut),
                      fila("Dirección", direccion),
                      fila("Comuna", comuna),
                      fila("Ciudad", ciudad),
                    ],
                  ),
                ),
              ),

              /// 🔥 BOTÓN CERRAR SESIÓN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: cerrarSesion,
                  child: const Text("Cerrar sesión"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
