import 'package:flutter/material.dart';
import 'alphabet_page.dart';
import 'number_page.dart';

class LearnMenu extends StatelessWidget {
  const LearnMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFF7F4CD9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                child: Text(
                  "Lingo Sign",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),

          smallMenuButton("ALPHABET", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlphabetPage()),
            );
          }),

          const SizedBox(height: 20),

          smallMenuButton("NUMBER", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NumberPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget smallMenuButton(String txt, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 230,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(txt, style: const TextStyle(fontSize: 18))),
      ),
    );
  }
}
