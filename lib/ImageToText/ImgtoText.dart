import 'dart:io';
import 'package:Envision/ImageToText/result_screen.dart';
import 'package:camera/camera.dart';
import 'package:Envision/camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';


class TextRecogView extends StatefulWidget {
  const TextRecogView({super.key});

  @override
  State<TextRecogView> createState() => _TextRecogViewState();
}

class _TextRecogViewState extends State<TextRecogView> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late final Future<void> _future;

  final textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!cameraController!.value.isInitialized) {
      initCameraController(cameras[0]);
    }

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }else if (state == AppLifecycleState.resumed &&
        cameraController != null &&
        cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _future,
    builder: (context, snapshot) {
      return Stack(
        children: [
          if (_isPermissionGranted)
            FutureBuilder<List<CameraDescription>>(
              future: availableCameras(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Positioned.fill(
                    child: CameraPreview(cameraController!),
                  );
                } else {
                  return const LinearProgressIndicator();
                }
              },
            ),
          Scaffold(
            appBar: AppBar(
              title: const Text('Text Recognition'),
              backgroundColor: Color.fromARGB(255, 234, 174, 84),
            ),
            backgroundColor: _isPermissionGranted ? Colors.transparent : null,
            body: Stack(
              children: [
                Positioned.fill(
                  child: ElevatedButton(
                    onPressed: _scanImage,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: const SizedBox(),
                  ),
                ),
                if (!_isPermissionGranted)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                      child: const Text(
                        'Camera permission denied',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}


  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (cameraController != null) {
      _cameraSelected(cameraController!.description);
    }
  }


  Future<void> _cameraSelected(CameraDescription camera) async {
    cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await cameraController!.initialize();
    await cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (cameraController == null) return;
    
    final navigator = Navigator.of(context);

    try {
      final pictureFile = await cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultScreen(text: recognizedText.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }
}