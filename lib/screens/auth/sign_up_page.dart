import 'package:babyshophub/screens/admin/admin_manage_front_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A screen for user registration (Sign Up) with email and password.
///
/// It includes an optional field for admin registration using a secret key.
class SignUpPage extends StatefulWidget {
  /// Callback function to navigate back to the sign-in screen upon successful registration.
  final VoidCallback onLoginClicked;

  const SignUpPage({super.key, required this.onLoginClicked});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text editing controllers for capturing user input.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminKeyController = TextEditingController();
// State variables to manage the registration mode and UI feedback.
  bool _isAdmin = false;
  bool _loading = false;
  /// Handles the user registration process.
  ///
  /// Performs input validation (empty fields, password match) and calls
  /// Supabase to create a new user. It handles different navigation
  /// based on whether the user is registering as a regular user or an admin.
  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // Input validation check.
    if (email.isEmpty || password.isEmpty) {
      _showMsg("Please fill all fields");
      return;
    }

    if (password != confirm) {
      _showMsg("Passwords do not match");
      return;
    }

    setState(() => _loading = true);
    try {
      // Call the Supabase sign-up method to create the user.
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // --- Admin Registration Check ---
        if (_isAdmin) {
          const adminKey = "BABYSHOPP_ADMIN_2025";
          // Check if the provided admin key matches the hardcoded key.
          if (_adminKeyController.text.trim() == adminKey) {
            // If key is valid, navigate to the Admin dashboard.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminManageFrontPage()),
            );
          } else {
            // If key is invalid, show error message.
            _showMsg("Invalid admin key");
          }
        } else {
          // --- Regular User Registration ---
          _showMsg("Sign up successful!");
          widget.onLoginClicked();
        }
      }
    } on AuthException catch (e) {
      // Handle and display specific Supabase authentication errors (e.g., user already exists).
      _showMsg(e.message);
    } finally {
      setState(() => _loading = false);
    }
  }
  /// Displays a message to the user using a SnackBar at the bottom of the screen.
  ///
  /// @param msg The string message to be displayed.
  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  /// Handles the action for the close button.
  ///
  /// Pops the current screen if possible, otherwise closes the application.
  void _handleClose() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop(); // exits app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "SIGN UP",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Form container with styling.
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
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email Input
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                        ),
                        // Password Input
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                          ),
                        ),
                        //  Confirm password Input
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Confirm Password",
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Admin Checkbox and text label.
                        Row(
                          children: [
                            Checkbox(
                              value: _isAdmin,
                              // Toggle the admin state when the checkbox is tapped.
                              onChanged: (v) => setState(() => _isAdmin = v!),
                            ),
                            const Text("Register as Admin"),
                          ],
                        ),
                        // Admin Key field shown conditionally based on _isAdmin state.
                        if (_isAdmin)
                          TextField(
                            controller: _adminKeyController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Admin Key",
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Sign Up button. Disabled when _loading is true.
                        ElevatedButton(
                          onPressed: _loading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006876),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: Text(_loading ? "Loading..." : "SIGN UP"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Text button to navigate to the Sign In page.
                  TextButton(
                    onPressed: widget.onLoginClicked,
                    child: const Text("Already have an account? Sign in"),
                  ),
                ],
              ),
            ),
            // ❌ close icon
            // Close icon button for easy dismissal.
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
