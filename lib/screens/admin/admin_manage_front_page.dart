import 'package:babyshophub/screens/admin/admin_view_orders.dart';
import 'package:babyshophub/screens/products_page.dart';
import 'package:babyshophub/screens/profile/profile_page.dart';
import 'package:babyshophub/screens/splash_screen.dart';
import 'package:babyshophub/screens/user_support/user_support_tickets.dart';
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

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> adminPages = [
      SplashScreen(onNavigate: setSelectedIndex),
      ProductsPage(),
      AdminViewOrders(),
      UserSupportTicket(),
      ProfilePage(),
    ];
    return Scaffold(
      body: adminPages[_selectedIndex],
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
              GButton(icon: Icons.manage_search, text: "Orders", iconSize: 30),
              GButton(
                icon: Icons.support_agent_rounded,
                text: "Tickets",
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
