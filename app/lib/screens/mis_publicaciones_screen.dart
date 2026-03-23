import 'package:flutter/material.dart';
import 'registro_screen.dart';
import 'home_screen.dart';

class MisPublicacionesScreen extends StatelessWidget {
  const MisPublicacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔥 HEADER (LOGO + TITULO)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  /// LOGO (CLICK → HOME)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: Image.asset("assets/images/logo.png", height: 40),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "Mis publicaciones",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// 📦 LISTADO (por ahora placeholder)
            Expanded(
              child: Center(
                child: Text(
                  "Aquí verás tus productos publicados",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),

            /// 🔥 BOTÓN REGISTRARSE (IMPORTANTE)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegistroScreen()),
                    );
                  },
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
