import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/playlist_item.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final Playlist playlist;
  final List<PlaylistItem>
      availableItems; // Wszystkie pliki do wyboru (zasobnik)

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
    _itemsInPlaylist = List.from(widget.playlist.items);
  }

  // Dodaj element do playlisty z zasobnika
  void _addItemToPlaylist(PlaylistItem item) {
    setState(() {
      if (!_itemsInPlaylist.any((i) => i.file.path == item.file.path)) {
        _itemsInPlaylist.add(item);
      }
    });
  }

  // Usuń element z playlisty
  void _removeItemFromPlaylist(int index) {
    setState(() {
      _itemsInPlaylist.removeAt(index);
    });
  }

  // Zapisywanie zmian do modelu playlisty (opcjonalnie na końcu)
  void _savePlaylistChanges() {
    widget.playlist.items
      ..clear()
      ..addAll(_itemsInPlaylist);
    Navigator.of(context)
        .pop(widget.playlist); // Możesz przekazać playlistę do powrotu
  }

  // Wybór plików do dodania
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final itemsToShow = widget.availableItems
            .where((item) =>
                !_itemsInPlaylist.any((i) => i.file.path == item.file.path))
            .toList();

        if (itemsToShow.isEmpty) {
          return const AlertDialog(
            content: Text('Brak dostępnych plików do dodania.'),
          );
        }

        return SimpleDialog(
          title: const Text('Dodaj multimedia do playlisty'),
          children: itemsToShow.map((item) {
            return ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(item.file.name),
              onTap: () {
                Navigator.pop(context);
                _addItemToPlaylist(item);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlista: ${widget.playlist.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Zapisz',
            onPressed: _savePlaylistChanges,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Dodaj plik'),
                onPressed: _showAddItemDialog,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _itemsInPlaylist.isEmpty
                ? const Center(child: Text('Brak plików w playliście.'))
                : ReorderableListView.builder(
                    itemCount: _itemsInPlaylist.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _itemsInPlaylist.removeAt(oldIndex);
                        _itemsInPlaylist.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _itemsInPlaylist[index];
                      return ListTile(
                        key: ValueKey(item.file.path),
                        leading: const Icon(Icons.drag_handle),
                        title: Text(item.file.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Usuń',
                          onPressed: () => _removeItemFromPlaylist(index),
                        ),
                        // Możesz dodać obsługę czasu trwania
                        // subtitle: Text('Czas: ${item.durationSeconds}s'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
