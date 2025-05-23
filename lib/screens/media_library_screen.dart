import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/media_grid_item.dart';
import 'media_preview_screen.dart';

class MediaLibraryScreen extends StatefulWidget {
  final void Function(List<PlatformFile>) onFilesChanged;

  const MediaLibraryScreen({
    Key? key,
    required this.onFilesChanged,
  }) : super(key: key);

  @override
  State<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> {
  List<PlatformFile> _selectedFiles = [];
  static const _prefsKey = 'saved_file_paths';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  // Wczytuje zapisane ścieżki plików z pamięci
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
                  size: File(path).existsSync() ? File(path).lengthSync() : 0,
                ))
            .toList();
      });
      widget.onFilesChanged(
          _selectedFiles); // <-- Informuje aplikację o początkowym stanie listy plików
    }
  }

  // Zapisuje listę ścieżek plików do pamięci
  Future<void> _saveFiles(List<PlatformFile> files) async {
    final prefs = await SharedPreferences.getInstance();
    final paths = files
        .where((file) => file.path != null)
        .map((file) => file.path!)
        .toList();
    await prefs.setStringList(_prefsKey, paths);
  }

  // Dodaje nowe pliki do listy oraz aktualizuje stan globalny
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        for (var newFile in result.files) {
          if (!_selectedFiles.any((f) => f.path == newFile.path)) {
            _selectedFiles.add(newFile);
          }
        }
      });
      widget.onFilesChanged(
          _selectedFiles); // <-- Informuje aplikację o zmianie listy plików po dodaniu
      await _saveFiles(_selectedFiles);
    }
  }

  // Usuwa plik z listy oraz aktualizuje stan globalny
  void _removeFile(int index) async {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesChanged(
        _selectedFiles); // <-- Informuje aplikację o zmianie listy plików po usunięciu
    await _saveFiles(_selectedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wybrane multimedia:', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedFiles.isEmpty
                ? const Text('Nie wybrano żadnych plików.')
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      return MediaGridItem(
                        file: file,
                        onRemove: () => _removeFile(index),
                        onTap: () async {
                          final shouldDelete =
                              await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => MediaPreviewScreen(file: file),
                            ),
                          );
                          if (shouldDelete == true) {
                            _removeFile(index);
                          }
                        },
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
    );
  }
}
