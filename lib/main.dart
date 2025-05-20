import 'package:flutter/material.dart';

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
  // Docelowo tu będą playlisty i logika aplikacji

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Signage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Tu dodamy przejście do ekranu ustawień
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_play),
              title: const Text('Playlisty'),
              onTap: () {
                // Tu przejdziemy do ekranu playlist
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ustawienia'),
              onTap: () {
                // Tu przejdziemy do ustawień
              },
            ),
            ListTile(
              leading: const Icon(Icons.tv),
              title: const Text('Tryb wyświetlania'),
              onTap: () {
                // Tu przejdziemy do trybu wyświetlania
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tu będzie lista multimediów',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Dodaj pliki do playlisty'),
              onPressed: () {
                // Tu dodamy wybieranie plików
              },
            ),
          ],
        ),
      ),
    );
  }
}
