import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shop/navigation.dart';
import '../products_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 0;
  int _cartCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final cart = await Supabase.instance.client
          .from('carts')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (cart == null) {
        setState(() {
          _cartCount = 0;
          _isLoading = false;
        });
        return;
      }

      final cartId = cart['id'];
      final items = await Supabase.instance.client
          .from('cart_items')
          .select('id')
          .eq('cart_id', cartId);

      setState(() {
        _cartCount = (items as List).length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading cart count: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
      // Shop
        break;
      case 1:
      // Search (future feature)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search coming soon!')),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/cart');
        break;
      case 3:
        Navigator.pushNamed(context, '/order_history');
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile coming soon!')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "BABYSHOPHUB",
          style: TextStyle(
            color: Color(0xff006876),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const ProductsPage(), // Displays all products
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        cartCount: _cartCount,
      ),
    );
  }
}
