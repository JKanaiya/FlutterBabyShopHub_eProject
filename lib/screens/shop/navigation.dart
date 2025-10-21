import 'package:flutter/material.dart';


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
    return BottomNavigationBar(
      // The index corresponding to the currently active tab.
      currentIndex: currentIndex,
      // The function to call when a navigation item is selected.
      onTap: onTap,
      // Styling for the selected item's icon and label

      selectedItemColor: const Color(0xff006876),
      // Styling for unselected items
      unselectedItemColor: Colors.grey,
      // Ensures all items are visible even with many tabs.
      type: BottomNavigationBarType.fixed,
      // Hides the labels for unselected items for a cleaner look
      showUnselectedLabels: false,
      // The list of items displayed in the navigation bar.
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: "Cart"),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: "Orders"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}
