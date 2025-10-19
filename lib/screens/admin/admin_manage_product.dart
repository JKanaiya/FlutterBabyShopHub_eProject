import 'package:babyshophub/screens/admin/edit_product.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:babyshophub/main.dart';

class AdminProductManage extends StatefulWidget {
  final int productId;
  AdminProductManage({super.key, required this.productId});

  @override
  State<AdminProductManage> createState() => _AdminProductManageState();
}

class _AdminProductManageState extends State<AdminProductManage> {
  Map<String, dynamic>? _product;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _loadProductDetails() async {
    try {
      final productData = await supabase
          .from('products')
          .select('id, name, description, price, image_url')
          .eq('id', widget.productId)
          .maybeSingle();

      setState(() {
        _product = productData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading product details: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  @override
  // TODO: replace the text with the product data from supabase
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
      }
    }

    final imageUrl =
        _product?['image_url'] ??
        'https://via.placeholder.com/300x300.png?text=No+Image';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HSLColor.fromAHSL(0, 197, 0.28, 0.95).toColor(),
        titleSpacing: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.west,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProduct(
                    price: _product?['price'],
                    description: _product?['description'],
                    id: _product?['id'],
                    name: _product?['name'],
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
        ],
        title: Text(
          _product?['name'],
          selectionColor: Theme.of(context).colorScheme.primary,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: false, overscroll: false),
          child: ListView(
            clipBehavior: Clip.none,
            children: [
              // TODO: replace the image and data here with the product received from the db
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: Offset(2, 2), // changes position of shadow
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      offset: Offset(-5, -2), // changes position of shadow
                    ),
                  ],
                ),
                height: 500,
                child: Column(
                  children: [
                    Expanded(child: Image.network(imageUrl, fit: BoxFit.fill)),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _product?['description'] ??
                                'This is a high-quality baby product perfect for everyday use.',
                            style: TextStyle(
                              fontFamily: "ubuntu",
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontFamily: "ubuntu",
                                  fontSize: 27,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 10),
                              ...List.generate(
                                4,
                                (index) => Icon(
                                  Icons.star_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30,
                                ),
                              ),
                              Icon(
                                Icons.star_half_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 30,
                              ),
                            ],
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(right: 0.0),
                            leading: Text(
                              "\$${_product?['price']}",
                              style: Theme.of(context).textTheme.headlineSmall!
                                  .copyWith(
                                    fontFamily: "ubuntu",
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                padding: EdgeInsets.all(20),
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _addToCart(_product!),
                              child: const Text(
                                "Add to Cart",
                                style: TextStyle(fontFamily: "ubuntu"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Reviews",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 30),
              // TODO: replace with builder when real data is fetchable
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(2, 2), // changes position of shadow
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      offset: Offset(-2, -2), // changes position of shadow
                    ),
                  ],

                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Container(
                  height: screenHeight * 0.4,
                  padding: EdgeInsets.symmetric(horizontal: 30),

                  child: ListView(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          ListTile(
                            leading: Icon(Icons.person_2_outlined),
                            // TODO replace with data
                            contentPadding: EdgeInsets.only(right: 0.0),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  Text(
                                    '4.9',
                                    style: TextStyle(
                                      fontFamily: "ubuntu",
                                      fontSize: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star_half_rounded,
                                    size: 25,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              "Jane Doe",
                              style: Theme.of(context).textTheme.labelSmall!
                                  .copyWith(fontFamily: "ubuntu"),
                            ),
                          ),
                          Text(
                            "Absolutely love these! They are so soft and easy to put on, which is a miracle with a squirmy baby. They actually stay on her feet all day—no more lost socks or shoes! Plus, the suede sole gives her just the right grip on our hardwood floors. Highly recommend for new walkers!",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontFamily: "ubuntu"),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          ListTile(
                            leading: Icon(Icons.person_2_outlined),
                            // TODO replace with data
                            contentPadding: EdgeInsets.only(right: 0.0),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  Text(
                                    '4.9',
                                    style: TextStyle(
                                      fontFamily: "ubuntu",
                                      fontSize: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star_half_rounded,
                                    size: 25,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              "Jane Doe",
                              style: Theme.of(context).textTheme.labelSmall!
                                  .copyWith(fontFamily: "ubuntu"),
                            ),
                          ),
                          Text(
                            "Absolutely love these! They are so soft and easy to put on, which is a miracle with a squirmy baby. They actually stay on her feet all day—no more lost socks or shoes! Plus, the suede sole gives her just the right grip on our hardwood floors. Highly recommend for new walkers!",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontFamily: "ubuntu"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.only(right: 0.0),
                title: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Add Comment",
                      hintStyle: TextStyle(
                        fontFamily: 'ubuntu',
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    hoverColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icon(Icons.north_outlined),
                    // TODO: Implement addComment on product
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 7,
              blurRadius: 7,
              offset: Offset(0, 3),
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: GNav(
            gap: 8,
            color: Theme.of(context).colorScheme.primary,
            tabBackgroundColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.onPrimary,
            // onTabChange: (){},
            padding: EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.home_filled, text: "Home", iconSize: 30),
              GButton(icon: Icons.search, text: "Search", iconSize: 30),
              GButton(icon: Icons.local_mall, text: "Products", iconSize: 30),
              GButton(icon: Icons.manage_search, text: "Manage", iconSize: 30),
              GButton(icon: Icons.person, text: "Account", iconSize: 30),
            ],
          ),
        ),
      ),
    );
  }
}
