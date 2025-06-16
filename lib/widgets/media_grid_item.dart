import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/media_thumbnail.dart';

/// Widget jednego pliku w gridzie biblioteki multimediów
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            FutureBuilder<Widget>(
              future: buildMediaThumbnail(file, size: 80),
              builder: (context, snapshot) {
                final thumbnail =
                    snapshot.data ?? const SizedBox(width: 80, height: 80);
                return Center(child: thumbnail);
              },
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                tooltip: 'Usuń',
                onPressed: onRemove,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Text(
                  file.name,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
