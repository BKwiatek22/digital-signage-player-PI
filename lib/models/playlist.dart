import 'playlist_item.dart';

class Playlist {
  String name;
  List<PlaylistItem> items;
  bool isLooping;
  DateTime? startTime;
  DateTime? endTime;

  Playlist({
    required this.name,
    required this.items,
    this.isLooping = false,
    this.startTime,
    this.endTime,
  });
}
