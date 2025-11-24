import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteHelper {
  static late Interpreter interpreter;
  static bool initialized = false;

  /// Panggil sekali saat app start (mis: splash_page initState)
  static Future<void> loadModel() async {
    if (initialized) return;
    try {
      interpreter = await Interpreter.fromAsset('model/best_float16.tflite');
      initialized = true;
      print("TFLite model loaded.");
    } catch (e) {
      print("Failed to load model: $e");
      rethrow;
    }
  }

  /// Menjalankan inference.
  /// inputImage adalah List<List<List<List<double>>>> dengan shape [1,640,640,3]
  /// Mengembalikan output nested List dengan shape [1,41,8400]
  static Future<List> runModel(List inputImage) async {
    if (!initialized) {
      throw Exception(
        "Interpreter belum di-initialize. Panggil TFLiteHelper.loadModel() dulu.",
      );
    }

    // Pre-allocate output sesuai model: [1, 41, 8400]
    final int dim1 = 1;
    final int dim2 = 41;
    final int dim3 = 8400;

    // buat nested list untuk menampung output
    List output = List.generate(
      dim1,
      (_) => List.generate(dim2, (_) => List.filled(dim3, 0.0)),
    );

    try {
      interpreter.run(inputImage, output);
    } catch (e) {
      print("Error running interpreter: $e");
      rethrow;
    }

    return output;
  }
}
