import 'package:flutter/material.dart';
import 'auth/sign_up_page.dart';
import 'auth/sign_in_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showSignIn = true;

  void togglePage() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn
        ? SignInPage(onRegisterClicked: togglePage)
        : SignUpPage(onLoginClicked: togglePage);
  }
}