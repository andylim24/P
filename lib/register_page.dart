import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'jobseeker_registration_page.dart';
import 'main_homepage.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _skillsController = TextEditingController();
  bool _isHovering = false;
  String? _selectedBarangay;

  final List<String> _barangayList = [
    'Poblacion', 'Bel-Air', 'Guadalupe Nuevo', 'San Antonio', 'Santa Cruz', 'San Lorenzo',
    'Cembo', 'Comembo', 'East Rembo', 'West Rembo', 'Pembo', 'South Cembo', 'Rizal',
    'Pitogo', 'Olympia', 'Bangkal', 'Tejeros', 'Singkamas', 'La Paz', 'Santa Cruz',
    'Palanan', 'Magallanes', 'San Isidro', 'Kasilawan',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if (passwordConfirmed()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        await addUserDetails(user!.email!, user.uid);


        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const JobseekerRegistrationPage()),
        );

      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text(e.toString())),
        );
      }
    }
  }

  Future addUserDetails(String email, String uid) async {
    final skillsList = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fullName': _fullNameController.text.trim(),
      'email': email,
      'skills': skillsList,
      'barangay': _selectedBarangay ?? '',
      'resumeUrl': '',
      'appliedJobs': [],
    });
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Passwords don't match!"),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return MainScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgimage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gradient background stripe
              Container(
                width: 600,
                height: screenHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: CustomPaint(
                  painter: PlusSignPainter(),
                ),
              ),

              // Register form container
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and PESO Text outside the form container
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 140,
                            height: 140,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Text(
                                'PESO MAKATI:',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 65,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Job Recommendation APP',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 35,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // White form container with input fields
                    Container(
                      padding: const EdgeInsets.all(30),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Create a Makati Job Account',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 24,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          _buildInputField(_fullNameController, 'Full Name'),
                          const SizedBox(height: 15),
                          _buildInputField(_emailController, 'Email'),
                          const SizedBox(height: 15),
                          _buildInputField(_skillsController, 'Skills (comma-separated)'),
                          const SizedBox(height: 15),
                          _buildDropdownField(),
                          const SizedBox(height: 15),
                          _buildInputField(_passwordController, 'Password', obscureText: true),
                          const SizedBox(height: 15),
                          _buildInputField(_confirmPasswordController, 'Confirm Password', obscureText: true),
                          const SizedBox(height: 25),
                          _buildRegisterButton(),
                          const SizedBox(height: 20),
                          _buildLoginLink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedBarangay,
      hint: const Text('Select Barangay'),
      onChanged: (value) => setState(() => _selectedBarangay = value),
      items: _barangayList
          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
          .toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: signUp,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHovering ? Colors.blue.shade800 : Colors.blue.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('Register',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account?', style: TextStyle(fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: widget.showLoginPage,
          child: const Text('  Login',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
class PlusSignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    double spacing = 40.0;  // Adjust the spacing between the plus signs
    double sizeOfPlus = 20.0; // Adjust the size of the plus sign
    double padding = 20.0; // Padding around the edges of the container

    // Draw "+" symbols in rows and columns, with padding to avoid edges
    for (double x = padding; x < size.width - padding + spacing; x += spacing) {
      for (double y = padding; y < size.height - padding; y += spacing) {
        // Draw the "+" symbol by combining lines
        canvas.drawLine(Offset(x - sizeOfPlus / 2, y), Offset(x + sizeOfPlus / 2, y), paint); // Horizontal line
        canvas.drawLine(Offset(x, y - sizeOfPlus / 2), Offset(x, y + sizeOfPlus / 2), paint); // Vertical line
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}