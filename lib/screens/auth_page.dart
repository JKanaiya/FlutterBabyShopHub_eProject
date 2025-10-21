import 'package:flutter/material.dart';
import 'auth/sign_up_page.dart';
import 'auth/sign_in_page.dart';

/// A container widget that acts as a switch between the SignInPage and SignUpPage.
///
/// It holds the state necessary to determine which authentication form to display.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // State variable to control which page is currently visible.
  // True means SignInPage is shown; False means SignUpPage is shown.
  bool showSignIn = true;
  /// Toggles the value of `showSignIn`, triggering a rebuild of the widget
  /// to switch between the sign-in and sign-up screens
  void togglePage() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    // Conditional rendering based on the `showSignIn` state.
    return showSignIn
        // If true, show the SignInPage and pass the toggle function
    // so it can switch to the SignUpPage when the user clicks 'Register'.
        ? SignInPage(onRegisterClicked: togglePage)
    // If false, show the SignUpPage and pass the toggle function
    // so it can switch back to the SignInPage when the user clicks 'Login'.
        : SignUpPage(onLoginClicked: togglePage);
  }
}