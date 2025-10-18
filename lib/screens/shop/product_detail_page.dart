import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? _product;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      final productData = await Supabase.instance.client
          .from('products')
          .select('id, name, description, price, image_url')
          .eq('id', widget.productId)
          .single();

      final reviewData = await Supabase.instance.client
          .from('reviews')
          .select('rating, comment, created_at, profiles(full_name)')
          .eq('product_id', widget.productId)
          .order('created_at', ascending: false);

      setState(() {
        _product = productData;
        _reviews = List<Map<String, dynamic>>.from(reviewData);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading product details: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add to cart')),
        );
        return;
      }

      // 1️⃣ Get or create user's cart
      final existingCart = await Supabase.instance.client
          .from('carts')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      String cartId;
      if (existingCart == null) {
        final newCart = await Supabase.instance.client
            .from('carts')
            .insert({'user_id': user.id})
            .select('id')
            .single();
        cartId = newCart['id'];
      } else {
        cartId = existingCart['id'];
      }

      // 2️⃣ Check if this product already exists in cart
      final existingItem = await Supabase.instance.client
          .from('cart_items')
          .select('id, quantity')
          .eq('cart_id', cartId)
          .eq('product_id', _product!['id'])
          .maybeSingle();

      if (existingItem != null) {
        // 3️⃣ Update quantity if product already in cart
        final newQty = (existingItem['quantity'] as int) + 1;
        await Supabase.instance.client
            .from('cart_items')
            .update({'quantity': newQty})
            .eq('id', existingItem['id']);
      } else {
        // 4️⃣ Insert new cart item
        await Supabase.instance.client.from('cart_items').insert({
          'cart_id': cartId,
          'product_id': _product!['id'],
          'quantity': 1,
          'unit_price': _product!['price'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Added to cart')),
      );
    } catch (e) {
      debugPrint("Add to cart failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to add to cart: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return const Scaffold(
        body: Center(child: Text("Product not found")),
      );
    }

    final imageUrl = _product!['image_url'] ??
        'https://via.placeholder.com/150x150.png?text=No+Image';

    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Color(0xff006876)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _product!['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff006876),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${_product!['price']}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _product!['description'] ?? "No description available.",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            const Text(
              "Reviews",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff006876),
              ),
            ),
            const SizedBox(height: 10),
            _reviews.isEmpty
                ? const Text("No reviews yet")
                : Column(
              children: _reviews.map((r) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(r['profiles']['full_name'] ?? 'Anonymous'),
                  subtitle: Text(r['comment'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                          (i) => Icon(
                        i < (r['rating'] ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: const Color(0xfffbc02d),
                        size: 18,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006876),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Add to Cart",
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
