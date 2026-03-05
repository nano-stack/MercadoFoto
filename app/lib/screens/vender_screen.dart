import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'confirmacion_screen.dart';

class VenderScreen extends StatefulWidget {
  const VenderScreen({super.key});

  @override
  State<VenderScreen> createState() => _VenderScreenState();
}

class _VenderScreenState extends State<VenderScreen> {
  bool _loading = false;

  Future<void> _seleccionarImagen(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    File file = File(pickedFile.path);

    setState(() {
      _loading = true;
    });

    try {
      final jsonData = await ApiService.enviarImagen(file);

      final String titulo = jsonData['titulo'] ?? '';
      final String descripcion = jsonData['descripcion'] ?? '';
      final String imagenUrl = jsonData['imagen_url'] ?? '';

      setState(() {
        _loading = false;
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmacionScreen(
            titulo: titulo,
            descripcion: descripcion,
            imagenUrl: imagenUrl,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al analizar la imagen")),
      );
    }
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tomar Foto"),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Elegir desde Galería"),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Publicar producto")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _mostrarOpciones,
                child: const Text("Seleccionar Imagen"),
              ),
      ),
    );
  }
}
