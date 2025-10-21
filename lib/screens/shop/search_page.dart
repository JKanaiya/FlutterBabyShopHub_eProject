import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A screen dedicated to searching products by name.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Get the Supabase client instance.
  final SupabaseClient supabase = Supabase.instance.client;
  // List to hold the products returned from the search query.
  List<Map<String, dynamic>> _results = [];
  // Stores the current text input by the user in the search field.
  String _query = "";

  /// Executes a search query against the 'products' table in Supabase.
  ///
  /// It uses the `ilike` operator for case-insensitive partial matching on the 'name' column.
  /// @param query The search term entered by the user.
  Future<void> _searchProducts(String query) async {
    // If the query is empty, clear the previous results.
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    // Execute the search query. The '%$query%' pattern enables wildcards
    // for finding matches anywhere in the product name.
    final data = await supabase
        .from('products')
        .select()
        .ilike('name', '%$query%');

    setState(() {
      // Update the state with the list of matching products.
      _results = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "Search Products",
          style: TextStyle(color: Color(0xff006876)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff006876)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Field
            TextField(
              onChanged: (val) {
                // Update the query state and immediately trigger a search.
                _query = val;
                _searchProducts(val);
              },
              decoration: const InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search, color: Color(0xff006876)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search Results Display Area
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text("No results"))
              // Display results in a scrollable list.
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final product = _results[index];
                  // Use placeholder image if the URL is missing.
                  final imageUrl = product['image_url'] ??
                      'https://via.placeholder.com/150x150.png?text=No+Image';
                  return ListTile(
                    // Product Image
                    leading: Image.network(imageUrl, width: 50),
                    // Product Name
                    title: Text(product['name']),
                    // Product Price
                    subtitle: Text("\$${product['price']}"),
                    // Navigate to the product detail page on tap.
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/product_detail',
                      arguments: product['id'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
