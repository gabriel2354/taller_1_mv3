import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'PeliculaDetailScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  List<dynamic> _peliculas = [];
  List<String> _categorias = ['Todas'];
  String _categoriaSeleccionada = 'Todas';
  String _busqueda = '';
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
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            bool mostrarTrailer = false;
            VideoPlayerController? _videoController;

            return StatefulBuilder(builder: (context, setModalState) {
              return SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        mostrarTrailer
                            ? FutureBuilder(
                                future: (() {
                                  _videoController = VideoPlayerController.network(pelicula['trailer']);
                                  return _videoController!.initialize();
                                })(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    _videoController!.play();
                                    return AspectRatio(
                                      aspectRatio: _videoController!.value.aspectRatio,
                                      child: VideoPlayer(_videoController!),
                                    );
                                  } else {
                                    return const SizedBox(
                                      height: 240,
                                      child: Center(
                                        child: CircularProgressIndicator(color: Colors.deepPurple),
                                      ),
                                    );
                                  }
                                },
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  pelicula['imagen'],
                                  height: 240,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pelicula['titulo'],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: (pelicula['genero'] as List)
                          .map((g) => Chip(
                                label: Text(g, style: const TextStyle(color: Colors.white)),
                                backgroundColor: Colors.grey[800],
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    Text("🎬 Director: ${pelicula['director']}", style: const TextStyle(color: Colors.white70)),
                    Text("📅 Año: ${pelicula['anio']}", style: const TextStyle(color: Colors.white70)),
                    Text("⭐ Valoración: ${pelicula['valoracion']}", style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    Text(
                      pelicula['descripcion'],
                      textAlign: TextAlign.justify,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PeliculaDetailScreen(pelicula: pelicula),
                              ),
                            );
                          },
                          icon: const Icon(Icons.movie_creation_outlined),
                          label: const Text("Ver Película"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 235, 234, 237)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setModalState(() => mostrarTrailer = true);
                          },
                          icon: const Icon(Icons.play_circle_fill),
                          label: const Text(" Ver Tráiler"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 235, 234, 240)),
                        ),
                      ],
                    ),
                    if (mostrarTrailer)
                      TextButton(
                        onPressed: () {
                          _videoController?.pause();
                          _videoController?.dispose();
                          setModalState(() => mostrarTrailer = false);
                        },
                        child: const Text("Cerrar Tráiler", style: TextStyle(color: Colors.white70)),
                      ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _videoController?.pause();
                        _videoController?.dispose();
                        Navigator.pop(context);
                      },
                      child: const Text("Cerrar", style: TextStyle(fontSize: 16, color: Colors.white60)),
                    )
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final peliculasFiltradas = _peliculas.where((p) {
      final titulo = (p['titulo'] as String).toLowerCase();
      final coincideBusqueda = titulo.contains(_busqueda.toLowerCase());
      final coincideCategoria = _categoriaSeleccionada == 'Todas' ||
          (p['genero'] as List).contains(_categoriaSeleccionada);
      return coincideBusqueda && coincideCategoria;
    }).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 67, 65, 65),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: TextField(
          onChanged: (valor) => setState(() => _busqueda = valor),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Buscar película...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 141, 137, 137),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/welcome.jpeg'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? user?.email ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Catálogo por Género',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _categorias.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white12),
                itemBuilder: (context, index) {
                  final categoria = _categorias[index];
                  final icono = _iconoPorCategoria(categoria);
                  return ListTile(
                    leading: Icon(icono, color: Colors.deepPurple),
                    title: Text(categoria, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      setState(() => _categoriaSeleccionada = categoria);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: peliculasFiltradas.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
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
                    color: const Color.fromARGB(255, 34, 33, 33),
                    elevation: 6,
                    shadowColor: Colors.deepPurple,
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
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        onTap: _onBottomTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }

  IconData _iconoPorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'acción':
        return Icons.local_fire_department;
      case 'drama':
        return Icons.theater_comedy;
      case 'romance':
        return Icons.favorite;
      case 'comedia':
        return Icons.emoji_emotions;
      case 'aventura':
        return Icons.explore;
      case 'crimen':
        return Icons.gavel;
      case 'musical':
        return Icons.music_note;
      case 'superhéroes':
        return Icons.shield;
      case 'thriller':
        return Icons.flash_on;
      case 'fantasía':
        return Icons.auto_awesome;
      case 'ciencia ficción':
        return Icons.science;
      default:
        return Icons.category;
    }
  }
}
