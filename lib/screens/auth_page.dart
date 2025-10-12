import 'package:babyshophub/screens/admin/admin_index.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'products_page.dart';
import 'profile_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //Added new admin controller and status
  final _adminController = TextEditingController();
  bool _isAdmin = false;
  //override dispose to hide or dispose the admin textfiled if the checkbox has not been checked
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _adminController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password required")),
      );
      return;
    }

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signup success! Profile created automatically."),
          ),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup failed: ${e.message}")));
    }
  }

  Future<void> _signIn() async {
    final res = await Supabase.instance.client.auth.signInWithPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProductsPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login failed")));
    }
  }

  //Added admin navigation logic
  Future<void> _navigateToAdmin() async {
    //TODO: change this hard coded key and enable access of it from the supabase storage
    const String secretAdminKey = 'BABYSHOPP_ADMIN_2025';

    final enteredKey = _adminController.text.trim();

    if (enteredKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the admin key')),
      );
      return;
    }
    if (enteredKey == secretAdminKey) {
      Navigator.pushReplacement(
        //navigates to the proguct page for To do navigate to the correct admin page
        context,
        MaterialPageRoute(builder: (_) => const AdminIndex()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access denied invalid key')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signUp, child: const Text("Sign Up")),
            ElevatedButton(onPressed: _signIn, child: const Text("Sign In")),
            const SizedBox(height: 20),
            //Added the checkbox for the admin to access the textfield for the key
            Row(
              children: [
                Checkbox(
                  value: _isAdmin,
                  onChanged: (bool? newValue) {
                    {
                      setState(() {
                        _isAdmin = newValue ?? false;
                      });
                    }
                  },
                ),
                const Text('Admin section'),
              ],
            ),

            //thus display the admin key field
            if (_isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: TextField(
                  controller: _adminController,
                  decoration: const InputDecoration(
                    labelText: 'Admin Key',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                ),
              ),
            //button to navigate to admin page
            if (_isAdmin)
              ElevatedButton.icon(
                onPressed: _navigateToAdmin,
                icon: const Icon(Icons.security),
                label: const Text("Access admin Panel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: const Text("Go to Profile Page"),
            ),
          ],
        ),
      ),
    );
  }
}
