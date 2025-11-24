import 'package:flutter/material.dart';

class AlphabetPage extends StatelessWidget {
  const AlphabetPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List huruf A - Z
    List<String> alph = List.generate(26, (i) => String.fromCharCode(65 + i));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alphabet"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: alph.length,
        itemBuilder: (context, index) {
          String letter = alph[index];

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/alphabet/$letter.png",
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
