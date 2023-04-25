import 'package:camera/camera.dart';

CameraController? cameraController;

Future<void> initCameraController(CameraDescription cameraDescription) async {
  cameraController = CameraController(
    cameraDescription,
    ResolutionPreset.high,
  );

  await cameraController!.initialize();
}
