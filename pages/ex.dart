import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VideoCapturePage extends StatefulWidget {
  const VideoCapturePage({super.key});

  @override
  State<VideoCapturePage> createState() => _VideoCapturePageState();
}

class _VideoCapturePageState extends State<VideoCapturePage> {
  CameraController? _controller;
  late List<CameraDescription> cameras;
  bool _isRecording = false;
  VideoPlayerController? _videoPlayerController;
  bool _showCamera = true;
  //String? _savedVideoPath;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("No cameras found");
        return;
      }
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startVideoRecording();
    setState(() => _isRecording = true);
    print('Started recording');
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    final XFile video = await _controller!.stopVideoRecording();
    final bytes = await video.readAsBytes();

    setState(() {
      _isRecording = false;
    });

    print('Stopped recording, video size: ${bytes.length} bytes');
    _uploadVideo(bytes);
  }

  Future<void> _uploadVideo(Uint8List bytes) async {
    final uri = Uri.parse(
      'http://192.168.23.73:5000/upload',
    ); // Update IP if needed
    print('Uploading video to $uri');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes('video', bytes, filename: 'video.mp4'),
      );

      final response = await request.send();
      print('Server response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final returnedBytes = await response.stream.toBytes();
        print('Received video size: ${returnedBytes.length} bytes');

        final filePath = await saveVideo(
          returnedBytes,
        ); // Save to local storage

        _videoPlayerController = VideoPlayerController.file(File(filePath));

        await _videoPlayerController!.initialize();
        print('🎬 Video player initialized');
        setState(() => _showCamera = false);
      } else {
        print('❌ Server error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error uploading video: $e');
    }
  }

  // Save video to device storage
  Future<String> saveVideo(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saved_video.mp4');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Video Capture')),
      body: Column(
        children: [
          Expanded(
            child:
                _showCamera
                    ? CameraPreview(_controller!)
                    : (_videoPlayerController != null
                        ? AspectRatio(
                          aspectRatio:
                              _videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController!),
                        )
                        : const Center(child: Text('No video available'))),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_showCamera) ...[
                  ElevatedButton(
                    onPressed: _isRecording ? null : _startRecording,
                    child: const Text('Start'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isRecording ? _stopRecording : null,
                    child: const Text('Stop'),
                  ),
                ],
                if (!_showCamera && _videoPlayerController != null) ...[
                  ElevatedButton(
                    onPressed: () => _videoPlayerController!.play(),
                    child: const Text('Play'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showCamera = true;
                        _videoPlayerController?.dispose();
                        _videoPlayerController = null;
                      });
                    },
                    child: const Text('Back to Camera'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
