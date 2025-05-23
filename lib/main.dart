import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const DigitalSignageApp());
}

class DigitalSignageApp extends StatelessWidget {
  const DigitalSignageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projekt inżynierski BK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<PlatformFile> _selectedFiles = [];
  final String _prefsKey = 'saved_file_paths';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  // Ładowanie ścieżek plików z pamięci
  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedPaths = prefs.getStringList(_prefsKey);
    if (savedPaths != null) {
      setState(() {
        _selectedFiles = savedPaths
            .where((path) => File(path).existsSync())
            .map((path) => PlatformFile(
                  path: path,
                  name: path.split(Platform.pathSeparator).last,
                  size: File(path).lengthSync(),
                  // Możesz dodać typ pliku (np. extension) jeśli potrzebujesz
                ))
            .toList();
      });
    }
  }

  // Zapis ścieżek do plików
  Future<void> _saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = _selectedFiles
        .where((file) => file.path != null)
        .map((file) => file.path!)
        .toList();
    await prefs.setStringList(_prefsKey, paths);
  }

  // Dodawanie wielu plików
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        // Dodaj tylko nowe pliki (unikaj duplikatów po ścieżce)
        for (var newFile in result.files) {
          if (!_selectedFiles.any((f) => f.path == newFile.path)) {
            _selectedFiles.add(newFile);
          }
        }
      });
      await _saveFiles(); // Zapisz zmiany po dodaniu
    }
  }

  // Usuwanie pliku z listy
  void _removeFile(int index) async {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    await _saveFiles();
  }

  Widget _buildThumbnail(PlatformFile file) {
    final ext = file.extension?.toLowerCase();

    // Miniatury dla obrazów – bez zmian
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      if (file.path != null) {
        return Image.file(
          File(file.path!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        );
      }
    }

    // Miniatura wideo
    if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext)) {
      return FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: file.path!,
          imageFormat: ImageFormat.PNG,
          maxWidth: 256, // większa szerokość – ostrzejsza miniaturka!
          quality: 100, // 100% jakości
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            );
          } else {
            return const SizedBox(
              width: 90,
              height: 90,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
        },
      );
    }

    // Inne pliki – domyślna ikona
    return const Icon(Icons.insert_drive_file, size: 48, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Signage'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: const Text('Wybrane multimedia'),
              onTap: () {
                Navigator.pop(context);
                // Przełącz na ekran główny (możesz dodać zmienną _currentScreen do kontrolowania ekranu)
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_play),
              title: const Text('Playlisty'),
              onTap: () {
                Navigator.pop(context);
                // Przełącz na ekran Playlist (przygotuj nowy ekran)
              },
            ),
            // Możesz dodać kolejne opcje
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wybrane multimedia:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _selectedFiles.isEmpty
                  ? const Text('Nie wybrano żadnych plików.')
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // liczba kolumn w gridzie
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final shouldDelete =
                                            await Navigator.of(context)
                                                .push<bool>(
                                          MaterialPageRoute(
                                            builder: (_) => MediaPreviewScreen(
                                              file: file,
                                            ),
                                          ),
                                        );
                                        if (shouldDelete == true) {
                                          setState(() {
                                            _selectedFiles.removeWhere(
                                                (f) => f.path == file.path);
                                          });
                                          await _saveFiles();
                                        }
                                      },
                                      child: _buildThumbnail(file),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeFile(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.red, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Text(
                                file.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Dodaj pliki do playlisty'),
                onPressed: _pickFiles,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaPreviewScreen extends StatefulWidget {
  final PlatformFile file;

  const MediaPreviewScreen({Key? key, required this.file}) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final ext = widget.file.extension?.toLowerCase();
    if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext)) {
      _controller = VideoPlayerController.file(File(widget.file.path!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = widget.file.extension?.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final isVideo = ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Zamykamy ekran i zwracamy true (prośba o usunięcie)
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: isImage && widget.file.path != null
            ? InteractiveViewer(
                child: Image.file(File(widget.file.path!)),
              )
            : isVideo && _controller != null && _controller!.value.isInitialized
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                      VideoProgressIndicator(_controller!,
                          allowScrubbing: true),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_controller!.value.isPlaying) {
                                  _controller!.pause();
                                } else {
                                  _controller!.play();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : const Text(
                    'Nieobsługiwany typ pliku lub nie można odtworzyć.',
                    style: TextStyle(color: Colors.white),
                  ),
      ),
    );
  }
}
