import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'track_order_page.dart';

/// A screen that displays the details of a successfully placed order.
///
/// It shows the order ID, a list of items, shipping address, total amount,
/// and buttons for tracking the order or navigating home.
class OrderSummaryPage extends StatefulWidget {
  /// The unique identifier of the order to be displayed.
  final String orderId;

  const OrderSummaryPage({super.key, required this.orderId});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  // State variable to control the display of the loading indicator.
  bool _isLoading = true;

  // Map to hold the main order details and nested address data.
  Map<String, dynamic>? _order;

  // List to hold the individual products (items) within the order.
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    // Start fetching all necessary order data immediately.
    _fetchOrderSummary();
  }

  /// Fetches the complete order details (order header, shipping address, and items)
  /// from Supabase using two separate queries.
  Future<void> _fetchOrderSummary() async {
    try {
      // Fetch order info + shipping address
      final orderData = await Supabase.instance.client
          .from('orders')
          // Select all fields from orders and join with the addresses table
          .select('*, addresses(*)')
          .eq('id', widget.orderId)
          .maybeSingle();

      print(orderData);
      // Fetch items in the order
      final itemData = await Supabase.instance.client
          .from('order_items')
          .select('quantity, unit_price, products(name, image_url)')
          .eq('order_id', widget.orderId);

      setState(() {
        _order = orderData;
        _items = List<Map<String, dynamic>>.from(itemData);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching order summary: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading screen while data is being fetched.
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Show a "not found" screen if the fetch succeeded but returned no data.
    if (_order == null) {
      return const Scaffold(body: Center(child: Text("Order not found")));
    }
    // Extract the shipping address map for easier access.
    final address = _order?['addresses'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Summary"),
        centerTitle: true,
        backgroundColor: const Color(0xff006876),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "Order Placed Successfully!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Order ID: ${_order!['id']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Order Items",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Dynamically generate ListTile for each product item using the spread operator.
            ..._items.map((item) {
              final product = item['products'];
              return ListTile(
                // Product image or placeholder.
                leading: product['image_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['image_url'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image_not_supported),
                // Product name.
                title: Text(product['name']),
                // Quantity and unit price.
                subtitle: Text(
                  "${item['quantity']} × \$${item['unit_price'].toStringAsFixed(2)}",
                ),
              );
            }),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              // Shipping Address details.
              "Shipping to:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "${address?['street'] ?? ''}, ${address?['city'] ?? ''}, ${address?['country'] ?? ''}",
            ),
            const SizedBox(height: 15),
            // Final Total Amount prominently displayed.
            Text(
              "Total Amount: \$${_order!['total_amount'].toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            // Button to navigate to the order tracking page.
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff006876),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              // Navigate and replace the current page to prevent users from returning to the summary.
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackOrderPage(orderId: widget.orderId),
                  ),
                );
              },
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text("Track My Order"),
            ),
            const SizedBox(height: 10),
            // Button to navigate back to the root of the app (Home).
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xff006876)),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
