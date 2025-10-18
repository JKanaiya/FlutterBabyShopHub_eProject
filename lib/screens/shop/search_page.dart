import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _results = [];
  String _query = "";

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    final data = await supabase
        .from('products')
        .select()
        .ilike('name', '%$query%');

    setState(() {
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
            TextField(
              onChanged: (val) {
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
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text("No results"))
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final product = _results[index];
                  final imageUrl = product['image_url'] ??
                      'https://via.placeholder.com/150x150.png?text=No+Image';
                  return ListTile(
                    leading: Image.network(imageUrl, width: 50),
                    title: Text(product['name']),
                    subtitle: Text("\$${product['price']}"),
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
