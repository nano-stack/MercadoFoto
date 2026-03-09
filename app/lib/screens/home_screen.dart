import 'package:flutter/material.dart';
import 'vender_screen.dart';
import 'marketplace_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final bool usuarioRegistrado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// CONTENIDO PRINCIPAL
            Column(
              children: [
                /// ESPACIO PARA HEADER (LOGO + BUSCADOR)
                const SizedBox(height: 110),

                /// BANNER IA
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/banner_publicidad.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// MARKETPLACE
                const Expanded(child: MarketplaceScreen()),

                /// ESPACIO PARA BOTONES INFERIORES
                const SizedBox(height: 90),
              ],
            ),

            /// HEADER SUPERIOR
            Positioned(
              top: 10,
              left: 15,
              right: 15,
              child: Row(
                children: [
                  /// LOGO
                  Image.asset('assets/images/logo.png', height: 60),

                  const SizedBox(width: 10),

                  /// BUSCADOR
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Buscar productos...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// BOTÓN REGISTRARSE (ANTES ESTABA ABAJO)
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("Registrarse"),
                  ),
                ],
              ),
            ),

            /// BOTONES INFERIORES
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// INGRESAR
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Ingresar"),
                    ),

                    const SizedBox(width: 15),

                    /// VENDER (ANTES ESTABA ARRIBA)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VenderScreen(),
                          ),
                        );
                      },
                      child: const Text("Vender"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
