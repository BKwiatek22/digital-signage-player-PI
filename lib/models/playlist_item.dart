import 'package:file_picker/file_picker.dart';

class PlaylistItem {
  final PlatformFile file;
  int durationSeconds; // domyślnie 7 sekund dla zdjęcia

  PlaylistItem({required this.file, this.durationSeconds = 7});
}
