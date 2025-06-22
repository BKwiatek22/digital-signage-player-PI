import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/playlist.dart';
import '../models/playlist_item.dart';
import '../utils/media_thumbnail.dart';
import '../screens/playlist_player_screen.dart';

bool isImageFile(PlatformFile file) {
  final ext = file.extension?.toLowerCase();
  return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
}

class PlaylistDetailsScreen extends StatefulWidget {
  final Playlist playlist;
  final List<PlaylistItem> availableItems;

  const PlaylistDetailsScreen({
    Key? key,
    required this.playlist,
    required this.availableItems,
  }) : super(key: key);

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  late List<PlaylistItem> _itemsInPlaylist;

  @override
  void initState() {
    super.initState();
    _itemsInPlaylist = List<PlaylistItem>.from(widget.playlist.items);
  }

  void _addItemToPlaylist(PlaylistItem item) {
    setState(() {
      if (!_itemsInPlaylist.any((i) => i.file.path == item.file.path)) {
        _itemsInPlaylist.add(item);
      }
    });
  }

  void _removeItemFromPlaylist(int index) {
    setState(() {
      _itemsInPlaylist.removeAt(index);
    });
  }

  void _showAddItemDialog() {
    final itemsToShow = widget.availableItems
        .where((item) =>
            !_itemsInPlaylist.any((i) => i.file.path == item.file.path))
        .toList();

    if (itemsToShow.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text('Brak dostępnych plików do dodania.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj multimedia do playlisty'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView.builder(
            itemCount: itemsToShow.length,
            itemBuilder: (context, index) {
              final item = itemsToShow[index];
              return FutureBuilder<Widget>(
                future: buildMediaThumbnail(item.file, size: 44),
                builder: (context, snapshot) {
                  final thumbnail =
                      snapshot.data ?? const SizedBox(width: 44, height: 44);
                  return ListTile(
                    leading: thumbnail,
                    title: Text(item.file.name),
                    onTap: () {
                      Navigator.pop(context);
                      _addItemToPlaylist(item);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showDurationDialog(int index) async {
    final current = _itemsInPlaylist[index].durationSeconds ?? 5;
    final controller = TextEditingController(text: current.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Czas trwania (sekundy)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Czas trwania',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Zapisz'),
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      setState(() {
        _itemsInPlaylist[index] =
            _itemsInPlaylist[index].copyWith(durationSeconds: result);
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _itemsInPlaylist.removeAt(oldIndex);
      _itemsInPlaylist.insert(newIndex, item);
    });
  }

  Future<void> _showMassDurationDialog() async {
    final controller = TextEditingController(text: '5');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Czas trwania dla wszystkich zdjęć (sekundy)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Czas trwania',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Zapisz'),
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      setState(() {
        _itemsInPlaylist = _itemsInPlaylist.map((item) {
          if (isImageFile(item.file)) {
            return item.copyWith(durationSeconds: result);
          }
          return item;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.playlist.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer, color: Colors.white),
            tooltip: 'Ustaw czas dla wszystkich zdjęć',
            onPressed: _showMassDurationDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Dodaj plik',
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ReorderableListView.builder(
          itemCount: _itemsInPlaylist.length,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            final item = _itemsInPlaylist[index];
            return FutureBuilder<Widget>(
              key: ValueKey(item.file.path),
              future: buildMediaThumbnail(item.file, size: 44),
              builder: (context, snapshot) {
                final thumbnail =
                    snapshot.data ?? const SizedBox(width: 44, height: 44);
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.drag_handle),
                      const SizedBox(width: 8),
                      thumbnail,
                    ],
                  ),
                  title: Text(item.file.name),
                  subtitle:
                      isImageFile(item.file) && item.durationSeconds != null
                          ? Text('Czas: ${item.durationSeconds} s')
                          : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isImageFile(item.file))
                        IconButton(
                          icon: const Icon(Icons.timer, color: Colors.blue),
                          tooltip: 'Ustaw czas trwania',
                          onPressed: () => _showDurationDialog(index),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Usuń',
                        onPressed: () => _removeItemFromPlaylist(index),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.save),
        label: const Text('Zapisz zmiany'),
        onPressed: () {
          Navigator.pop(
            context,
            widget.playlist.copyWith(items: _itemsInPlaylist),
          );
        },
      ),
    );
  }
}
