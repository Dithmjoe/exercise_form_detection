import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Video App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Video App')),
      body: Center(
        child: GridView.count(
          padding: EdgeInsets.all(16.0),
          crossAxisCount: 2,
          children: <Widget>[
            _buildCard(
              context,
              'Exercise',
              Icons.fitness_center,
              ExerciseScreen(),
            ),
            _buildCard(
              context,
              'Session History',
              Icons.history,
              SessionHistoryScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Widget destination) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}


class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture; // Change to nullable Future
  bool _isStreaming = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      final firstCamera = cameras.first;

      _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture; // Await the initialization
      setState(() {}); // Rebuild to reflect initialization state
    } catch (e) {
      print('Error initializing camera: $e');
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e')),
      );
      // Set _initializeControllerFuture to null to avoid late initialization error
      _initializeControllerFuture = Future.value();
    }
  }

  void _startStreaming() {
    setState(() {
      _isStreaming = true;
      _isLoading = true;
    });

    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (!_isStreaming) {
        timer.cancel();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final image = await _cameraController.takePicture();
        final bytes = await image.readAsBytes();
        final img.Image? decodedImage = img.decodeImage(Uint8List.fromList(bytes));

        if (decodedImage != null) {
          final encodedImage = img.encodeJpg(decodedImage);
          final frameData = Uint8List.fromList(encodedImage);
          await _sendFrameToServer(frameData);
        }
      } catch (e) {
        print('Error capturing image: $e');
      }
    });
  }

  void _stopStreaming() {
    setState(() {
      _isStreaming = false;
    });
  }

  Future<void> _sendFrameToServer(Uint8List frameData) async {
    final url = Uri.parse('http://192.168.95.73:2000/upload');
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
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    _isStreaming ? _stopStreaming() : _startStreaming();
                    setState(() {});
                  },
                  icon: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
                  label: Text(_isStreaming ? 'Stop Streaming' : 'Start Streaming'),
                ),
                if (_isLoading) CircularProgressIndicator(),
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
  const SessionHistoryScreen({super.key});

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
