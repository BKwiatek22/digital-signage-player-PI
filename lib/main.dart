import 'package:flutter/material.dart';
import 'screens/media_library_screen.dart';
import 'screens/playlists_screen.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const DigitalSignageApp());
}

class DigitalSignageApp extends StatelessWidget {
  const DigitalSignageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Signage',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  List<PlatformFile> _mediaFiles = []; // <-- globalna lista multimediów

  void _onFilesChanged(List<PlatformFile> files) {
    setState(() => _mediaFiles = files); // <-- aktualizuj globalnie!
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
        onFilesChanged: _onFilesChanged, // <-- przekazujesz callback!
      ),
      PlaylistsScreen(
        mediaFiles: _mediaFiles, // <-- przekazujesz aktualną listę!
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Wybrane multimedia' : 'Playlisty'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: const Text('Wybrane multimedia'),
              onTap: () => _onDrawerTap(0),
            ),
            ListTile(
              title: const Text('Playlisty'),
              onTap: () => _onDrawerTap(1),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
