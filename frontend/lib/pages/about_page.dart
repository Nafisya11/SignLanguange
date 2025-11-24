import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APPBAR UNGU
      appBar: AppBar(
        backgroundColor: const Color(0xFF7F4CD9),
        centerTitle: true,
        title: const Text(
          "About LingoSign",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Judul Besar
            const Text(
              "Tentang Aplikasi",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7F4CD9),
              ),
            ),
            const SizedBox(height: 15),

            // 🔲 CARD 1 – Deskripsi
            _buildCard(
              title: "Apa itu LingoSign?",
              content:
                  "LingoSign adalah aplikasi pembelajaran BISINDO (Bahasa Isyarat Indonesia) "
                  "yang membantu pengguna memahami huruf dan angka melalui ilustrasi gerakan "
                  "tangan yang mudah dipahami.",
            ),
            const SizedBox(height: 15),

            // 🔲 CARD 2 – Fitur Utama
            _buildCard(
              title: "Fitur Utama",
              content:
                  "• Belajar Alphabet BISINDO A–Z\n"
                  "• Belajar Angka 0–10 dalam bahasa isyarat\n"
                  "• Tampilan sederhana dan ramah pemula\n"
                  "• Belajar kapan saja melalui smartphone",
            ),
            const SizedBox(height: 15),

            // 🔲 CARD 3 – Tujuan
            _buildCard(
              title: "Tujuan Aplikasi",
              content:
                  "✔ Meningkatkan pemahaman masyarakat tentang BISINDO\n"
                  "✔ Memberikan media pembelajaran visual yang praktis\n"
                  "✔ Mendukung komunikasi inklusif dengan teman Tuli",
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // 🔹 WIDGET KARTU KONTEN
  // ====================================================
  Widget _buildCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7F4CD9),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
