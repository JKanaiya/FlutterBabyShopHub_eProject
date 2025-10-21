import 'package:flutter/material.dart';
import 'package:babyshophub/main.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // State variable to manage the loading indicator display
  bool _isLoading = true;
  // List to hold the fetched order data from the database.
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    // Start fetching order data immediately when the widget is initialized.
    _fetchOrders();
  }

  /// Fetches the order history for the currently authenticated user from Supabase.
  Future<void> _fetchOrders() async {
    final user = supabase.auth.currentUser;
    // If no user is logged in, stop the function.
    if (user == null) return;

    try {
      // Query the 'orders' table for the current user's orders.
      final data = await supabase
          .from('orders')
          .select('id, total_amount, status, created_at')
          // Order by creation date, newest first.
          .order('created_at', ascending: false);

      setState(() {
        _orders = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      // Print error details for debugging purposes.
      debugPrint("Error fetching orders: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Returns a specific color based on the order status string.
  ///
  /// @param s The status string (e.g., 'delivered', 'shipped').
  /// @returns A Material color associated with the status.
  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.orange;
      case 'processing':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(
            color: Color(0xff006876),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff006876)),
      ),
      body: _isLoading
          // Display a progress indicator while data is being fetched.
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          // Display a message if the orders list is empty.
          ? const Center(child: Text("No past orders yet"))
          // Use a ListView.builder to efficiently display the list of orders.
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, idx) {
                final order = _orders[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      "Order #${order['id'].toString().substring(0, 8)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      // Format date and total amount for the subtitle.
                      "Date: ${order['created_at'].toString().split('T').first}\n"
                      "Total: \$${order['total_amount']}",
                    ),
                    // Display the order status as a colored badge on the right
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(order['status'] ?? ''),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order['status']?.toUpperCase() ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Navigate to the detailed order tracking page when tapped.
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/track_order',
                        arguments: order['id'],
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
