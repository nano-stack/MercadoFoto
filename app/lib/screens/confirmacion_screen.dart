import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'marketplace_screen.dart';

class ConfirmacionScreen extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final String imagenUrl;

  const ConfirmacionScreen({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
  });

  @override
  State<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends State<ConfirmacionScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  final TextEditingController _precioController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo);
    _descripcionController = TextEditingController(text: widget.descripcion);
  }

  Future<void> _publicar() async {
    if (_precioController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Debes ingresar un precio")));
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await ApiService.publicarProducto(
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        precio: _precioController.text,
        imagenUrl: widget.imagenUrl,
      );

      setState(() {
        _loading = false;
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MarketplaceScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al publicar producto")),
      );
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String imagenCompleta = "${ApiService.baseUrl}${widget.imagenUrl}";

    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar publicación")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(imagenCompleta, height: 250),
            const SizedBox(height: 20),

            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Precio",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _publicar,
                      child: const Text("PUBLICAR"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
