import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import '../models/playlist_item.dart';
import '../models/playlist.dart';
import '../main.dart';

class PlaylistPlayerScreen extends StatefulWidget {
  final List<PlaylistItem> items;
  final String? pin;

  const PlaylistPlayerScreen({Key? key, required this.items, this.pin})
      : super(key: key);

  @override
  State<PlaylistPlayerScreen> createState() => _PlaylistPlayerScreenState();
}

class _PlaylistPlayerScreenState extends State<PlaylistPlayerScreen> {
  int _currentIndex = 0;
  Timer? _timer;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _startCurrent();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  void _startCurrent() async {
    _timer?.cancel();
    _videoController?.dispose();
    final item = widget.items[_currentIndex];
    final ext = item.file.extension?.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final isVideo = ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext);

    if (isImage && item.file.path != null) {
      _timer = Timer(Duration(seconds: item.durationSeconds ?? 5), _next);
      setState(() {});
    } else if (isVideo && item.file.path != null) {
      _videoController = VideoPlayerController.file(File(item.file.path!));
      await _videoController!.initialize();
      _videoController!.play();
      _videoController!.addListener(() {
        if (_videoController!.value.position >=
            _videoController!.value.duration) {
          _next();
        }
      });
      setState(() {});
    }
  }

  void _next() {
    setState(() {
      if (_currentIndex < widget.items.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
    _startCurrent();
  }

  Future<void> _tryExit() async {
    // Jeśli PIN nie jest ustawiony – od razu wyjście
    if (widget.pin == null || widget.pin!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_playlist_name');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppLauncher()),
        (route) => false,
      );
      return;
    }
    final controller = TextEditingController();
    final correct = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Wyjście z odtwarzania"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Wpisz PIN'),
          obscureText: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context, controller.text == widget.pin);
            },
          ),
        ],
      ),
    );
    if (correct == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_playlist_name');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppLauncher()),
        (route) => false,
      );
    }
    // Jeśli zły PIN – nic nie rób, zostaje na prezentacji
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_currentIndex];
    final ext = item.file.extension?.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final isVideo = ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPress: _tryExit,
        onDoubleTap: _tryExit,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: isImage && item.file.path != null
              ? SizedBox.expand(
                  child: Image.file(
                    File(item.file.path!),
                    fit: BoxFit.contain,
                  ),
                )
              : isVideo &&
                      _videoController != null &&
                      _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
