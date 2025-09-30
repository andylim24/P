import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    'Poblacion','Bel-Air','Guadalupe Nuevo','San Antonio','Santa Cruz','San Lorenzo',
    'Cembo','Comembo','East Rembo','West Rembo','Pembo','South Cembo','Rizal',
    'Pitogo','Olympia','Bangkal','Tejeros','Singkamas','La Paz','Santa Cruz',
    'Palanan','Magallanes','San Isidro','Kasilawan',
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
          MaterialPageRoute(builder: (_) => const HomePage()),
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
              // 🔹 Full-height stripe behind the card
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

              // 🔹 Register Card
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
            color: _isHovering ? Colors.red.shade700 : Colors.redAccent,
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
