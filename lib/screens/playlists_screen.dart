import 'package:flutter/material.dart';
import '../models/playlist.dart';
import 'playlist_details_screen.dart';
import 'playlist_player_screen.dart';
import 'package:file_picker/file_picker.dart';
import '../models/playlist_item.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistsScreen extends StatefulWidget {
  final List<PlatformFile> mediaFiles;

  const PlaylistsScreen({Key? key, required this.mediaFiles}) : super(key: key);

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  List<Playlist> playlists = [];
  static const _prefsPlaylistsKey = 'saved_playlists';
  @override
  void initState() {
    super.initState();
    loadPlaylists().then((list) {
      setState(() => playlists = list);
    });
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = playlists.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList(_prefsPlaylistsKey, jsonList);
  }

  Future<List<Playlist>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsPlaylistsKey);
    if (jsonList == null) return [];
    return jsonList.map((e) => Playlist.fromMap(json.decode(e))).toList();
  }

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
      await savePlaylists(playlists);
    }
  }

  void _removePlaylist(int index) {
    setState(() {
      playlists.removeAt(index);
    });
    savePlaylists(playlists);
  }

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
      final updatedPlaylist = playlists[index].copyWith(name: result.trim());
      setState(() {
        playlists[index] = updatedPlaylist;
      });
      await savePlaylists(playlists);
    }
  }

  Future<String?> _showPinDialog(
      BuildContext context, String? currentPin) async {
    final controller = TextEditingController(text: currentPin ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentPin == null || currentPin.isEmpty
            ? 'Ustaw PIN dla tej playlisty'
            : 'Zmień lub usuń PIN playlisty'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'PIN (pozostaw puste, by usunąć)',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Zapisz'),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //  title: const Text('Playlisty'),
      //),
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${playlist.items.length} plików'),
                      if (playlist.pin != null && playlist.pin!.isNotEmpty)
                        const Text("Zabezpieczona PIN-em",
                            style: TextStyle(
                                color: Colors.blueGrey, fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.lock,
                          color:
                              playlist.pin != null && playlist.pin!.isNotEmpty
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                        tooltip:
                            playlist.pin != null && playlist.pin!.isNotEmpty
                                ? "Zmień/usuń PIN"
                                : "Ustaw PIN",
                        onPressed: () async {
                          final newPin =
                              await _showPinDialog(context, playlist.pin);
                          if (newPin != null) {
                            setState(() {
                              playlists[index] = playlist.copyWith(
                                  pin: (newPin == null || newPin.isEmpty)
                                      ? null
                                      : newPin);
                            });
                            await savePlaylists(playlists);
                          }
                        },
                      ),
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
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green),
                        tooltip: "Odtwórz playlistę",
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              'active_playlist_name', playlists[index].name);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlaylistPlayerScreen(
                                items: playlists[index].items,
                                pin: playlists[index].pin,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    print(
                        "Liczba multimediów dostępnych do dodania: ${widget.mediaFiles.length}");
                    List<PlaylistItem> availableItems = widget.mediaFiles
                        .map((file) => PlaylistItem(file: file))
                        .toList();

                    final updatedPlaylist =
                        await Navigator.of(context).push<Playlist>(
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailsScreen(
                          playlist: playlists[index],
                          availableItems: availableItems,
                        ),
                      ),
                    );
                    if (updatedPlaylist != null) {
                      setState(() {
                        playlists[index] = updatedPlaylist;
                      });
                      await savePlaylists(playlists);
                    }
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
