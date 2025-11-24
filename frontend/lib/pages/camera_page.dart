import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import '../main.dart'; // Import ini untuk mengambil variabel 'cameras' dari main.dart

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  late FlutterVision vision;
  bool isLoaded = false;
  bool isDetecting = false; // Flag untuk mencegah deteksi tumpuk
  List<Map<String, dynamic>> yoloResults = [];
  CameraImage? cameraImage;

  @override
  void initState() {
    super.initState();
    init();
  }

  // --- 1. INISIALISASI KAMERA & MODEL ---
  init() async {
    if (cameras.isEmpty) return;

    vision = FlutterVision();

    await vision.loadYoloModel(
        labels: 'assets/model/labels.txt',
        modelPath: 'assets/model/my_model.tflite',

        modelVersion: "yolov8", // <--- UBAH JADI INI (Sekarang pasti bisa!)
        quantization: false,
        numThreads: 2,
        useGpu: false);

    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium, // <--- PENTING: Medium itu rasionya 4:3
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await controller.initialize();

    if (mounted) {
      setState(() {
        isLoaded = true;
      });
      startDetection();
    }
  }

  // --- 2. LOOP DETEKSI ---
  Future<void> startDetection() async {
    if (!controller.value.isInitialized) return;

    await controller.startImageStream((image) async {
      if (isDetecting) return;

      isDetecting = true;
      cameraImage = image;

      try {
        final result = await vision.yoloOnFrame(
            bytesList: image.planes.map((plane) => plane.bytes).toList(),
            imageHeight: 1,
            imageWidth: 1,
            iouThreshold: 0.3,
            confThreshold: 0.15, // <--- TURUNKAN JADI 15% (Biar sensitif banget)
            classThreshold: 0.15); // <--- INI JUGA

        // Debugging di terminal
        if (result.isNotEmpty) {
          print("✅ TERDETEKSI: $result");
        }

        if (mounted) {
          setState(() {
            yoloResults = result;
          });
        }
      } catch (e) {
        print("Error Deteksi: $e");
      } finally {
        // Jangan terlalu cepat, kasih napas dikit
        await Future.delayed(const Duration(milliseconds: 100));
        isDetecting = false;
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
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
        ],
      ),
    );
  }

  // --- 3. MENGGAMBAR KOTAK HASIL DETEKSI ---
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen, double imgH, double imgW) {
    if (yoloResults.isEmpty || cameraImage == null) return [];

    // Faktor kalibrasi manual untuk rasio 4:3
    double factorX = screen.width / (imgH);
    double factorY = screen.height / (imgW); // Sesuaikan tinggi kamera vs tinggi layar

    return yoloResults.map((result) {

      // Ambil data pixel mentah
      double x1 = result["box"][0];
      double y1 = result["box"][1];
      double x2 = result["box"][2];
      double y2 = result["box"][3];

      // Konversi ke ukuran layar
      double left = x1 * factorX;
      double top = y1 * factorY;
      double width = (x2 - x1) * factorX;
      double height = (y2 - y1) * factorY;

      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.green, width: 3.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = Colors.green,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    // Matikan stream dan controller saat keluar halaman
    controller.dispose();
    vision.closeYoloModel();
    super.dispose();
  }
}