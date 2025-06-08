import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _peliculas = [];
  List<String> _categorias = ['Todas'];
  String _categoriaSeleccionada = 'Todas';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  Future<void> _cargarPeliculas() async {
    try {
      final String jsonData = await rootBundle.loadString('assets/data/peliculas3.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonData);
      final List<dynamic> data = jsonMap['peliculas'];

      final Set<String> categoriasSet = {};
      for (var peli in data) {
        List<dynamic> generos = peli['genero'];
        categoriasSet.addAll(generos.map((g) => g.toString()));
      }

      setState(() {
        _peliculas = data;
        _categorias = ['Todas', ...categoriasSet.toList()];
      });
    } catch (e) {
      print("Error al cargar películas: $e");
    }
  }

  void _onBottomTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/profile');
        break;
      case 2:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void _mostrarModalPelicula(BuildContext context, Map<String, dynamic> pelicula) {
    showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  pelicula['imagen'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(pelicula['titulo'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("🎬 Director: ${pelicula['director']}"),
              Text("📅 Año: ${pelicula['anio']}"),
              Text("🎭 Géneros: ${(pelicula['genero'] as List).join(", ")}"),
              Text("⭐ Valoración: ${pelicula['valoracion']}"),
              const SizedBox(height: 12),
              Text(
                pelicula['descripcion'],
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _abrirURL(pelicula['trailer']),
                    icon: const Icon(Icons.play_circle),
                    label: const Text("Ver Tráiler"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.movie),
                    label: const Text("Ver Película"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      );
    },
  );
}
  void _abrirURL(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final peliculasFiltradas = _categoriaSeleccionada == 'Todas'
        ? _peliculas
        : _peliculas.where((p) => (p['genero'] as List).contains(_categoriaSeleccionada)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('CinePlay - $_categoriaSeleccionada'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Catálogo por Género',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            for (final categoria in _categorias)
              ListTile(
                title: Text(categoria),
                onTap: () {
                  setState(() => _categoriaSeleccionada = categoria);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: peliculasFiltradas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: peliculasFiltradas.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final pelicula = peliculasFiltradas[index];
                return GestureDetector(
                  onTap: () => _mostrarModalPelicula(context, pelicula),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.asset(
                              pelicula['imagen'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            pelicula['titulo'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onBottomTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}
