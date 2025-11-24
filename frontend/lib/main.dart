import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Tambah import ini

// HAPUS import tflite_helper.dart (kita tidak pakai lagi)
// import 'tflite_helper.dart';

import 'pages/splash_page.dart';
import 'pages/welcome_page.dart';
import 'pages/menu_page.dart';
import 'pages/learn_menu_page.dart';
import 'pages/alphabet_page.dart';
import 'pages/number_page.dart';
import 'pages/camera_page.dart';
import 'pages/about_page.dart';

// Buat variabel global agar bisa diakses di CameraPage
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Siapkan Kamera di sini
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }

  // 2. HAPUS baris TFLiteHelper.loadModel();
  // (Kita akan load model nanti di CameraPage saja supaya hemat memori)

  runApp(LingoSignApp());
}

class LingoSignApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingo Sign',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
      routes: {
        '/welcome': (_) => WelcomePage(),
        '/menu': (_) => MenuPage(),
        '/learn': (_) => LearnMenu(),
        '/alphabet': (_) => AlphabetPage(),
        '/number': (_) => NumberPage(),
        '/camera': (_) => CameraPage(), // Ini akan memanggil file di langkah 3
        '/about': (_) => AboutPage(),
      },
    );
  }
}