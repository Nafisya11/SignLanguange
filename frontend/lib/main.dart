import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Tambah import ini
import 'pages/splash_page.dart';
import 'pages/welcome_page.dart';
import 'pages/menu_page.dart';
import 'pages/learn_menu_page.dart';
import 'pages/alphabet_page.dart';
import 'pages/number_page.dart';
import 'pages/camera_page.dart';
import 'pages/about_page.dart';
import 'pages/history_page.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
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
        '/history': (_) => HistoryPage(),
        '/about': (_) => AboutPage(),
      },
    );
  }
}