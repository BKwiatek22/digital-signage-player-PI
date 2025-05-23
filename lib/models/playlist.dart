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

  // --- SERIALIZACJA DO MAPY ---
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items.map((e) => e.toMap()).toList(),
      'isLooping': isLooping,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
    };
  }

  // --- DESERIALIZACJA Z MAPY ---
  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      name: map['name'] ?? '',
      items: map['items'] != null
          ? List<PlaylistItem>.from(
              (map['items'] as List).map((e) => PlaylistItem.fromMap(e)))
          : [],
      isLooping: map['isLooping'] ?? false,
      startTime: map['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
          : null,
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
    );
  }
}
