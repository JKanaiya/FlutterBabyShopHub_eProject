import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackOrderPage extends StatefulWidget {
  final String orderId;
  const TrackOrderPage({super.key, required this.orderId});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic>? _address;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      // 🧾 Fetch order info
      final orderData = await Supabase.instance.client
          .from('orders')
          .select('*, addresses(*)')
          .eq('id', widget.orderId)
          .maybeSingle();

      // 🛍 Fetch items
      final itemData = await Supabase.instance.client
          .from('order_items')
          .select('quantity, unit_price, products(name, image_url)')
          .eq('order_id', widget.orderId);

      setState(() {
        _order = orderData;
        _address = orderData?['addresses'];
        _items = List<Map<String, dynamic>>.from(itemData);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading order: $e");
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProgress(String status) {
    final statuses = ['pending', 'shipped', 'delivered'];
    final activeIndex = statuses.indexOf(status);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: statuses.map((s) {
        final index = statuses.indexOf(s);
        final isActive = index <= activeIndex;
        return Column(
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isActive ? Colors.green : Colors.grey,
            ),
            Text(s.toUpperCase(),
                style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey,
                    fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (_order == null) {
      return const Scaffold(
        body: Center(child: Text("Order not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Order"),
        centerTitle: true,
        backgroundColor: const Color(0xff006876),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Order ID: ${_order!['id']}",
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProgress(_order!['status'] ?? 'pending'),
            const SizedBox(height: 20),
            const Divider(),
            const Text("Items:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ..._items.map((item) {
              final product = item['products'];
              return ListTile(
                leading: product['image_url'] != null
                    ? Image.network(
                  product['image_url'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
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
              "Shipping to: ${_address?['street']}, ${_address?['city']}, ${_address?['country']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Total: \$${_order!['total_amount'].toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
