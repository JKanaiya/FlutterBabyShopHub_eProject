import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

/// A custom stateless widget for the application's bottom navigation bar.
///
/// This component provides a fixed navigation mechanism with specific styling
/// and defined icons for key application screens.
class CustomNavBar extends StatelessWidget {
  /// The index of the currently selected tab.
  final int currentIndex;

  /// The callback function triggered when a tab is tapped, providing the new index.
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          gap: 8, // Spacing between the icon and text in a selected tab
          // Spacing between the icon and text in a selected tab
          color: Theme.of(context).colorScheme.primary,
          // Background color for selected tab.
          tabBackgroundColor: Theme.of(context).colorScheme.primary,
          // Icon/text color for selected tab.
          activeColor: Theme.of(context).colorScheme.onPrimary,
          // Callback when a tab is selected.
          onTabChange: onTap,
          padding: EdgeInsets.all(16),
          tabs: const [
            GButton(icon: Icons.home_filled, text: "Home", iconSize: 30),
            GButton(icon: Icons.search, text: "Search", iconSize: 30),
            GButton(
              icon: Icons.shopping_cart_outlined,
              text: "Cart",
              iconSize: 30,
            ),
            GButton(
              icon: Icons.local_shipping_outlined,
              text: "Orders",
              iconSize: 30,
            ),
            GButton(icon: Icons.person_outline, text: "Profile", iconSize: 30),
          ],
        ),
      ),
    );
  }
}
    // BottomNavigationBar(
    //   // The index corresponding to the currently active tab.
    //   currentIndex: currentIndex,
    //   // The function to call when a navigation item is selected.
    //   onTap: onTap,
    //
    //   // Styling for the selected item's icon and label
    //   selectedItemColor: const Color(0xff006876),
    //   // Styling for unselected items
    //   unselectedItemColor: Colors.grey,
    //   // Ensures all items are visible even with many tabs.
    //   type: BottomNavigationBarType.fixed,
    //   // Hides the labels for unselected items for a cleaner look
    //   showUnselectedLabels: false,
    //   // The list of items displayed in the navigation bar.
    //   items: const [
    //     BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
    //     BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.shopping_cart_outlined),
    //       label: "Cart",
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.local_shipping_outlined),
    //       label: "Orders",
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.person_outline),
    //       label: "Profile",
    //     ),
    //   ],
    // );
