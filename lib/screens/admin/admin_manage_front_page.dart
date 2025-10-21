import 'package:babyshophub/screens/admin/admin_products.dart';
import 'package:babyshophub/screens/products_page.dart';
import 'package:babyshophub/screens/profile/profile_page.dart';
import 'package:babyshophub/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AdminManageFrontPage extends StatefulWidget {
  const AdminManageFrontPage({super.key});

  @override
  State<AdminManageFrontPage> createState() => _AdminManageFrontPageState();
}

class _AdminManageFrontPageState extends State<AdminManageFrontPage> {
  // TODO: Add a method and var to hold the splash screen text
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _adminPages = [
    SplashScreen(),
    ProductsPage(),
    AdminProducts(),
    ProfilePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _adminPages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 7,
              blurRadius: 7,
              offset: Offset(0, 3),
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: GNav(
            gap: 8,
            color: Theme.of(context).colorScheme.primary,
            tabBackgroundColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.onPrimary,
            onTabChange: _navigateBottomBar,
            padding: EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.home_filled, text: "Home", iconSize: 30),
              GButton(icon: Icons.search, text: "Shop", iconSize: 30),
              GButton(icon: Icons.manage_search, text: "Tickets", iconSize: 30),
              GButton(
                icon: Icons.support_agent_rounded,
                text: "Support",
                iconSize: 30,
              ),
              GButton(icon: Icons.person, text: "Account", iconSize: 30),
            ],
          ),
        ),
      ),
    );
  }
}
