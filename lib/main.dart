import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'widgets/thumbnail_widget.dart';

void main() {
  runApp(DigitalSignageApp());
}

class DigitalSignageApp extends StatelessWidget {
  const DigitalSignageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Signage',
      theme: ThemeData.dark(),
      home: MediaGallery(),
    );
  }
}

class MediaGallery extends StatefulWidget {
  const MediaGallery({super.key});

  @override
  _MediaGalleryState createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  final List<File> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaFiles.add(File(pickedFile.path));
      });
    }
  }

  void _deleteFile(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  void _viewFile(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullScreenLoopViewer(mediaFiles: _mediaFiles, startIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Signage')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _mediaFiles.length,
        itemBuilder: (context, index) {
          File file = _mediaFiles[index];
          return GestureDetector(
            onTap: () => _viewFile(index),
            onLongPress: () => _deleteFile(index),
            child: file.path.endsWith('.mp4')
                ? ThumbnailWidget(videoFile: file) // zamiast VideoWidget
                : Image.file(file, fit: BoxFit.cover),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickImage,
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _pickVideo,
            child: const Icon(Icons.videocam),
          ),
        ],
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final File videoFile;
  const VideoWidget({super.key, required this.videoFile});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class FullScreenLoopViewer extends StatefulWidget {
  final List<File> mediaFiles;
  final int startIndex;
  const FullScreenLoopViewer(
      {super.key, required this.mediaFiles, required this.startIndex});

  @override
  _FullScreenLoopViewerState createState() => _FullScreenLoopViewerState();
}

class _FullScreenLoopViewerState extends State<FullScreenLoopViewer> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
    _startLoop();
  }

  void _startLoop() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          currentIndex = (currentIndex + 1) % widget.mediaFiles.length;
        });
        _startLoop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    File file = widget.mediaFiles[currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: file.path.endsWith('.mp4')
            ? VideoWidget(videoFile: file)
            : Image.file(file, fit: BoxFit.contain),
      ),
    );
  }
}
