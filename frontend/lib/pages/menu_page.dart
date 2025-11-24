import 'package:flutter/material.dart';
import 'about_page.dart';
import 'learn_menu_page.dart';
import 'camera_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ===========================
            // HEADER MELENGKUNG (WARNA UNGU)
            // ===========================
            ClipPath(
              clipper: HeaderClipper(),
              child: Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFF7F4CD9), // Warna ungu
                child: const Center(
                  child: Text(
                    "Lingo Sign",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ===========================
            // 2 MENU BOX
            // ===========================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _menuBox(
                  label: "Learning",
                  icon: Icons.menu_book_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LearnMenu()),
                    );
                  },
                ),
                const SizedBox(width: 20),
                _menuBox(
                  label: "About Us",
                  icon: Icons.info_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                  },
                ),
              ],
            ),

            const Spacer(),

            // ===========================
            // TOMBOL KAMERA DI BAWAH
            // ===========================
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7F4CD9),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  iconSize: 40,
                  color: Colors.white,
                  icon: const Icon(Icons.camera_alt_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CameraPage()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // MENU BOX
  // ===========================
  Widget _menuBox({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF7F4CD9)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================
// CLIPPER HEADER
// ===========================
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
