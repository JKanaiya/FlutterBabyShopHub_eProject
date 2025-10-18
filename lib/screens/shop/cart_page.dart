import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  double _total = 0.0;
  String? _cartId; // ✅ store current user's cart ID

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // get user cart
      final cart = await supabase
          .from('carts')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (cart == null) {
        setState(() {
          _cartItems = [];
          _isLoading = false;
        });
        return;
      }

      _cartId = cart['id']; // ✅ save cartId

      final data = await supabase
          .from('cart_items')
          .select('id, quantity, unit_price, products (id, name, image_url)')
          .eq('cart_id', _cartId!);

      setState(() {
        _cartItems = List<Map<String, dynamic>>.from(data);
        _total = _calculateTotal();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching cart items: $e");
      setState(() => _isLoading = false);
    }
  }

  double _calculateTotal() {
    double total = 0.0;
    for (final item in _cartItems) {
      total += (item['quantity'] ?? 0) * (item['unit_price'] ?? 0);
    }
    return total;
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    final item = _cartItems[index];
    if (newQuantity < 1) return;

    try {
      await supabase
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', item['id']);

      setState(() {
        _cartItems[index]['quantity'] = newQuantity;
        _total = _calculateTotal();
      });
    } catch (e) {
      debugPrint("Error updating quantity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update quantity')),
      );
    }
  }

  Future<void> _removeItem(int id) async {
    try {
      await supabase.from('cart_items').delete().eq('id', id);
      setState(() {
        _cartItems.removeWhere((item) => item['id'] == id);
        _total = _calculateTotal();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed')),
      );
    } catch (e) {
      debugPrint("Error removing item: $e");
    }
  }

  void _goToCheckout() {
    if (_cartId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart not found')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: _cartId, // ✅ pass cartId to route
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "Your Cart",
          style: TextStyle(
            color: Color(0xff006876),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff006876)),
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
          final imageUrl = product?['image_url'] ??
              'https://via.placeholder.com/150';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?['name'] ?? 'Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "\$${item['unit_price']}",
                          style: const TextStyle(
                            color: Color(0xff006876),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _updateQuantity(
                            index, item['quantity'] - 1),
                      ),
                      Text(
                        "${item['quantity']}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _updateQuantity(
                            index, item['quantity'] + 1),
                      ),
                    ],
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red),
                    onPressed: () => _removeItem(item['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total: \$${_total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff006876),
              ),
            ),
            ElevatedButton(
              onPressed: _goToCheckout, // ✅ fixed navigation
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff006876),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Checkout",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
