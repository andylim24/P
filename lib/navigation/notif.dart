import 'package:flutter/material.dart';

class Notif extends StatelessWidget {
  const Notif({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.red),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content with fixed width
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notification card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[100],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400,
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Xample Notification:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Thank you for your interest in the position; however, we regret to inform you that you have not been selected. We appreciate the time and effort you put into your application.\n"
                                        "It was a pleasure reviewing your qualifications, and we recognize the strengths you bring.\n"
                                        "Unfortunately, after careful consideration, we have chosen to move forward with another candidate whose experience more closely aligns with our current needs. "
                                        "We encourage you to apply for future opportunities that match your skills and interests. Again, thank you for considering a career with us, and we wish you all the best in your job search.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 40),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Text(
                                  "Wednesday, July 03, 2025\n9:00 AM",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Fixed pagination footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _pageButton("Prev", active: false),
                      _pageNumber(1, active: true),
                      _pageNumber(2),
                      _pageNumber(3),
                      _pageNumber(4),
                      _pageNumber(5),
                      _pageNumber(12),
                      _pageButton("Next", active: true),
                    ],
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageButton(String label, {bool active = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: active ? () {} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? Colors.blue[900] : Colors.grey[300],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _pageNumber(int number, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.lightBlue[100] : Colors.lightBlue[50],
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          '$number',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
