import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../services/session_service.dart';

import 'vender_screen.dart' as vender;
import 'marketplace_screen.dart';
import 'registro_screen.dart';
import 'mi_cuenta_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? userId;
  String nombreUsuario = "Usuario invitado";

  @override
  void initState() {
    super.initState();
    inicializarHome();
  }

  Future<void> inicializarHome() async {
    await iniciarSesion();
    await cargarUsuario();
  }

  /// SESIÓN GUEST
  Future<void> iniciarSesion() async {
    final usuarioRegistrado = await SessionService.obtenerUser();
    if (usuarioRegistrado != null) return;

    final guest = await SessionService.obtenerGuest();
    if (guest != null && guest.toString().isNotEmpty) return;

    try {
      final response = await http.get(Uri.parse("${ApiService.baseUrl}/guest"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final guestId = data["guest_id"]?.toString();

        if (guestId != null && guestId.isNotEmpty) {
          await SessionService.guardarGuest(guestId);
        }
      }
    } catch (e) {
      debugPrint("Error en iniciarSesion(): $e");
    }
  }

  /// CARGAR USUARIO
  Future<void> cargarUsuario() async {
    final id = await SessionService.obtenerUser();
    final nombre = await SessionService.obtenerNombre();

    if (!mounted) return;

    setState(() {
      userId = id;
      nombreUsuario = nombre ?? "Usuario invitado";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Stack(
          children: [
            /// SCROLL
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 110),

                  /// BANNER
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: AssetImage(
                          "assets/images/banner_publicidad.jpg",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// MARKETPLACE
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const MarketplaceScreen(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            /// HEADER FIJO
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

                  /// USUARIO / REGISTRO
                  userId == null
                      ? OutlinedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistroScreen(),
                              ),
                            );

                            await cargarUsuario();
                          },
                          child: const Text("Registrarse"),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MiCuentaScreen(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.person),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  nombreUsuario,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),

            /// FOOTER FIJO
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
                    /// LOGIN / LOGOUT
                    userId == null
                        ? ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );

                              await cargarUsuario();
                            },
                            child: const Text("Ingresar"),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              await SessionService.cerrarSesion();

                              if (!mounted) return;

                              /// 🔥 SOLUCIÓN REAL
                              await inicializarHome();
                            },
                            child: const Text("Cerrar sesión"),
                          ),

                    const SizedBox(width: 15),

                    /// VENDER
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const vender.VenderScreen(),
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
