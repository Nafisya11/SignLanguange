import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    initCam();
  }

  Future<void> initCam() async {
    final cams = await availableCameras();
    controller = CameraController(
      cams[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      body: controller == null || !controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : CameraPreview(controller!),
    );
  }
}
