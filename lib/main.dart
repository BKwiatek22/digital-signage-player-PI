import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
  // Lista wybranych plików
  List<PlatformFile> _selectedFiles = [];

  // Funkcja wybierania plików (wiele plików na raz)
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any, // obsługujemy każdy format (obrazy, wideo, inne)
    );
    if (result != null) {
      setState(() {
        // Dodaje nowe pliki do listy (nie usuwa poprzednich)
        _selectedFiles.addAll(result.files.where((newFile) =>
            !_selectedFiles.any((oldFile) => oldFile.path == newFile.path)));
      });
    }
  }

  // Miniaturka pliku – obraz jeśli zdjęcie, ikona jeśli inny typ
  Widget _buildThumbnail(PlatformFile file) {
    final ext = file.extension?.toLowerCase();
    // Obsługa obrazów
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
    // Obsługa filmów
    if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext)) {
      return const Icon(Icons.movie, size: 48, color: Colors.deepPurple);
    }
    // Domyślna ikona
    return const Icon(Icons.insert_drive_file, size: 48, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Signage'),
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
            // Lista wybranych plików z miniaturkami
            Expanded(
              child: _selectedFiles.isEmpty
                  ? const Text('Nie wybrano żadnych plików.')
                  : ListView.separated(
                      itemCount: _selectedFiles.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return ListTile(
                          leading: _buildThumbnail(file),
                          title: Text(file.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          // Usuwanie pliku z listy (opcjonalnie)
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedFiles.removeAt(index);
                              });
                            },
                          ),
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
