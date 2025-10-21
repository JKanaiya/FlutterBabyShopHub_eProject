import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Global Supabase client instance for authenticated database operations.
final supabase = Supabase.instance.client;

/// A screen that displays the current user's shopping cart, allowing them
/// to view, modify item quantities, remove items, and proceed to checkout.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // List to hold the items currently in the cart.
  List<Map<String, dynamic>> _cartItems = [];
  // State to manage the loading indicator.
  bool _isLoading = true;
  // Calculated total cost of all items in the cart.
  double _total = 0.0;
  // The ID of the user's active cart in the 'carts' table.
  String? _cartId;

  @override
  void initState() {
    super.initState();
    // Start fetching cart data when the page loads.
    _fetchCartItems();
  }

  /// Fetches the user's active cart ID and then retrieves all items
  /// associated with that cart from Supabase.
  Future<void> _fetchCartItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // get user cart
      final cart = await supabase
      //Get the user's unique cart ID.
          .from('carts')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (cart == null) {
        // Handle case where user has no cart created yet.
        setState(() {
          _cartItems = [];
          _isLoading = false;
        });
        return;
      }

      _cartId = cart['id'];

      //Fetch all cart items linked to the cart ID, joining with product details.
      final data = await supabase
          .from('cart_items')
          .select('id, quantity, unit_price, products (id, name, image_url)')
          .eq('cart_id', _cartId!);

      setState(() {
        _cartItems = List<Map<String, dynamic>>.from(data);
        // Recalculate total after fetching items.
        _total = _calculateTotal();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching cart items: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Calculates the aggregate total price of all items currently in the cart.
  ///
  /// @returns The sum of (quantity * unit_price) for all items
  double _calculateTotal() {
    double total = 0.0;
    for (final item in _cartItems) {
      total += (item['quantity'] ?? 0) * (item['unit_price'] ?? 0);
    }
    return total;
  }

  /// Updates the quantity of a specific item in the database and locally.
  ///
  /// @param index The index of the item in the local list.
  /// @param newQuantity The new quantity to set for the item.
  Future<void> _updateQuantity(int index, int newQuantity) async {
    final item = _cartItems[index];
    // Prevent setting quantity to zero or less
    if (newQuantity < 1) return;

    try {
      // Update the quantity in the database.
      await supabase
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', item['id']);
      // Update the state to reflect the change immediately in the UI.
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

  /// Removes a cart item from the database and the local list.
  ///
  /// @param id The ID of the `cart_items` entry to delete.
  Future<void> _removeItem(int id) async {
    try {
      // Delete the item from the database.
      await supabase.from('cart_items').delete().eq('id', id);

      // Update the state to remove the item locally and recalculate the total
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

  /// Navigates the user to the checkout page, passing the current cart ID.
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
      arguments: _cartId,
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
      // Show empty message if cart has no items.
          ? const Center(child: Text("Your cart is empty"))
      // Build the list of cart items
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
                  // Product Image
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

                  // Product Name and Price
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

                  // Quantity Controls (Decrement/Increment)
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

                  // Remove Item Button
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

      // Fixed bottom bar displaying total and checkout button.
      bottomNavigationBar: _cartItems.isEmpty
          ? null
      // Hide bar if cart is empty.
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

            // Display Total Price
            Text(
              "Total: \$${_total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff006876),
              ),
            ),
            // Checkout Button
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
