import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  final PlatformFile file;

  const MediaPreviewScreen({Key? key, required this.file}) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final ext = widget.file.extension?.toLowerCase();
    if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext)) {
      _controller = VideoPlayerController.file(File(widget.file.path!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = widget.file.extension?.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final isVideo = ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: isImage && widget.file.path != null
            ? InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: SizedBox.expand(
                  child: Image.file(
                    File(widget.file.path!),
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : isVideo && _controller != null && _controller!.value.isInitialized
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final aspectRatio = _controller!.value.aspectRatio;
                            double width = constraints.maxWidth;
                            double height = width / aspectRatio;
                            if (height > constraints.maxHeight) {
                              height = constraints.maxHeight;
                              width = height * aspectRatio;
                            }
                            return Center(
                              child: SizedBox(
                                width: width,
                                height: height,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    width: _controller!.value.size.width,
                                    height: _controller!.value.size.height,
                                    child: VideoPlayer(_controller!),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      VideoProgressIndicator(_controller!,
                          allowScrubbing: true),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_controller!.value.isPlaying) {
                                  _controller!.pause();
                                } else {
                                  _controller!.play();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : const Text(
                    'Nieobsługiwany typ pliku lub nie można odtworzyć.',
                    style: TextStyle(color: Colors.white),
                  ),
      ),
    );
  }
}
