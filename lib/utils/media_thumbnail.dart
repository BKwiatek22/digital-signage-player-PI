import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Cache miniatur (w pamięci, na czas życia aplikacji)
final Map<String, Widget> _thumbnailCache = {};

Future<Widget> buildMediaThumbnail(PlatformFile file,
    {double size = 44}) async {
  if (_thumbnailCache.containsKey(file.path)) {
    return _thumbnailCache[file.path]!;
  }
  try {
    final ext = file.extension?.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final isVideo = ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext);

    if (isImage && file.path != null) {
      final img = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(file.path!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: size.toInt(),
          cacheHeight: size.toInt(),
        ),
      );
      _thumbnailCache[file.path!] = img;
      return img;
    } else if (isVideo && file.path != null) {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: file.path!,
        imageFormat: ImageFormat.PNG,
        quality: 100,
        maxWidth: 128,
        maxHeight: 128,
      );
      if (uint8list != null) {
        final vid = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            uint8list,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
        _thumbnailCache[file.path!] = vid;
        return vid;
      }
    }
  } catch (_) {
    // ignore
  }
  // Zwraca domyślną ikonę jeśli nie rozpoznano lub wystąpił błąd
  final icon = Icon(Icons.insert_drive_file, size: size);
  _thumbnailCache[file.path ?? ""] = icon;
  return icon;
}
