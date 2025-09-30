import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.of(context).pushReplacement(
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
        // 🔹 Full background image
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
              // 🔹 Full-height solid stripe behind the card
              Container(
                width: 600, // wider than login card
                height: screenHeight, // full height
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[900]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ), // flat edges for full-height stripe
                ),
              ),

              // 🔹 Login Card
              SingleChildScrollView(
                child: Container(
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
                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'PESO WEBSITE',
                        style: GoogleFonts.bebasNeue(fontSize: 36),
                      ),
                      const SizedBox(height: 30),
                      // Email & Password
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
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
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
            color: _isHovering ? Colors.red.shade700 : Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Log In',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
