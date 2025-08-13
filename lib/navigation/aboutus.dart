import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.red),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Image (outside of container)
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),

            // Container for Mission and Vision
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, // Light background color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mission Section
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
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                          'Curabitur blandit tempus porttitor. Sed posuere consectetur est at lobortis. '
                          'Maecenas faucibus mollis interdum. Nullam quis risus eget urna mollis ornare vel eu leo. '
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                          'Curabitur blandit tempus porttitor. Sed posuere consectetur est at lobortis.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 24),

                    // Vision Section
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
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                          'Integer posuere erat a ante venenatis dapibus posuere velit aliquet. '
                          'Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. '
                          'Curabitur blandit tempus porttitor. Sed posuere consectetur est at lobortis. '
                          'Maecenas faucibus mollis interdum. Nullam quis risus eget urna mollis ornare vel eu leo.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
