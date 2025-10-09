import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A1446), // Dark blue background
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Left Section
              SizedBox(
                width: 300,
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
              const SizedBox(width: 100),


              // 🔹 Middle Section
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/makati_logo.png",
                            height: 100, fit: BoxFit.contain),
                        const SizedBox(width: 20),
                        Image.asset("assets/images/logo.png",
                            height: 100, fit: BoxFit.contain),
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

              const SizedBox(width: 100),

              // 🔹 Right Section
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _dole("DOLE"),
                    _poea("POEA"),
                    _owwa("OWWA"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dole(String label) {
    return Column(
      children: [
        Image.asset("assets/images/dole.png", height: 50, fit: BoxFit.contain),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
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
        Image.asset("assets/images/owwa.png", height: 100, fit: BoxFit.contain),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
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
        Image.asset("assets/images/poea.png", height: 100, fit: BoxFit.contain),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

}
