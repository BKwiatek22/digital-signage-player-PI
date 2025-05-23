import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaGridItem extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const MediaGridItem({
    Key? key,
    required this.file,
    required this.onRemove,
    required this.onTap,
  }) : super(key: key);

  Widget _buildThumbnail(BuildContext context) {
    final ext = file.extension?.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      if (file.path != null) {
        return Image.file(
          File(file.path!),
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        );
      }
    }
    if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext)) {
      return FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: file.path!,
          imageFormat: ImageFormat.PNG,
          maxWidth: 256,
          quality: 100,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            );
          } else {
            return const SizedBox(
              width: 90,
              height: 90,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
        },
      );
    }
    return const Icon(Icons.insert_drive_file, size: 48, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // <--- przekazany callback
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: _buildThumbnail(context),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              file.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
