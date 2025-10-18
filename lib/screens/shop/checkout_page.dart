import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final String cartId;

  const CheckoutPage({super.key, required this.cartId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _addresses = [];
  String? _selectedAddressId;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to continue')),
        );
        return;
      }

      // 🏠 Fetch saved addresses
      final addressData = await Supabase.instance.client
          .from('addresses')
          .select('id, label, street, city, country, phone')
          .eq('user_id', user.id);

      // 🛒 Calculate total from cart_items
      final cartData = await Supabase.instance.client
          .from('cart_items')
          .select('quantity, unit_price')
          .eq('cart_id', widget.cartId);

      double total = 0.0;
      for (final item in cartData) {
        total += (item['quantity'] as num) * (item['unit_price'] as num);
      }

      setState(() {
        _addresses = List<Map<String, dynamic>>.from(addressData);
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading checkout data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final user = Supabase.instance.client.auth.currentUser;

      // 🧾 1. Create order
      final orderInsert = await Supabase.instance.client
          .from('orders')
          .insert({
        'user_id': user!.id,
        'total_amount': _totalAmount,
        'currency': 'USD',
        'status': 'pending',
        'shipping_address_id': _selectedAddressId,
      })
          .select('id')
          .single();

      final orderId = orderInsert['id'];

      // 🧺 2. Fetch cart items
      final cartItems = await Supabase.instance.client
          .from('cart_items')
          .select('product_id, quantity, unit_price')
          .eq('cart_id', widget.cartId);

      // 🧩 3. Insert order items
      final orderItems = cartItems.map((item) {
        final subtotal =
            (item['quantity'] as num) * (item['unit_price'] as num);
        return {
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'unit_price': item['unit_price'],
          'subtotal': subtotal,
        };
      }).toList();

      await Supabase.instance.client.from('order_items').insert(orderItems);

      // 🧹 4. Clear cart after successful order
      await Supabase.instance.client
          .from('cart_items')
          .delete()
          .eq('cart_id', widget.cartId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.pushReplacementNamed(context, '/order_summary',
          arguments: orderId);
    } catch (e) {
      debugPrint("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addNewAddress() {
    TextEditingController labelCtrl = TextEditingController();
    TextEditingController streetCtrl = TextEditingController();
    TextEditingController cityCtrl = TextEditingController();
    TextEditingController phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Address"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: "Label")),
              TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: "Street")),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: "City")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final user = Supabase.instance.client.auth.currentUser;
              await Supabase.instance.client.from('addresses').insert({
                'user_id': user!.id,
                'label': labelCtrl.text,
                'street': streetCtrl.text,
                'city': cityCtrl.text,
                'phone': phoneCtrl.text,
                'country': 'Kenya'
              });
              Navigator.pop(context);
              _loadCheckoutData();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "CHECKOUT",
          style: TextStyle(
              color: Color(0xff006876),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Shipping Address",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff006876))),
            const SizedBox(height: 10),
            if (_addresses.isEmpty)
              const Text("No addresses found. Add one below."),
            ..._addresses.map((addr) {
              return RadioListTile<String>(
                value: addr['id'],
                groupValue: _selectedAddressId,
                onChanged: (val) {
                  setState(() => _selectedAddressId = val);
                },
                title: Text(addr['label'] ?? "Address"),
                subtitle: Text(
                    "${addr['street']}, ${addr['city']} - ${addr['country']}\n📞 ${addr['phone']}"),
              );
            }),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: Color(0xff006876)),
                label: const Text("Add Address",
                    style: TextStyle(color: Color(0xff006876))),
                onPressed: _addNewAddress,
              ),
            ),
            const Spacer(),
            Text(
              "Total: \$${_totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff006876),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Center(
                child: Text(
                  "Place Order",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
