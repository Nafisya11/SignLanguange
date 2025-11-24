import 'package:flutter/material.dart';
import 'menu_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF7F4CD9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(120),
                bottomRight: Radius.circular(120),
              ),
            ),
            child: const Center(
              child: Text(
                "Welcome To\nLingo Sign",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
          const Icon(Icons.front_hand, size: 100),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '“Bahasa bukan sekedar kata – ia juga bisa diucapkan lewat gerakan dan hati.”',
              textAlign: TextAlign.center,
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuPage()),
              );
            },
            child: const Text(
              "Get Started",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
