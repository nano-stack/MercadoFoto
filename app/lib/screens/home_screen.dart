import 'package:flutter/material.dart';
import 'vender_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final bool usuarioRegistrado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO
                Image.asset('assets/images/logo.png', height: 150),

                const SizedBox(height: 30),

                // Estado usuario
                Text(
                  usuarioRegistrado
                      ? "Usuario identificado"
                      : "Usuario no identificado",
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                if (!usuarioRegistrado)
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("REGISTRARSE"),
                  ),

                const SizedBox(height: 20),

                ElevatedButton(onPressed: () {}, child: const Text("COMPRAR")),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VenderScreen(),
                      ),
                    );
                  },
                  child: const Text("VENDER"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
