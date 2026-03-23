import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../services/session_service.dart';
import 'mis_publicaciones_screen.dart';

class ConfirmacionScreen extends StatefulWidget {
  final String data;
  final File imagen;

  const ConfirmacionScreen({
    super.key,
    required this.data,
    required this.imagen,
  });

  @override
  State<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends State<ConfirmacionScreen> {
  late TextEditingController titulo;
  late TextEditingController descripcion;
  final precio = TextEditingController();

  @override
  void initState() {
    super.initState();

    final jsonData = jsonDecode(widget.data);

    titulo = TextEditingController(text: jsonData["titulo"]);
    descripcion = TextEditingController(text: jsonData["descripcion"]);
  }

  Future<void> publicar() async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiService.baseUrl}/publicar"),
      );

      /// CAMPOS
      request.fields["titulo"] = titulo.text.trim();
      request.fields["descripcion"] = descripcion.text.trim();
      request.fields["precio"] = precio.text.trim().isEmpty
          ? "0"
          : precio.text.trim();

      /// IMAGEN
      request.files.add(
        await http.MultipartFile.fromPath("file", widget.imagen.path),
      );

      /// SESION (guest o user)
      final session = await SessionService.obtenerSesion();

      if (session["user_id"] != null) {
        request.fields["user_id"] = session["user_id"].toString();
      }

      if (session["guest_id"] != null) {
        request.fields["guest_id"] = session["guest_id"].toString();
      }

      /// ENVIAR
      final response = await request.send();

      final respStr = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        debugPrint("ERROR PUBLICAR: $respStr");
        throw Exception("Error al publicar");
      }

      if (!mounted) return;

      /// 🔥 IR A MIS PUBLICACIONES (NO marketplace)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MisPublicacionesScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("ERROR PUBLICAR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al publicar el producto")),
      );
    }
  }

  Widget campo(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar producto")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [
            Image.file(widget.imagen, height: 200),

            const SizedBox(height: 20),

            campo("Título", titulo),
            campo("Descripción", descripcion),
            campo("Precio", precio),

            const SizedBox(height: 20),

            /// 🔥 BOTÓN ACTUALIZADO
            ElevatedButton(onPressed: publicar, child: const Text("Publicar")),
          ],
        ),
      ),
    );
  }
}
