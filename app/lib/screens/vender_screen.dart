import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import 'confirmacion_screen.dart';

class VenderScreen extends StatefulWidget {
  const VenderScreen({super.key});

  @override
  State<VenderScreen> createState() => _VenderScreenState();
}

class _VenderScreenState extends State<VenderScreen> {
  final ImagePicker picker = ImagePicker();
  bool loading = false;

  Future<void> analizarImagen(File imagen) async {
    setState(() {
      loading = true;
    });

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiService.baseUrl}/analizar"),
    );

    request.files.add(await http.MultipartFile.fromPath("file", imagen.path));

    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    setState(() {
      loading = false;
    });

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmacionScreen(data: respStr, imagen: imagen),
        ),
      );
    }
  }

  Future<void> abrirCamara() async {
    final XFile? foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (foto != null) {
      analizarImagen(File(foto.path));
    }
  }

  Future<void> abrirGaleria() async {
    final XFile? foto = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (foto != null) {
      analizarImagen(File(foto.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vender producto")),

      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Selecciona una imagen",
                    style: TextStyle(fontSize: 22),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton.icon(
                    onPressed: abrirCamara,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Abrir cámara"),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: abrirGaleria,
                    icon: const Icon(Icons.photo),
                    label: const Text("Abrir galería"),
                  ),
                ],
              ),
      ),
    );
  }
}
