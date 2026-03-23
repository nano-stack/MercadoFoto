import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/session_service.dart';
import 'producto_detalle_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List publicaciones = [];
  bool loading = true;

  bool usuarioRegistrado = false;
  String nombreUsuario = "";
  String apellidoUsuario = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await cargarUsuario();
    await cargarPublicaciones();
  }

  Future<void> cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt("user_id");
    final nombre = prefs.getString("nombre");
    final apellido = prefs.getString("apellido");

    if (userId != null) {
      usuarioRegistrado = true;
      nombreUsuario = nombre ?? "";
      apellidoUsuario = apellido ?? "";
    }
  }

  Future<void> cargarPublicaciones() async {
    try {
      final session = await SessionService.obtenerSesion();
      final userId = session["user_id"];

      http.Response response;

      /// 🔥 USUARIO REGISTRADO → SOLO SUS PRODUCTOS
      if (userId != null) {
        response = await http.get(
          Uri.parse("${ApiService.baseUrl}/vendedor/$userId"),
        );

        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          publicaciones = data["publicaciones"] ?? [];
          loading = false;
        });
      } else {
        /// 🔥 INVITADO → MARKETPLACE GENERAL
        response = await http.get(
          Uri.parse("${ApiService.baseUrl}/publicaciones"),
        );

        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          publicaciones = data;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        publicaciones = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// LOADING
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 HEADER LIMPIO (SIN LOGO DUPLICADO)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 40, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuarioRegistrado ? "Mis publicaciones" : "Marketplace",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usuarioRegistrado
                      ? "$nombreUsuario $apellidoUsuario"
                      : "Usuario invitado",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          /// 🔥 SIN PRODUCTOS
          if (publicaciones.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "Aquí verás tus productos publicados",
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ),

          /// 🔥 GRID PRODUCTOS
          if (publicaciones.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.60,
                ),

                itemCount: publicaciones.length,

                itemBuilder: (context, index) {
                  final item = publicaciones[index];

                  final imagenUrl = item['imagen_url'] ?? "";
                  final titulo = item['titulo'] ?? "";
                  final descripcion = item['descripcion'] ?? "";
                  final precio = item['precio'] ?? 0;
                  final vendedor =
                      item['nombre_vendedor'] ?? "Usuario invitado";

                  final userId = item['user_id'];
                  final bool registrado = userId != null;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductoDetalleScreen(producto: item),
                        ),
                      );
                    },

                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔥 IMAGEN
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              "${ApiService.baseUrl}$imagenUrl",
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// TITULO
                                Text(
                                  titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                /// DESCRIPCION
                                Text(
                                  descripcion,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                /// PRECIO
                                Text(
                                  "\$${precio.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// VENDEDOR
                                Row(
                                  children: [
                                    const Icon(Icons.storefront, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Vendido por $vendedor",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// ESTADO
                                Row(
                                  children: [
                                    Icon(
                                      registrado
                                          ? Icons.verified_user
                                          : Icons.person_outline,
                                      size: 14,
                                      color: registrado
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      registrado ? "Registrado" : "Invitado",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: registrado
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
