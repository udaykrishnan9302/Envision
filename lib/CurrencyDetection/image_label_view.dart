import 'dart:io' as io;
import 'dart:developer' as logDev;

import 'package:Envision/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path/path.dart' as pathI;
import 'package:path_provider/path_provider.dart';
import 'package:Envision/CurrencyDetection/curr_res_screen.dart';

import '../OjectDetection/camera_view.dart';

import 'package:camera/camera.dart';
import 'package:Envision/camera_controller.dart';
import 'package:permission_handler/permission_handler.dart';


class ImageLabelView extends StatefulWidget {
  const ImageLabelView({super.key});

  @override
  State<ImageLabelView> createState() => _ImageLabelViewState();
}

class _ImageLabelViewState extends State<ImageLabelView> with WidgetsBindingObserver{
  late ImageLabeler _imageLabeler;
  ScreenMode mode = ScreenMode.gallery;
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  
  get text => null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!cameraController!.value.isInitialized) {
      initCameraController(cameras[0]);
    }

    _future = _requestCameraPermission();
    _initializeLabeler();
  }

  @override
  void dispose() {
    _imageLabeler.close();
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
              title: const Text('Currency Detection'),
            ),
            backgroundColor: _isPermissionGranted ? Colors.transparent : null,
            body: Stack(
              children: [
                Positioned.fill(
                  child: ElevatedButton(
                    onPressed: _processImage,
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

  void _initializeLabeler() async {
    // uncomment next line if you want to use the default model
    // _imageLabeler = ImageLabeler(options: ImageLabelerOptions());

    // uncomment next lines if you want to use a local model
    // make sure to add tflite model to assets/ml
    // final path = 'assets/ml/lite-model_aiy_vision_classifier_birds_V1_3.tflite';
    const path = 'assets/ml/model.tflite';
    final modelPath = await _getModel(path);
    final options = LocalLabelerOptions(modelPath: modelPath);
    _imageLabeler = ImageLabeler(options: options);

    // uncomment next lines if you want to use a remote model
    // make sure to add model to firebase
    // final modelName = 'bird-classifier';
    // final response =
    //     await FirebaseImageLabelerModelManager().downloadModel(modelName);
    // print('Downloaded: $response');
    // final options =
    //     FirebaseLabelerOption(confidenceThreshold: 0.5, modelName: modelName);
    // _imageLabeler = ImageLabeler(options: options);

  }

  Future<void> _processImage() async {
    String text2="";
    if (cameraController == null) return;
    logDev.log("======================================console log==================================",name:"mylog");
    final navigator = Navigator.of(context);
    logDev.log("======================================console log2==================================",name:"mylog");
    try {
      final pictureFile = await cameraController!.takePicture();

      final file = io.File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final labels = await _imageLabeler.processImage(inputImage);
      if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
    } else {
      String text = 'Labels found: ${labels.length}\n\n';
      for (final label in labels) {
        text += 'Label: ${label.label}, '
            'Confidence: ${label.confidence.toStringAsFixed(2)}\n\n';
      }
      text2=text;
    }
      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              CurrResultScreen(text: text2),
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

  Future<String> _getModel(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(pathI.dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
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
}
