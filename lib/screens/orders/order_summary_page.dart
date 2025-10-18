import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'track_order_page.dart';

class OrderSummaryPage extends StatefulWidget {
  final String orderId;

  const OrderSummaryPage({super.key, required this.orderId});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderSummary();
  }

  Future<void> _fetchOrderSummary() async {
    try {
      // Fetch order info + shipping address
      final orderData = await Supabase.instance.client
          .from('orders')
          .select('*, addresses(*)')
          .eq('id', widget.orderId)
          .maybeSingle();

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return const Scaffold(
        body: Center(child: Text("Order not found")),
      );
    }

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
              child: Icon(Icons.check_circle,
                  size: 80, color: Colors.greenAccent),
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
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const Text(
              "Order Items",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ..._items.map((item) {
              final product = item['products'];
              return ListTile(
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
                title: Text(product['name']),
                subtitle: Text(
                    "${item['quantity']} × \$${item['unit_price'].toStringAsFixed(2)}"),
              );
            }),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              "Shipping to:",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
                "${address?['street'] ?? ''}, ${address?['city'] ?? ''}, ${address?['country'] ?? ''}"),
            const SizedBox(height: 15),
            Text(
              "Total Amount: \$${_order!['total_amount'].toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff006876),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          TrackOrderPage(orderId: widget.orderId)),
                );
              },
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text("Track My Order"),
            ),
            const SizedBox(height: 10),
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
