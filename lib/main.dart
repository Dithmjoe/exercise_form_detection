import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // Add this dependency for image processing

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Video App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Video App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExerciseScreen()),
                );
              },
              child: Text('Exercise'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SessionHistoryScreen()),
                );
              },
              child: Text('Session History'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseScreen extends StatefulWidget {
  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    // Initialize the camera controller
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _cameraController.initialize();
    
    // Make sure that the camera is initialized before using it
    await _initializeControllerFuture;
    setState(() {}); // Rebuild to reflect initialization state
  }

  // Start sending frames to the server
  void _startStreaming() {
    _isStreaming = true;
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (!_isStreaming) {
        timer.cancel();
        return;
      }

      try {
        final image = await _cameraController.takePicture();
        final bytes = await image.readAsBytes();
        final img.Image? decodedImage = img.decodeImage(Uint8List.fromList(bytes));

        if (decodedImage != null) {
          final encodedImage = img.encodeJpg(decodedImage);

          // Convert List<int> (encodedImage) to Uint8List
          final frameData = Uint8List.fromList(encodedImage);

          // Send the frame to the server
          await _sendFrameToServer(frameData);
        }
      } catch (e) {
        print('Error capturing image: $e');
      }
    });
  }

  // Stop streaming
  void _stopStreaming() {
    setState(() {
      _isStreaming = false;
    });
  }

  // Send the video frame to the server
  Future<void> _sendFrameToServer(Uint8List frameData) async {
    final url = Uri.parse('http://127.0.0.1:2000/upload');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/octet-stream",
      },
      body: frameData,
    );

    if (response.statusCode == 200) {
      print('Frame sent successfully');
    } else {
      print('Failed to send frame');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: CameraPreview(_cameraController),
                ),
                ElevatedButton(
                  onPressed: () {
                    _isStreaming ? _stopStreaming() : _startStreaming();
                    setState(() {});
                  },
                  child: Text(_isStreaming ? 'Stop Streaming' : 'Start Streaming'),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error initializing camera: ${snapshot.error}'),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class SessionHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Session History')),
      body: Center(
        child: Text(
          'The History',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
