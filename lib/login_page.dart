import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:peso_makati_website_application/admin_page/admin_homepage.dart';
import 'forgot_pw_page.dart';
import '../main_homepage.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isHovering = false;
  bool _isPasswordVisible = false; // Added for show/hide password

  Future<void> signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == 'admin@gmail.com' && password == 'admin123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomepage()),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Invalid email or password. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and PESO text side by side
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
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
                    // White Box with Input Fields and Job Recommendation App text
                    Container(
                      padding: const EdgeInsets.all(30),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
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
                            'Enter Your Makati Job Account',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 24,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildInputField(_emailController, 'Email'),
                          const SizedBox(height: 15),
                          _buildInputField(_passwordController, 'Password', obscureText: true),
                          const SizedBox(height: 10),
                          _buildForgotPasswordLink(),
                          const SizedBox(height: 20),
                          _buildLoginButton(),
                          const SizedBox(height: 20),
                          _buildRegisterLink(),
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

  Widget _buildInputField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText && !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: obscureText
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[700],
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        )
            : null,
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ForgotPasswordPage(),
              ),
            );
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: signIn,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHovering ? Colors.blue.shade800 : Colors.blue.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Log In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: widget.showRegisterPage,
          child: const Text(
            '  Sign Up',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
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

    double spacing = 40.0;
    double sizeOfPlus = 20.0;
    double padding = 20.0;

    for (double x = padding; x < size.width - padding + spacing; x += spacing) {
      for (double y = padding; y < size.height - padding; y += spacing) {
        canvas.drawLine(Offset(x - sizeOfPlus / 2, y), Offset(x + sizeOfPlus / 2, y), paint);
        canvas.drawLine(Offset(x, y - sizeOfPlus / 2), Offset(x, y + sizeOfPlus / 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
