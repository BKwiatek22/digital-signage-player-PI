import 'package:flutter/material.dart';
import '../models/playlist.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  List<Playlist> playlists = [];

  // Dodaj nową playlistę (pokaż dialog z nazwą)
  Future<void> _addPlaylistDialog() async {
    String playlistName = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nowa playlista'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nazwa playlisty'),
            onChanged: (value) => playlistName = value,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Dodaj'),
              onPressed: () => Navigator.of(context).pop(playlistName),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        playlists.add(
          Playlist(
            name: result.trim(),
            items: [],
          ),
        );
      });
    }
  }

  // Usuwanie playlisty z listy
  void _removePlaylist(int index) {
    setState(() {
      playlists.removeAt(index);
    });
  }

  // Edycja nazwy playlisty (na razie przez dialog)
  Future<void> _editPlaylistName(int index) async {
    String newName = playlists[index].name;
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zmień nazwę playlisty'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nowa nazwa'),
            controller: TextEditingController(text: playlists[index].name),
            onChanged: (value) => newName = value,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Zmień'),
              onPressed: () => Navigator.of(context).pop(newName),
            ),
          ],
        );
      },
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        playlists[index].name = result.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlisty'),
      ),
      body: playlists.isEmpty
          ? const Center(child: Text('Brak utworzonych playlist'))
          : ListView.separated(
              itemCount: playlists.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.items.length} plików'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        tooltip: 'Zmień nazwę',
                        onPressed: () => _editPlaylistName(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Usuń',
                        onPressed: () => _removePlaylist(index),
                      ),
                    ],
                  ),
                  onTap: () {
                    // W przyszłości: szczegóły/edycja playlisty
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nowa playlista'),
        onPressed: _addPlaylistDialog,
      ),
    );
  }
}
