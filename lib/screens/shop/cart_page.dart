import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shop/navigation.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _currentIndex = 2;
  bool _isLoading = true;
  List<Map<String, dynamic>> _cartItems = [];
  double _total = 0.0;
  String? _cartId;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please log in first')));
        return;
      }

      // 1️⃣ Get or create cart for this user
      final existingCart = await Supabase.instance.client
          .from('carts')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      String cartId;
      if (existingCart == null) {
        final newCart = await Supabase.instance.client
            .from('carts')
            .insert({'user_id': user.id})
            .select('id')
            .single();
        cartId = newCart['id'];
      } else {
        cartId = existingCart['id'];
      }

      _cartId = cartId;

      // 2️⃣ Fetch cart items joined with products
      final data = await Supabase.instance.client
          .from('cart_items')
          .select('id, quantity, unit_price, products(id, name, price, image_url)')
          .eq('cart_id', cartId);

      final List<Map<String, dynamic>> items =
      List<Map<String, dynamic>>.from(data);

      double total = 0.0;
      for (final item in items) {
        final price = (item['unit_price'] as num).toDouble();
        final qty = (item['quantity'] as num).toDouble();
        total += price * qty;
      }

      setState(() {
        _cartItems = items;
        _total = total;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading cart: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeItem(int itemId) async {
    try {
      await Supabase.instance.client
          .from('cart_items')
          .delete()
          .eq('id', itemId);

      _loadCart();
    } catch (e) {
      debugPrint("Error removing item: $e");
    }
  }

  Future<void> _checkout() async {
    Navigator.pushNamed(context, '/checkout', arguments: _cartId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "MY CART",
          style: TextStyle(
              color: Color(0xff006876),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final item = _cartItems[index];
          final product = item['products'];
          final imageUrl = product['image_url'] ??
              'https://via.placeholder.com/150x150.png?text=No+Image';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "\$${product['price']}",
                          style: const TextStyle(
                            color: Color(0xff006876),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text("Qty: ${item['quantity']}"),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  _removeItem(item['id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        height: 90,
        color: Colors.white,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: \$${_total.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ElevatedButton(
                onPressed: _cartItems.isEmpty ? null : _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006876),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Checkout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
