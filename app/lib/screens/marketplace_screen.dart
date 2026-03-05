import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List publicaciones = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarPublicaciones();
  }

  Future<void> cargarPublicaciones() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/publicaciones"),
      );

      if (response.statusCode == 200) {
        setState(() {
          publicaciones = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marketplace")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : publicaciones.isEmpty
          ? const Center(child: Text("No hay publicaciones"))
          : ListView.builder(
              itemCount: publicaciones.length,
              itemBuilder: (context, index) {
                final item = publicaciones[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        "${ApiService.baseUrl}${item['imagen_url']}",
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['titulo'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(item['descripcion']),
                            const SizedBox(height: 5),
                            Text(
                              "\$${item['precio']}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
