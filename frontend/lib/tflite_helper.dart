import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteHelper {
  static late Interpreter interpreter;
  static bool initialized = false;

  /// Panggil sekali saat app start (mis: di method initState pada main.dart atau loading screen)
  static Future<void> loadModel() async {
    if (initialized) return;
    try {
      // Opsi tambahan agar deteksi lebih cepat (tidak bikin UI macet)
      final options = InterpreterOptions();
      options.threads = 2; // Gunakan 2 core CPU
      // options.addDelegate(GpuDelegate()); // Uncomment jika ingin coba pakai GPU (bisa error di beberapa HP)

      // PERBAIKAN: Tambahkan 'assets/' di depan path
      interpreter = await Interpreter.fromAsset(
          'assets/model/my_model.tflite',
          options: options
      );

      initialized = true;
      print("✅ TFLite model loaded successfully.");
    } catch (e) {
      print("❌ Failed to load model: $e");
      rethrow;
    }
  }

  /// Menjalankan inference.
  /// inputImage: Harus sudah berupa float32 list [1, 640, 640, 3] yang dinormalisasi (0-1)
  static Future<List> runModel(List inputImage) async {
    if (!initialized) {
      throw Exception(
        "Interpreter belum di-initialize. Panggil TFLiteHelper.loadModel() dulu.",
      );
    }

    // Output shape YOLOv8 biasanya [1, (4 + ClassCount), 8400]
    // Berdasarkan komentar Anda: [1, 41, 8400]
    const int batchSize = 1;
    const int channels = 41; // 4 koordinat + 37 kelas bahasa isyarat
    const int anchors = 8400;

    // Alokasi memori output
    // Menggunakan reshape logic agar sesuai permintaan TFLite
    var output = List.filled(batchSize * channels * anchors, 0.0).reshape([batchSize, channels, anchors]);

    try {
      // Jalankan model
      interpreter.run(inputImage, output);
    } catch (e) {
      print("❌ Error running interpreter: $e");
      rethrow;
    }

    return output;
  }

  static void close() {
    if (initialized) {
      interpreter.close();
      initialized = false;
    }
  }
}