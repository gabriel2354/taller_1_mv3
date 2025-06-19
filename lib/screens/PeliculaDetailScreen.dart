import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class PeliculaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pelicula;

  const PeliculaDetailScreen({super.key, required this.pelicula});

  @override
  State<PeliculaDetailScreen> createState() => _PeliculaDetailScreenState();
}

class _PeliculaDetailScreenState extends State<PeliculaDetailScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.pelicula['video_url'] ?? '';

    _videoController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() => _isVideoInitialized = true);
        _videoController.setLooping(true);
        _videoController.play();
        _startAutoHideTimer();
      }).catchError((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Error al cargar el video")),
        );
      });
  }

  void _startAutoHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startAutoHideTimer();
  }

  void _seekBy(Duration offset) {
    final pos = _videoController.value.position + offset;
    _videoController.seekTo(pos);
  }

  void _enterFullScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenPlayer(controller: _videoController),
      ),
    );
    _startAutoHideTimer();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positivas = widget.pelicula['opiniones']?['opiniones_positivas']?['detalles'] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.pelicula['titulo']),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _isVideoInitialized ? _enterFullScreen : null,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            if (_isVideoInitialized)
              AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: GestureDetector(
                  onTap: _toggleControls,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_videoController),
                      if (_showControls)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black45,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () => _seekBy(const Duration(seconds: -10)),
                                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 40),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _videoController.value.isPlaying
                                              ? _videoController.pause()
                                              : _videoController.play();
                                        });
                                        _startAutoHideTimer();
                                      },
                                      icon: Icon(
                                        _videoController.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _seekBy(const Duration(seconds: 10)),
                                      icon: const Icon(Icons.forward_10, color: Colors.white, size: 40),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                VideoProgressIndicator(
                                  _videoController,
                                  allowScrubbing: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  colors: const VideoProgressColors(
                                    playedColor: Colors.red,
                                    bufferedColor: Colors.grey,
                                    backgroundColor: Colors.white30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.red))),

            const SizedBox(height: 20),

            Text(
              "${widget.pelicula['anio']} • ${(widget.pelicula['genero'] as List).join(', ')}",
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            Text(widget.pelicula['descripcion'],
                style: const TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.justify),

            const SizedBox(height: 20),
            const Divider(color: Colors.white24),

            const Text("Opiniones", style: TextStyle(fontSize: 18, color: Colors.white)),
            ...positivas.map<Widget>((op) => ListTile(
                  leading: const Icon(Icons.thumb_up, color: Colors.green),
                  title: Text(op['opinion'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "Usuario: ${op['detalles_usuario']['usuario']} - Puntuación: ${op['detalles_usuario']['puntuacion']}",
                    style: const TextStyle(color: Colors.white60),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class FullScreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenPlayer({super.key, required this.controller});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller),
        ),
      ),
    );
  }
}
