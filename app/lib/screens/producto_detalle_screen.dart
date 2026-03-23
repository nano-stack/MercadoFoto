import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'registro_screen.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final Map producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  bool campoEstado = false;
  bool campoCodigo = false;
  bool campoSKU = false;
  bool campoStock = false;

  final estadoController = TextEditingController();
  final codigoController = TextEditingController();
  final skuController = TextEditingController();
  final stockController = TextEditingController();

  Widget campoExpandible({
    required String titulo,
    required bool abierto,
    required VoidCallback toggle,
    TextEditingController? controller,
  }) {
    return Column(
      children: [
        /// HEADER DEL CAMPO
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(abierto ? Icons.remove : Icons.add),
              onPressed: toggle,
            ),
          ],
        ),

        /// CAMPO
        if (abierto)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagen = "${ApiService.baseUrl}${widget.producto["imagen_url"]}";
    final titulo = widget.producto["titulo"] ?? "";
    final descripcion = widget.producto["descripcion"] ?? "";
    final precio = widget.producto["precio"] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: const Text("Detalle del producto")),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGEN
            Image.network(
              imagen,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITULO
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// DESCRIPCION
                  Text(
                    descripcion,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),

                  const SizedBox(height: 12),

                  /// PRECIO
                  Text(
                    "\$$precio",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Divider(),

                  const SizedBox(height: 10),

                  /// INFORMACION ADICIONAL
                  const Text(
                    "Información adicional",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// NUEVO / USADO
                  campoExpandible(
                    titulo: "NUEVO / USADO",
                    abierto: campoEstado,
                    controller: estadoController,
                    toggle: () {
                      setState(() {
                        campoEstado = !campoEstado;
                      });
                    },
                  ),

                  /// CODIGO UNIVERSAL
                  campoExpandible(
                    titulo: "CODIGO UNIVERSAL",
                    abierto: campoCodigo,
                    controller: codigoController,
                    toggle: () {
                      setState(() {
                        campoCodigo = !campoCodigo;
                      });
                    },
                  ),

                  /// SKU
                  campoExpandible(
                    titulo: "SKU",
                    abierto: campoSKU,
                    controller: skuController,
                    toggle: () {
                      setState(() {
                        campoSKU = !campoSKU;
                      });
                    },
                  ),

                  /// STOCK
                  campoExpandible(
                    titulo: "STOCK",
                    abierto: campoStock,
                    controller: stockController,
                    toggle: () {
                      setState(() {
                        campoStock = !campoStock;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  /// BOTON PUBLICAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistroScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Registrarse",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
