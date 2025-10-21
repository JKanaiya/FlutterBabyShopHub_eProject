import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:babyshophub/main.dart';
=======
import 'package:supabase_flutter/supabase_flutter.dart';

// Global Supabase client instance for ease of access
final supabase = Supabase.instance.client;
>>>>>>> 513b849d90ea38071020a3ce6abb3be23880b453


/// A screen responsible for the final steps before placing an order.
///
/// It allows users to select a shipping address, choose a payment method,
/// view the order total, and confirm the purchase.
class CheckoutPage extends StatefulWidget {
  final String cartId;

  const CheckoutPage({super.key, required this.cartId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

  /// The ID of the current shopping cart being processed for checkout.
  bool _isLoading = true;
  List<Map<String, dynamic>> _addresses = [];
  String? _selectedAddressId;
  String? _selectedPayment;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Load necessary data (addresses and cart total) upon page initialization.
    _loadCheckoutData();
  }

  /// Fetches the user's saved shipping addresses and calculates the total
  /// amount of the items in the current cart.
  Future<void> _loadCheckoutData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to continue')),
        );
        return;
      }

      // 🏠 Fetch saved addresses
      final addressData = await supabase
          .from('addresses')
          .select('id, label, street, city, country, phone')
          .eq('user_id', user.id);

      // 🛒 Calculate total from cart_items
      final cartData = await supabase
          .from('cart_items')
          .select('quantity, unit_price')
          .eq('cart_id', widget.cartId);

      // Calculate the total from all cart items.
      double total = 0.0;
      for (final item in cartData) {
        total += (item['quantity'] as num) * (item['unit_price'] as num);
      }

      setState(() {
        _addresses = List<Map<String, dynamic>>.from(addressData);
        // Automatically select the first address if available.
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading checkout data: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Executes the multi-step process to finalize the transaction:
  /// 1. Creates a new entry in the `orders` table.
  /// 2. Transfers items from `cart_items` to `order_items`.
  /// 3. Clears the `cart_items`.
  /// 4. Navigates to the order summary page.
  Future<void> _placeOrder() async {

    // Validation checks.
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address')),
      );
      return;
    }

    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final user = supabase.auth.currentUser;

      // 🧾 1. Create order
      final orderInsert = await supabase
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
      final cartItems = await supabase
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

      await supabase.from('order_items').insert(orderItems);

      // 🧹 4. Clear cart after successful order
      await supabase.from('cart_items').delete().eq('cart_id', widget.cartId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.pushReplacementNamed(
        context,
        '/order_summary',
        arguments: orderId,
      );
    } catch (e) {
      debugPrint("Error placing order: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to place order')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Opens a dialog window to allow the user to input and save a new shipping address
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
            // Form fields for address details.
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: "Label"),
              ),
              TextField(
                controller: streetCtrl,
                decoration: const InputDecoration(labelText: "Street"),
              ),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: "City"),
              ),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final user = supabase.auth.currentUser;
              // Insert the new address into the 'addresses' table.
              await supabase.from('addresses').insert({
                'user_id': user!.id,
                'label': labelCtrl.text,
                'street': streetCtrl.text,
                'city': cityCtrl.text,
                'phone': phoneCtrl.text,
                'country': 'Kenya',
              });

              // Reload all checkout data to include the new address.
              Navigator.pop(context);
              _loadCheckoutData();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// Helper widget to generate a payment method RadioListTile with an image/logo.
  ///
  /// @param label The name of the payment method.
  /// @param logoPath The local asset path to the logo image.
  Widget _buildPaymentOption(String label, String logoPath) {
    return RadioListTile<String>(
      value: label,
      groupValue: _selectedPayment,
      onChanged: (val) => setState(() => _selectedPayment = val),
      activeColor: const Color(0xff006876),
      title: Row(
        children: [
          // Display the payment logo image.
          Image.asset(
            logoPath,
            height: 28,
            width: 28,
            // Fallback icon if the image asset fails to load
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.payment, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "CHECKOUT",
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
<<<<<<< HEAD
              const Text(
                "Shipping Address",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006876),
                ),
              ),
=======

              // --- Shipping Address Section ---
              const Text("Shipping Address",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff006876))),
>>>>>>> 513b849d90ea38071020a3ce6abb3be23880b453
              const SizedBox(height: 10),
              if (_addresses.isEmpty)
                const Text("No addresses found. Add one below."),
              // List of saved addresses, rendered as radio buttons.
              ..._addresses.map((addr) {
                return RadioListTile<String>(
                  value: addr['id'],
                  groupValue: _selectedAddressId,
                  onChanged: (val) => setState(() => _selectedAddressId = val),
                  title: Text(addr['label'] ?? "Address"),
                  subtitle: Text(
                    "${addr['street']}, ${addr['city']} - ${addr['country']}\n📞 ${addr['phone']}",
                  ),
                );
              }),
              const SizedBox(height: 10),
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, color: Color(0xff006876)),
                  label: const Text(
                    "Add Address",
                    style: TextStyle(color: Color(0xff006876)),
                  ),
                  onPressed: _addNewAddress,
                ),
              ),
              const SizedBox(height: 20),

              const Divider(),
              const SizedBox(height: 10),

              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006876),
                ),
              ),
              const SizedBox(height: 8),

              // 💳 Payment Options
              _buildPaymentOption("PayPal", "assets/images/Logos/paypal.png"),
              _buildPaymentOption("M-Pesa", "assets/images/Logos/mpesa.png"),
              _buildPaymentOption("Apple Pay", "assets/images/Logos/apple.png"),
              _buildPaymentOption(
                "Google Pay",
                "assets/images/Logos/google.png",
              ),

              const SizedBox(height: 25),

              // 📦 Order Summary Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff006876),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtotal calculation.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Subtotal",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text("\$${_totalAmount.toStringAsFixed(2)}"),
                        ],
                      ),
                      // Delivery cost (Hardcoded as Free).
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Delivery", style: TextStyle(fontSize: 16)),
                          Text("Free"),
                        ],
                      ),
                      const Divider(height: 20),

                      // Final Total Amount.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${_totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff006876),
                            ),
                          ),
                        ],
                      ),

                      // Place Order/Pay Button.
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006876),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Pay",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
