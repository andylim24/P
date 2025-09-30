import 'package:flutter/material.dart';
import '../main_homepage.dart';
import '../homepage parts/footer.dart'; // Make sure this path is correct

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Container(
        // 🔹 Background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/homebackground.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Container(
          // 🔹 Dark overlay for readability
          color: Colors.black.withOpacity(0.3),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Full-width Banner
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue[900]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Welcome to Our Organization!\n\nLearn more about our mission, vision, history, and the dedicated team behind our initiatives.",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),

                // 🔹 Mission and Vision Container
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Mission',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Our mission is to provide quality services and resources to the community, '
                              'ensuring accessibility, sustainability, and innovation in all our initiatives.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Our Vision',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Our vision is to become a leading organization recognized for excellence, '
                              'innovation, and positive impact on the community and society at large.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 History Section
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our History',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                              'Praesent vel dolor eget nisi feugiat efficitur. Sed vitae justo eu mauris venenatis tempus. '
                              'Donec scelerisque, purus sit amet elementum finibus, turpis quam fermentum justo, '
                              'ac feugiat enim leo ut orci.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 Team Members Section
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Members of the Organization',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                              'Mauris luctus, tortor sit amet convallis cursus, orci risus finibus enim, '
                              'id laoreet quam eros a justo. Quisque at sapien sit amet turpis varius malesuada.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                              'Sed euismod justo vel diam malesuada, ac placerat libero tincidunt. '
                              'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Footer
                const FooterSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
