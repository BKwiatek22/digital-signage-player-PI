import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailWidget extends StatelessWidget {
  final File videoFile;

  const ThumbnailWidget({super.key, required this.videoFile});

  Future<String?> _generateThumbnail() async {
    final tempDir = await getTemporaryDirectory();
    return await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: '${tempDir.path}/${videoFile.path.hashCode}.jpg',
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      quality: 75,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          return Image.file(
            File(snapshot.data!),
            fit: BoxFit.cover,
          );
        } else {
          return Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
