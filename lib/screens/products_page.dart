import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchCategories();
    await _fetchProducts();
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await supabase.from('categories').select().order('id');
      setState(() {
        _categories = <Map<String, dynamic>>[{'id': null, 'name': 'All'}]
          ..addAll(List<Map<String, dynamic>>.from(data));
      });
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() {
        _categories = <Map<String, dynamic>>[{'id': null, 'name': 'All'}];
      });
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);

    try {
      var query = supabase.from('products').select().eq('is_active', true);

      if (_selectedCategory != 'All') {
        final cat = _categories.firstWhere(
              (c) => c['name'] == _selectedCategory,
          orElse: () => {},
        );
        if (cat.isNotEmpty && cat['id'] != null) {
          query = query.eq('category_id', cat['id']);
        }
      }

      if (_searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$_searchQuery%');
      }

      final data = await query.order('created_at', ascending: false);
      setState(() {
        _products = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() => _products = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add items to cart')),
        );
        return;
      }

      // Get or create a cart for this user
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

      // Add or update item
      await supabase.from('cart_items').insert({
        'cart_id': cartId,
        'product_id': product['id'],
        'quantity': 1,
        'unit_price': product['price'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} added to cart!')),
      );
    } catch (e) {
      debugPrint('Add to cart failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to cart')),
      );
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _fetchProducts();
  }

  void _onCategorySelected(String categoryName) {
    setState(() => _selectedCategory = categoryName);
    _fetchProducts();
  }

  int _gridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "BABYSHOPHUB",
          style: TextStyle(
            color: Color(0xff006876),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Column(
            children: [
              // 🔍 Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12.withOpacity(0.03), blurRadius: 6),
                  ],
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: Color(0xff006876)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🏷 Categories (scrollable horizontally)
              SizedBox(
                height: 48,
                child: _categories.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final name = cat['name'] ?? 'All';
                    final isSelected = name == _selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => _onCategorySelected(name),
                        selectedColor: const Color(0xff006876),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 🛍 Product Grid
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _products.isEmpty
                    ? const Center(child: Text("No products available"))
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _gridCrossAxisCount(context);
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final imageUrl = product['image_url'] ??
                            'https://via.placeholder.com/150';
                        final rating = (product['rating'] ?? 4.5).toDouble();

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/product_detail',
                              arguments: product['id'],
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    // Product image
                                    ClipRRect(
                                      borderRadius:
                                      const BorderRadius.vertical(top: Radius.circular(14)),
                                      child: Image.network(
                                        imageUrl,
                                        height: constraints.maxWidth / (crossAxisCount * 1.9),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // ⭐ Rating overlay top-right
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                color: Color(0xfffbc02d), size: 16),
                                            const SizedBox(width: 3),
                                            Text(
                                              rating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // 🏷 Product info
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xff006876),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "\$${product['price']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_shopping_cart,
                                                color: Color(0xff006876)),
                                            onPressed: () => _addToCart(product),
                                            tooltip: 'Add to cart',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
