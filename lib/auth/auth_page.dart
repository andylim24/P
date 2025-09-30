import 'package:flutter/material.dart';
import '../login_page.dart';
import '../register_page.dart';

class AuthPage extends StatefulWidget {
  final bool showLogin; // ✅ new parameter

  const AuthPage({super.key, this.showLogin = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool showLoginPage;

  @override
  void initState() {
    super.initState();
    showLoginPage = widget.showLogin; // ✅ pick default screen
  }

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        showRegisterPage: toggleScreens,
      );
    } else {
      return RegisterPage(
        showLoginPage: toggleScreens,
      );
    }
  }
}
