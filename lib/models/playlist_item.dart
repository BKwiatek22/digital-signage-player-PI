import 'package:file_picker/file_picker.dart';

class PlaylistItem {
  final PlatformFile file;
  final int? durationSeconds;

  PlaylistItem({required this.file, this.durationSeconds = 7});

  PlaylistItem copyWith({
    PlatformFile? file,
    int? durationSeconds,
  }) {
    return PlaylistItem(
      file: file ?? this.file,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': file.path,
      'name': file.name,
      'size': file.size,
      'durationSeconds': durationSeconds,
    };
  }

  factory PlaylistItem.fromMap(Map<String, dynamic> map) {
    return PlaylistItem(
      file: PlatformFile(
        path: map['path'],
        name: map['name'],
        size: map['size'],
      ),
      durationSeconds: map['durationSeconds'] ?? 7,
    );
  }
}
