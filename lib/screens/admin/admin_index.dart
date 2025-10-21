import 'package:babyshophub/screens/admin/admin_account.dart';
import 'package:babyshophub/screens/admin/admin_home.dart';
import 'package:babyshophub/screens/admin/admin_manage.dart';
import 'package:babyshophub/screens/admin/admin_products.dart';
import 'package:babyshophub/screens/admin/admin_search.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

/// The main index screen for the administrative interface.
///
/// This widget uses a `StatefulWidget` to manage the currently selected tab
/// and displays the corresponding administrative screen in the body.
class AdminIndex extends StatefulWidget {

  const AdminIndex({super.key});

  @override
  State<AdminIndex> createState() => _AdminIndexState();
}

class _AdminIndexState extends State<AdminIndex> {
  // State variable to track the index of the currently selected tab.
  int _selectedIndex = 0;

  /// Updates the selected index when a bottom navigation tab is tapped.
  /// @param index The index of the newly selected tab.
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// List of all administrative screens corresponding to the navigation tabs.
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
      // Display the widget corresponding to the currently selected index.
      body: _adminPages[_selectedIndex],
      bottomNavigationBar: Container(
        // Styling for the bottom bar container, adding a shadow for depth.
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
            // Using the GNav (Google Nav Bar) widget for the navigation layout.
          child: GNav(
            gap: 8,// Spacing between the icon and text in a selected tab
            // Spacing between the icon and text in a selected tab
            color: Theme.of(context).colorScheme.primary,
            // Background color for selected tab.
            tabBackgroundColor: Theme.of(context).colorScheme.primary,
            // Icon/text color for selected tab.
            activeColor: Theme.of(context).colorScheme.onPrimary,
            // Callback when a tab is selected.
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
