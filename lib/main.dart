import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front);

  runApp(MyApp(camera: frontCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _CameraScreen(camera: camera),
    );
  }
}

class _CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const _CameraScreen({required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<_CameraScreen> {
  CameraController? _cameraController;
  // Timer? _timer;
  String _message = "initial message";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(widget.camera, ResolutionPreset.high);
    await _cameraController!.initialize();

    _takePicture();
    // _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    //   _takePicture();
    // });

    setState(() {});
  }

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile pictrue = await _cameraController!.takePicture();
      final Uint8List imageData = await pictrue.readAsBytes();
      final ret = await ImageGallerySaver.saveImage(imageData);
      setState(() {
        _message = 'Picture saved to $ret';
      });
    } catch (e) {
      setState(() {
        _message = 'Error taking picture: $e';
      });
    }
  }

  @override
  void dispose() {
    // _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera not initialized'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera initialized'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _message,
              style: const TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
        ],
      ),
    );
  }
}
