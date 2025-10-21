import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Global Supabase client instance.
final supabase = Supabase.instance.client;

/// A screen that displays the detailed information for a single product.
///
/// Includes product data, a description, customer reviews, and functionality
/// to add the item to the cart and leave a comment.
class ProductDetailPage extends StatefulWidget {
  /// The unique identifier of the product to display.
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // State variables to hold product data, reviews, and UI status.

  Map<String, dynamic>? _product;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  // Controller for the user's comment input field.
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch product details and reviews immediately on screen load.
    _loadProductDetails();
  }

  /// Fetches the product's main information from Supabase and initializes dummy reviews
  Future<void> _loadProductDetails() async {
    try {

      /// Fetches the product's main information from Supabase and initializes dummy reviews
      final productData = await supabase
          .from('products')
          .select('id, name, description, price, image_url')
          .eq('id', widget.productId)
          .maybeSingle();

      // Dummy review data for demonstration purposes (replace with Supabase query for 'reviews' table).
      final dummyReviews = [
        {
          'username': 'Grace W.',
          'rating': 5,
          'comment': 'Amazing quality! My baby loves this.',
          'created_at': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'username': 'Peter N.',
          'rating': 4,
          'comment': 'Good product but delivery took a bit long.',
          'created_at': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'username': 'Joy K.',
          'rating': 5,
          'comment': 'Super soft and great value for money!',
          'created_at': DateTime.now().subtract(const Duration(days: 4)),
        },
      ];

      setState(() {
        _product = productData;
        _reviews = dummyReviews;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading product details: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Adds a new user comment locally (simulating a review submission).
  ///
  /// In a real application, this would involve inserting the comment into a
  /// 'reviews' or 'comments' table in Supabase.
  ///
  Future<void> _addComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final user = supabase.auth.currentUser;

// <<<<<<< Updated upstream
//     // TODO: replace with actual functionality
// =======
//     // Insert the new comment at the beginning of the local list.
// >>>>>>> Stashed changes
    setState(() {
      _reviews.insert(0, {
        'username': user?.email ?? 'Anonymous',
        'rating': 5, //hardcoded rating for simplicity
        'comment': comment,
        'created_at': DateTime.now(),
      });
      // Clear the input field.
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment added successfully!')),
    );
  }

  /// Handles the logic for adding the current product to the user's shopping cart.
  ///
  /// It ensures a cart exists for the user (creating one if necessary) and then
  /// inserts the product as a new item into the `cart_items` table
  Future<void> _addToCart() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add to cart')),
        );
        return;
      }

      // Get or create cart
      final existingCart = await supabase
          .from('carts')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      String cartId;
      if (existingCart == null) {
        final newCart = await supabase
            .from('carts')
            .insert({'user_id': user.id})
            .select('id')
            .single();
        cartId = newCart['id'];
      } else {
        cartId = existingCart['id'];
      }

      //  Insert the product as a new item into the cart.
      // Add item
      await supabase.from('cart_items').insert({
        'cart_id': cartId,
        'product_id': widget.productId,
        'quantity': 1,
        'unit_price': _product?['price'] ?? 0,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to cart')));
    } catch (e) {
      debugPrint("Add to cart failed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return const Scaffold(body: Center(child: Text("Product not found")));
    }
// <<<<<<< Updated upstream

//     final imageUrl = _product!['image_url'] ??
// =======
    // Use a placeholder image if the URL is null or empty.
    final imageUrl = _product!['image_url'] ??
// >>>>>>> Stashed changes
        'https://via.placeholder.com/300x300.png?text=No+Image';

    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: Text(
          _product!['name'] ?? '',
          style: const TextStyle(
            color: Color(0xff006876),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff006876)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼 Product Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 💲 Name + Price + Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _product!['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Color(0xffffc107), size: 20),
                      SizedBox(width: 4),
                      Text(
                        "4.8",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text(
                "\$${_product!['price']}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xff006876),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // 📄 Description
              Text(
                _product!['description'] ??
                    'This is a high-quality baby product perfect for everyday use.',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // 🛒 Add to Cart Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text("Add to Cart"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006876),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ⭐ Reviews Section
              const Text(
                "Customer Reviews",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006876),
                ),
              ),
              const SizedBox(height: 10),

              ..._reviews.map((r) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              r['username'] ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < (r['rating'] ?? 0)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: const Color(0xffffc107),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r['comment'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          r['created_at']
                              .toString()
                              .split(' ')
                              .first, // show only date
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // ✍️ Comment Input Bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xff006876)),
              onPressed: _addComment,
            ),
          ],
        ),
      ),
    );
  }
}
