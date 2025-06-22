import 'playlist_item.dart';

class Playlist {
  final String name;
  final List<PlaylistItem> items;
  final bool isLooping;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? pin;

  Playlist({
    required this.name,
    required this.items,
    this.isLooping = false,
    this.startTime,
    this.endTime,
    this.pin,
  });

  /// Pozwala stworzyć nową Playlistę na bazie obecnej, z podmianą wybranych pól.
  Playlist copyWith({
    String? name,
    List<PlaylistItem>? items,
    bool? isLooping,
    DateTime? startTime,
    DateTime? endTime,
    String? pin,
  }) {
    return Playlist(
      name: name ?? this.name,
      items: items ?? this.items,
      isLooping: isLooping ?? this.isLooping,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pin: pin,
    );
  }

  /// Serializacja do mapy
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
      'isLooping': isLooping,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'pin': pin,
    };
  }

  /// Tworzy Playlistę z mapy
  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      name: map['name'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => PlaylistItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      isLooping: map['isLooping'] ?? false,
      startTime: map['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
          : null,
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      pin: map['pin'] as String?,
    );
  }
}
