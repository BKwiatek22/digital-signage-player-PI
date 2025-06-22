import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

import 'screens/media_library_screen.dart';
import 'screens/playlists_screen.dart';
import 'screens/playlist_player_screen.dart';
import 'models/playlist.dart';

void main() {
  runApp(const DigitalSignageApp());
}

class DigitalSignageApp extends StatelessWidget {
  const DigitalSignageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Signage',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1976D2),
        ),
      ),
      home: const AppLauncher(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  bool _loading = true;
  Widget? _startScreen;

  @override
  void initState() {
    super.initState();
    _decideStartScreen();
  }

  Future<void> _decideStartScreen() async {
    List<Playlist> playlists = await _loadPlaylists();
    List<PlatformFile> mediaFiles = [];

    final prefs = await SharedPreferences.getInstance();
    final playlistName = prefs.getString('active_playlist_name');

    if (playlistName != null) {
      Playlist? playlist;
      try {
        playlist = playlists.firstWhere((pl) => pl.name == playlistName);
      } catch (_) {
        playlist = null;
      }
      if (playlist != null) {
        setState(() {
          _loading = false;
          _startScreen = PlaylistPlayerScreen(
            items: playlist!.items,
            pin: playlist!.pin,
          );
        });
        return;
      }
    }
// Brak aktywnej prezentacji – pokazuj menu
    setState(() {
      _loading = false;
      _startScreen = MainApp(mediaFiles: mediaFiles);
    });
  }

  Future<List<Playlist>> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('saved_playlists');
    if (jsonList == null) return [];
    return jsonList.map((e) => Playlist.fromMap(json.decode(e))).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _startScreen!;
  }
}

class MainApp extends StatefulWidget {
  final List<PlatformFile> mediaFiles;
  const MainApp({super.key, this.mediaFiles = const []});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  late List<PlatformFile> _mediaFiles;

  @override
  void initState() {
    super.initState();
    _mediaFiles = widget.mediaFiles;
  }

  void _onFilesChanged(List<PlatformFile> files) {
    setState(() => _mediaFiles = files);
  }

  void _onDrawerTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      MediaLibraryScreen(
        onFilesChanged: _onFilesChanged,
      ),
      PlaylistsScreen(
        mediaFiles: _mediaFiles,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Wybrane multimedia' : 'Playlisty'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF1976D2),
                ),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                )),
            ListTile(
              title: const Text('Multimedia',
                  style: TextStyle(color: Colors.white)),
              onTap: () => _onDrawerTap(0),
            ),
            ListTile(
              title: const Text('Playlisty',
                  style: TextStyle(color: Colors.white)),
              onTap: () => _onDrawerTap(1),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
