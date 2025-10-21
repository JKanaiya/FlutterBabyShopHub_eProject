import 'package:babyshophub/screens/orders/track_order_page.dart';
import 'package:flutter/material.dart';
import '../products_page.dart';
import '../shop/cart_page.dart';
import '../profile/profile_page.dart';
import '../shop/search_page.dart';
import '../shop/navigation.dart';

/// The main container widget for the application's core functionality.
///
/// This widget manages the state for the bottom navigation bar, switching
/// between different primary screens (Home, Search, Cart, Orders, Profile).
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // State variable to track the index of the currently selected tab/screen.
  int _currentIndex = 0;

  // List of all screens corresponding to the bottom navigation bar items.
  final List<Widget> _pages = const [
    ProductsPage(),//Home/Product
    SearchPage(),//Search
    CartPage(),//Cart
    TrackOrderPage(orderId: ''),//Orders
    ProfilePage(),//profile
  ];

  /// Callback function passed to the CustomNavBar to handle tab changes.
  ///
  /// @param index The index of the newly selected tab.
  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body displays the widget corresponding to the current index
      body: _pages[_currentIndex],
      // The fixed bottom navigation bar widget.
      bottomNavigationBar: CustomNavBar(

        currentIndex: _currentIndex,
        // Link the navigation tap event to the state update function.
        onTap: _onNavTap,
      ),
    );
  }
}