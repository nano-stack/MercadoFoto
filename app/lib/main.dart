import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MercadoFotoApp());
}

class MercadoFotoApp extends StatelessWidget {
  const MercadoFotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

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

                // REGISTRARSE (solo si no está registrado)
                if (!usuarioRegistrado)
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("REGISTRARSE"),
                  ),

                const SizedBox(height: 20),

                // COMPRAR
                ElevatedButton(onPressed: () {}, child: const Text("COMPRAR")),

                const SizedBox(height: 10),

                // VENDER
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

class VenderScreen extends StatefulWidget {
  const VenderScreen({super.key});

  @override
  State<VenderScreen> createState() => _VenderScreenState();
}

class _VenderScreenState extends State<VenderScreen> {
  File? _image;
  String? _resultado;

  Future<void> _abrirCamara() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      setState(() {
        _image = file;
      });

      await _enviarImagen(file);
    }
  }

  Future<void> _enviarImagen(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.53:8000/analizar'), // ⚠️ tu IP real
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      setState(() {
        _resultado =
            "Título: ${jsonData['titulo']}\n\nDescripción: ${jsonData['descripcion']}";
      });
    } else {
      setState(() {
        _resultado = "Error: ${response.statusCode}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Publicar producto")),
      body: Center(
        child: _image == null
            ? ElevatedButton(
                onPressed: _abrirCamara,
                child: const Text("Abrir Cámara"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(_image!, height: 300),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _abrirCamara,
                    child: const Text("Tomar otra foto"),
                  ),
                  if (_resultado != null) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_resultado!, textAlign: TextAlign.center),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
