import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shop/shop_page.dart';

/// A screen for user sign-in functionality using email and password.
///
/// This widget handles user input, performs authentication via Supabase,
/// and navigates to the main products page upon success.
class SignInPage extends StatefulWidget {
  final VoidCallback onRegisterClicked;
  /// Callback function to navigate to the registration screen.
  const SignInPage({super.key, required this.onRegisterClicked});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Controllers for the email and password text fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // State variable to manage the loading indicator on the button.
  bool _loading = false;

  /// Attempts to sign in the user with the provided email and password
  /// using Supabase authentication.
  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMsg("Email and password required");
      return;
    }

    setState(() => _loading = true);
    try {
      // Call the Supabase sign-in method.
      final res = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
    // Check if the sign-in was successful (user object is present).
      if (res.user != null) {

// <<<<<<< Updated upstream
        Navigator.pushAndRemoveUntil(
// =======

        // Navigate to the main products page, replacing the current route.
        // Navigator.pushReplacement(

          context,
          MaterialPageRoute(builder: (_) => const ShopPage()),
              (route) => false,
        );
      } else {
        _showMsg("Invalid credentials");
      }
    } on AuthException catch (e) {
      _showMsg(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  /// Handles the action for the close button.
  ///
  /// It attempts to pop the current screen; if no screens are left,
  /// it exits the application.
  void _handleClose() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      body: Center(
        child: Stack(
          children: [
            // Allows the form content to be scrollable if needed.
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "SIGN IN",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Card-like container for the input form.
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xffe9eff0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email input field.
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                        ),
                        // Password input field.
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Password"),
                        ),
                        const SizedBox(height: 20),
                        // Sign In button. Disabled when loading.
                        ElevatedButton(
                          onPressed: _loading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006876),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          // Display "Loading..." text when authentication is in progress.
                          child: Text(_loading ? "Loading..." : "SIGN IN"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Button to navigate to the registration screen using the callback.
                  TextButton(
                    onPressed: widget.onRegisterClicked,
                    child: const Text("Don’t have an account? Register here"),
                  ),
                ],
              ),
            ),


            // ❌ close icon
            // Close icon button positioned absolutely on the top right.
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, size: 28),
                onPressed: _handleClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
