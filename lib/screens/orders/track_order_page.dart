import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TrackOrderPage extends StatefulWidget {
  final String orderId;
  const TrackOrderPage({super.key, required this.orderId});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    try {
      final data = await supabase
          .from('orders')
          .select('id, status, created_at, shipping_address_id')
          .eq('id', widget.orderId)
          .maybeSingle();

      setState(() {
        _order = data;
      });
    } catch (e) {
      debugPrint("Error fetching order: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProgressStep(String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? Color(0xff006876) : Colors.grey[300],
          child: Icon(isActive ? Icons.check : Icons.circle,
              color: isActive ? Colors.white : Colors.grey[600], size: 16),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: isActive ? Color(0xff006876) : Colors.grey,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _order?['status'] ?? 'pending';
    // define statuses progression
    final steps = ['pending', 'shipped', 'delivered'];

    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "Track Order",
          style: TextStyle(color: Color(0xff006876)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff006876)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Order #${widget.orderId}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // progress bar steps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: steps.map((step) {
                bool active = false;
                if (status == 'pending' && step == 'pending') active = true;
                else if (status == 'shipped' && (step == 'pending' || step == 'shipped'))
                  active = true;
                else if (status == 'delivered') active = true;

                return _buildProgressStep(step.toUpperCase(), active);
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text("Status Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              "Your order is currently *${status.toUpperCase()}*.\nWe will notify you when the status changes.",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
