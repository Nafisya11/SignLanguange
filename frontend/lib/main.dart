import 'package:flutter/material.dart';

// IMPORT TFLITE HELPER
import 'tflite_helper.dart';

// IMPORT PAGES
import 'pages/splash_page.dart';
import 'pages/welcome_page.dart';
import 'pages/menu_page.dart';
import 'pages/learn_menu_page.dart';
import 'pages/alphabet_page.dart';
import 'pages/number_page.dart';
import 'pages/camera_page.dart';
import 'pages/about_page.dart';

Future<void> main() async {
  // WAJIB sebelum async
  WidgetsFlutterBinding.ensureInitialized();

  // Load model sebelum app berjalan
  await TFLiteHelper.loadModel();

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
        '/camera': (_) => CameraPage(),
        '/about': (_) => AboutPage(),
      },
    );
  }
}
