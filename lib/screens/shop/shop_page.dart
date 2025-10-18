import 'package:babyshophub/screens/orders/track_order_page.dart';
import 'package:flutter/material.dart';
import '../products_page.dart';
import '../shop/cart_page.dart';
// import '../profile/profile_page.dart';
import '../shop/search_page.dart';
import '../shop/navigation.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ProductsPage(),
    SearchPage(),
    CartPage(),
    TrackOrderPage(orderId: ''),
    // ProfilePage(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
