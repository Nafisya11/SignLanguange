import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import '../main.dart';
import '../services/history_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  late FlutterVision vision;
  bool isLoaded = false;
  bool isModelLoaded = false;
  bool isDetecting = false;
  bool _isStreaming = false;
  List<Map<String, dynamic>> yoloResults = [];
  CameraImage? cameraImage;
  String? lastSavedGesture;
  DateTime? lastSaveTime;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    init();
  }

  // --- 1. INISIALISASI KAMERA & MODEL ---
  init() async {
    if (cameras.isEmpty) {
      if (mounted) {
        setState(() {
          errorMessage = "Tidak ada kamera tersedia";
        });
      }
      return;
    }

    vision = FlutterVision();

    try {
      // Try GPU first, fallback to CPU
        await vision.loadYoloModel(
          labels: 'assets/model/labels.txt',
          modelPath: 'assets/model/my_model.tflite',
          modelVersion: "yolov8",
          quantization: true,
          numThreads: 2,
          useGpu: false,
        );
      isModelLoaded = true;
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Gagal memuat model AI: ${e.toString()}";
        });
      }
      return;
    }

    try {
      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (mounted && isModelLoaded) {
        setState(() {
          isLoaded = true;
        });
        startDetection();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Gagal menginisialisasi kamera: ${e.toString()}";
        });
      }
    }
  }

  // --- 2. LOOP DETEKSI ---
  Future<void> startDetection() async {
    if (!controller.value.isInitialized || !isModelLoaded || _isStreaming) return;

    _isStreaming = true;
    
    await controller.startImageStream((image) async {
      if (isDetecting) return;

      isDetecting = true;
      cameraImage = image;
      final startTime = DateTime.now();

      try {
        final result = await vision.yoloOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.45,
          confThreshold: 0.4,
          classThreshold: 0.4,
        );

        if (result.isNotEmpty && mounted) {
          final topResult = result.first;
          final gesture = topResult['tag'] as String;
          final confidence = topResult['box'][4] as double;
          
          final now = DateTime.now();
          final shouldSave = lastSavedGesture != gesture ||
              lastSaveTime == null ||
              now.difference(lastSaveTime!).inSeconds >= 3;
          
          if (shouldSave && confidence > 0.4) {
            HistoryService.saveDetection(gesture, confidence);
            lastSavedGesture = gesture;
            lastSaveTime = now;
          }

          setState(() {
            yoloResults = result;
          });
        }
      } catch (e) {
        // Silent error handling in production
      } finally {
        // Adaptive delay based on processing time
        final processingTime = DateTime.now().difference(startTime).inMilliseconds;
        final delay = (processingTime < 100) ? 100 - processingTime : 10;
        await Future.delayed(Duration(milliseconds: delay));
        isDetecting = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show error if model or camera failed
    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali ke Menu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show loading
    if (!isLoaded) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.purple),
              const SizedBox(height: 16),
              Text(
                isModelLoaded ? 'Memulai kamera...' : 'Memuat model AI...',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LAYER 1: KAMERA (Dibuat Center agar tidak ditarik paksa)
          Center(
            child: CameraPreview(controller),
          ),

          // LAYER 2: KOTAK DETEKSI
          // Kita bungkus dengan LayoutBuilder agar koordinatnya pas dengan ukuran kamera visual
          LayoutBuilder(
            builder: (context, constraints) {
              // Pastikan kita menggambar kotak HANYA di area kamera, bukan seluruh layar
              // Ukuran preview kamera di layar:
              final Size cameraSize = controller.value.previewSize!;

              // Hitung skala agar bounding box pas dengan tampilan di layar
              // Karena dirotasi, width controller jadi height layar
              double scaleX = constraints.maxWidth / cameraSize.height;
              double scaleY = constraints.maxHeight / cameraSize.width;

              // Jika kamera ditaruh di Center, kita butuh offset jika ada sisa layar hitam
              // Tapi untuk simplifikasi, kita anggap full width.

              return Stack(
                children: displayBoxesAroundRecognizedObjects(
                    Size(constraints.maxWidth, constraints.maxHeight),
                    cameraSize.height,
                    cameraSize.width
                ),
              );
            },
          ),

          // LAYER 3: TOMBOL KEMBALI
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // LAYER 4: TOMBOL HISTORY
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.history, color: Colors.white, size: 30),
              onPressed: () => Navigator.pushNamed(context, '/history'),
              tooltip: 'Lihat Riwayat',
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. MENGGAMBAR KOTAK HASIL DETEKSI ---
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen, double imgH, double imgW) {
    if (yoloResults.isEmpty || cameraImage == null) return [];

    double factorX = screen.width / imgH;
    double factorY = screen.height / imgW;

    return yoloResults.map((result) {
      double x1 = result["box"][0];
      double y1 = result["box"][1];
      double x2 = result["box"][2];
      double y2 = result["box"][3];

      // Clamp coordinates to prevent drawing outside screen
      double left = (x1 * factorX).clamp(0.0, screen.width - 10);
      double top = (y1 * factorY).clamp(0.0, screen.height - 10);
      double width = ((x2 - x1) * factorX).clamp(10.0, screen.width - left);
      double height = ((y2 - y1) * factorY).clamp(10.0, screen.height - top);

      final confidence = (result['box'][4] * 100).toStringAsFixed(0);

      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.greenAccent, width: 3.0),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    "${result['tag']} $confidence%",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    // Stop image stream before disposing
    if (_isStreaming && controller.value.isInitialized && controller.value.isStreamingImages) {
      controller.stopImageStream();
    }
    _isStreaming = false;
    
    // Dispose camera controller
    if (controller.value.isInitialized) {
      controller.dispose();
    }
    
    // Close YOLO model
    if (isModelLoaded) {
      vision.closeYoloModel();
    }
    
    super.dispose();
  }
}