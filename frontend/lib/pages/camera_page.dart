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
      try {
        await vision.loadYoloModel(
          labels: 'assets/model/labels.txt',
          modelPath: 'assets/model/my_model.tflite',
          modelVersion: "yolov8",
          quantization: false,
          numThreads: 2,
          useGpu: true,
        );
      } catch (gpuError) {
        await vision.loadYoloModel(
          labels: 'assets/model/labels.txt',
          modelPath: 'assets/model/my_model.tflite',
          modelVersion: "yolov8",
          quantization: false,
          numThreads: 2,
          useGpu: false,
        );
      }
      
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

        // Debug logging
        print("📐 Image: ${image.width}x${image.height}");
        print("📊 Results: ${result.length} detections");

        if (result.isNotEmpty && mounted) {
          final topResult = result.first;
          final gesture = topResult['tag'] as String;
          final confidence = topResult['box'][4] as double;
          
          // Debug: Print detected info
          print("✅ Detected: $gesture - ${(confidence * 100).toStringAsFixed(1)}%");
          print("📍 Box: ${topResult['box']}");
          
          final now = DateTime.now();
          final shouldSave = lastSavedGesture != gesture ||
              lastSaveTime == null ||
              now.difference(lastSaveTime!).inSeconds >= 3;
          
          if (shouldSave && confidence > 0.3) {
            HistoryService.saveDetection(gesture, confidence);
            lastSavedGesture = gesture;
            lastSaveTime = now;
          }

          setState(() {
            yoloResults = result;
          });
        } else if (mounted) {
          // Clear old results when nothing detected
          setState(() {
            yoloResults = [];
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

    return WillPopScope(
      onWillPop: () async {
        // Cleanup before navigating back
        if (_isStreaming && controller.value.isInitialized) {
          try {
            await controller.stopImageStream();
            _isStreaming = false;
          } catch (e) {
            // Ignore error during cleanup
          }
        }
        return true; // Allow navigation
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
        children: [
          // LAYER 1: KAMERA (Dibuat Center agar tidak ditarik paksa)
          Center(
            child: CameraPreview(controller),
          ),

          // LAYER 2: KOTAK DETEKSI
          LayoutBuilder(
            builder: (context, constraints) {
              if (cameraImage == null) return Stack(children: []);
              
              // Gunakan dimensi ASLI dari CameraImage
              final double imageWidth = cameraImage!.width.toDouble();
              final double imageHeight = cameraImage!.height.toDouble();
              
              return Stack(
                children: displayBoxesAroundRecognizedObjects(
                  Size(constraints.maxWidth, constraints.maxHeight),
                  imageHeight,
                  imageWidth
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

          // LAYER 5: STATUS INDICATOR
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: yoloResults.isEmpty 
                    ? Colors.orange.withOpacity(0.8)
                    : Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  yoloResults.isEmpty 
                    ? "🔍 Mencari gesture..." 
                    : "✅ ${yoloResults.length} gesture terdeteksi",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  // --- 3. MENGGAMBAR KOTAK HASIL DETEKSI ---
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen, double imgH, double imgW) {
    if (yoloResults.isEmpty || cameraImage == null) return [];

    // Fix: Gunakan koordinat yang benar dengan handle rotasi
    double factorX = screen.width / imgW;
    double factorY = screen.height / imgH;

    return yoloResults.map((result) {
      double x1 = result["box"][0];
      double y1 = result["box"][1];
      double x2 = result["box"][2];
      double y2 = result["box"][3];

      // Konversi koordinat dengan faktor yang benar
      double left = (x1 * factorX).clamp(0.0, screen.width - 50);
      double top = (y1 * factorY).clamp(0.0, screen.height - 50);
      double width = ((x2 - x1) * factorX).clamp(50.0, screen.width - left);
      double height = ((y2 - y1) * factorY).clamp(50.0, screen.height - top);

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
                      fontSize: 16.0,
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
    try {
      // Stop image stream with proper checks
      if (_isStreaming && 
          controller.value.isInitialized && 
          controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
    } catch (e) {
      print("Error stopping image stream: $e");
    }
    
    _isStreaming = false;
    
    try {
      // Dispose camera controller
      if (controller.value.isInitialized) {
        controller.dispose();
      }
    } catch (e) {
      print("Error disposing controller: $e");
    }
    
    try {
      // Close YOLO model
      if (isModelLoaded) {
        vision.closeYoloModel();
      }
    } catch (e) {
      print("Error closing YOLO model: $e");
    }
    
    super.dispose();
  }
}