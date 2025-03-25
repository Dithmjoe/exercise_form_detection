import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _videoPlayerController;
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    _loadSavedVideo();
  }

  Future<void> _loadSavedVideo() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/saved_video.mp4';
    final file = File(filePath);

    if (await file.exists()) {
      setState(() {
        _videoPath = filePath;
        _videoPlayerController = VideoPlayerController.file(File(filePath))
          ..initialize().then((_) {
            setState(() {});
          });
      });
    } else {
      print("No saved video found.");
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Video')),
      body: Center(
        child:
            _videoPath != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.contain, // Ensures no overflow
                        child: SizedBox(
                          width: _videoPlayerController!.value.size.width,
                          height: _videoPlayerController!.value.size.height,
                          child: VideoPlayer(_videoPlayerController!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_videoPlayerController!.value.isPlaying) {
                            _videoPlayerController!.pause();
                          } else {
                            _videoPlayerController!.play();
                          }
                        });
                      },
                      child: Text(
                        _videoPlayerController!.value.isPlaying
                            ? 'Pause'
                            : 'Play',
                      ),
                    ),
                  ],
                )
                : const Text('No saved video found'),
      ),
    );
  }
}
