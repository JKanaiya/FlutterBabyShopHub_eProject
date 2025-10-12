import 'package:babyshophub/screens/admin/admin_account.dart';
import 'package:babyshophub/screens/admin/admin_home.dart';
import 'package:babyshophub/screens/admin/admin_manage.dart';
import 'package:babyshophub/screens/admin/admin_products.dart';
import 'package:babyshophub/screens/admin/admin_search.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AdminIndex extends StatefulWidget {
  const AdminIndex({super.key});

  @override
  State<AdminIndex> createState() => _AdminIndexState();
}

class _AdminIndexState extends State<AdminIndex> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _adminPages = [
    AdminHome(),
    AdminSearch(),
    AdminProducts(),
    AdminManage(),
    AdminAccount(),
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
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: GNav(
            gap: 8,
            color: Theme.of(context).colorScheme.primary,
            tabBackgroundColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.onPrimary,
            onTabChange: _navigateBottomBar,
            padding: EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.home_filled, text: "Home", iconSize: 30),
              GButton(icon: Icons.search, text: "Search", iconSize: 30),
              GButton(icon: Icons.local_mall, text: "Products", iconSize: 30),
              GButton(icon: Icons.manage_search, text: "Manage", iconSize: 30),
              GButton(icon: Icons.person, text: "Account", iconSize: 30),
            ],
          ),
        ),
      ),
    );
  }
}
