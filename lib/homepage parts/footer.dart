import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A1446),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;

              return isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildSections(isMobile),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSections(isMobile),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(bool isMobile) {
    return [
      // 🔹 Left Section
      SizedBox(
        width: isMobile ? double.infinity : 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              "MAKATI PUBLIC EMPLOYMENT\nSERVICE OFFICE",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "5th floor, New Makati City Hall Bldg. I,\n"
                  "J.P. Rizal St., Poblacion, Makati City\n\n"
                  "☎ 870-1000 loc. 1230, 1226, 1233\n"
                  "📧 peso.makati@yahoo.com.ph\n"
                  "📧 eipd.pesomakati@gmail.com",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: isMobile ? 40 : 0),

      // 🔹 Middle Section
      SizedBox(
        width: isMobile ? double.infinity : 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/makati_logo.png", height: 80),
                const SizedBox(width: 20),
                Image.asset("assets/images/logo.png", height: 80),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "PESO",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Ang Bangko ng\nTrabaho",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: isMobile ? 40 : 0),

      // 🔹 Right Section
      SizedBox(
        width: isMobile ? double.infinity : 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _dole("DOLE"),
            const SizedBox(height: 16),
            _poea("POEA"),
            const SizedBox(height: 16),
            _owwa("OWWA"),
          ],
        ),
      ),
    ];
  }

  Widget _dole(String label) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(2, 0), // ➡ right | ⬅ left = negative
          child: Image.asset(
            "assets/images/dole.png",
            height: 50,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _poea(String label) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(7, 0), // ⬅ move left
          child: Image.asset(
            "assets/images/poea.png",
            height: 80,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _owwa(String label) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, 0), // adjust freely
          child: Image.asset(
            "assets/images/owwa.png",
            height: 80,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

}