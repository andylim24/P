import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _skillsController = TextEditingController();

  String? _selectedBarangay;
  final List<String> _barangayList = [
    'Poblacion',
    'Bel-Air',
    'Guadalupe Nuevo',
    'San Antonio',
    'Santa Cruz',
    'San Lorenzo',
    'Cembo',
    'Comembo',
    'East Rembo',
    'West Rembo',
    'Pembo',
    'South Cembo',
    'Rizal',
    'Pitogo',
    'Olympia',
    'Bangkal',
    'Tejeros',
    'Singkamas',
    'La Paz',
    'Santa Cruz',
    'Palanan',
    'Magallanes',
    'San Isidro',
    'Kasilawan',
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

        await addUserDetails(
          user!.email!,
          user.uid,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.toString()),
            );
          },
        );
      }
    }
  }

  Future addUserDetails(String email, String uid) async {
    final skillsList = _skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
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
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Passwords don't match!"),
          );
        },
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100,
      body: SafeArea(
        child: Center(
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text('Sign Up', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          const SizedBox(height: 25),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1500),
      padding: const EdgeInsets.all(40),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bgimage.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top-left text
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7), // transparent white background
                            borderRadius: BorderRadius.circular(8), // rounded corners
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PESO MAKATI',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 80,
                                  color: Colors.blueAccent, // make text readable on white
                                ),
                              ),
                              Text(
                                'JOB RECOMMENDATION APP',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 45,
                                  color: Colors.blueAccent, // make text readable on white
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      // Bottom-left logo + PESO MAKATI text
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 150,
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200, // Light blue background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildLoginLink(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              fillColor: Colors.grey[200],
              filled: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedBarangay,
            hint: const Text('Select Barangay'),
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedBarangay = newValue!;
              });
            },
            items: _barangayList.map((String barangay) {
              return DropdownMenuItem<String>(
                value: barangay,
                child: Text(barangay),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: signUp,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'REGISTER',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
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
          child: const Text(
            ' Login now',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
