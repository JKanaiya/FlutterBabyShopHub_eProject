import 'package:flutter/material.dart';
import 'package:babyshophub/main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _showAddresses = false;
  bool _showPayments = false;

  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('profiles')
          .select('full_name, phone')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        _nameController.text = data['full_name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      }

      await _fetchAddresses();
      await _fetchPayments();
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Delivery Addresses Management ---
  Future<void> _fetchAddresses() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final data = await supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id);
      setState(() => _addresses = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    }
  }

  Future<void> _addAddressDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Address"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter address"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = supabase.auth.currentUser;
              if (user != null && controller.text.trim().isNotEmpty) {
                await supabase.from('addresses').insert({
                  'user_id': user.id,
                  'address': controller.text.trim(),
                });
                Navigator.pop(context);
                _fetchAddresses();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006876),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- Payment Methods Management ---
  Future<void> _fetchPayments() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final data = await supabase
          .from('payment_methods')
          .select()
          .eq('user_id', user.id);
      setState(() => _payments = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
    }
  }

  Future<void> _addPaymentDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Payment Method"),
        content: TextField(
          controller: controller,
          decoration:
          const InputDecoration(hintText: "e.g. M-Pesa, PayPal, Visa ****1234"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = supabase.auth.currentUser;
              if (user != null && controller.text.trim().isNotEmpty) {
                await supabase.from('payment_methods').insert({
                  'user_id': user.id,
                  'method': controller.text.trim(),
                });
                Navigator.pop(context);
                _fetchPayments();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006876),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "EDIT PROFILE",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- Personal Info ---
              _buildInputField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline,
                validator: (v) =>
                v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                validator: (v) =>
                v == null || v.isEmpty ? 'Enter your phone number' : null,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 25),

              _buildExpandableSection(
                title: "Delivery Addresses",
                expanded: _showAddresses,
                onToggle: () => setState(() => _showAddresses = !_showAddresses),
                items: _addresses.map((a) => (a['address'] ?? '').toString()).toList().cast<String>(),
                onAdd: _addAddressDialog,
              ),
              const SizedBox(height: 20),

              // --- Payment Methods ---
              _buildExpandableSection(
                title: "Payment Methods",
                expanded: _showPayments,
                onToggle: () => setState(() => _showPayments = !_showPayments),
                items: _payments.map((p) => (p['method'] ?? '').toString()).toList().cast<String>(),
                onAdd: _addPaymentDialog,
              ),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006876),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Save Changes",
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
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff006876)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required List<String> items,
    required VoidCallback onAdd,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: (_) => onToggle(),
        title: Text(
          title,
          style: const TextStyle(
              color: Color(0xff006876), fontWeight: FontWeight.bold),
        ),
        children: [
          if (items.isEmpty)
            const ListTile(
              title: Text("No items added yet"),
            )
          else
            ...items
                .map((item) => ListTile(
              title: Text(item),
              trailing: const Icon(Icons.edit_outlined,
                  color: Colors.black45),
            ))
                .toList(),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Color(0xff006876)),
            label: const Text(
              "Add New",
              style: TextStyle(color: Color(0xff006876)),
            ),
          ),
        ],
      ),
    );
  }
}
