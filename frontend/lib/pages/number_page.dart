import 'package:flutter/material.dart';

class NumberPage extends StatelessWidget {
  const NumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    // list angka 0–10
    List<String> nums = List.generate(11, (i) => i.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Number"),
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
        itemCount: nums.length,
        itemBuilder: (context, index) {
          String num = nums[index];

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/number/$num.png", fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
