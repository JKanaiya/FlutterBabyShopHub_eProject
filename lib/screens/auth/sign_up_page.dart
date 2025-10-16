import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin/admin_index.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onLoginClicked;

  const SignUpPage({super.key, required this.onLoginClicked});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminKeyController = TextEditingController();

  bool _isAdmin = false;
  bool _loading = false;

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

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
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        if (_isAdmin) {
          const adminKey = "BABYSHOPP_ADMIN_2025";
          if (_adminKeyController.text.trim() == adminKey) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminIndex()),
            );
          } else {
            _showMsg("Invalid admin key");
          }
        } else {
          _showMsg("Sign up successful!");
          widget.onLoginClicked();
        }
      }
    } on AuthException catch (e) {
      _showMsg(e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:
                          const InputDecoration(labelText: "Password"),
                        ),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: "Confirm Password"),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _isAdmin,
                              onChanged: (v) => setState(() => _isAdmin = v!),
                            ),
                            const Text("Register as Admin"),
                          ],
                        ),
                        if (_isAdmin)
                          TextField(
                            controller: _adminKeyController,
                            obscureText: true,
                            decoration:
                            const InputDecoration(labelText: "Admin Key"),
                          ),
                        const SizedBox(height: 20),
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
                  TextButton(
                    onPressed: widget.onLoginClicked,
                    child: const Text("Already have an account? Sign in"),
                  ),
                ],
              ),
            ),
            // ❌ close icon
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
