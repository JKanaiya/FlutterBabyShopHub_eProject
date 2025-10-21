import 'package:babyshophub/screens/admin/edit_product.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:babyshophub/main.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';// Third-party rating bar widget

/// A screen to view the details of a single product, including its reviews,
/// and provides administrative actions like editing the product details.
class AdminProductManage extends StatefulWidget {
  // Required ID of the product to display.
  final int productId;
  AdminProductManage({super.key, required this.productId});

  @override
  State<AdminProductManage> createState() => _AdminProductManageState();
}

class _AdminProductManageState extends State<AdminProductManage> {
  // State variables for product data.
  Map<String, dynamic>? _product;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  double? _ratingAverage;

  /// Fetches the product details and associated reviews from Supabase.
  Future<void> _loadProductDetails() async {
    double? average;
    try {
      // Fetch product information by ID.
      final productData = await supabase
          .from('products')
          .select('id, name, description, price, image_url')
          .eq('id', widget.productId)
          .maybeSingle();

      // Fetch all reviews for this product.
      final reviews = await supabase
          .from('reviews')
          .select('rating, comment, user_email')
          .eq('product_id', productData?['id']);

      //Calculate the average rating.
      if (reviews.isEmpty) {
        average = 4.5;// Default rating if no reviews exist.
      } else if (reviews.length == 1) {
        average = reviews[0]['rating'];
      } else {
        // Calculate sum of all ratings using fold.
        double sum = reviews.fold(
          0,
          (prev, review) => prev + (review['rating'] as num).toDouble(),
        );
        average = sum / reviews.length;
      }

      // Update the UI state with the fetched data.
      setState(() {
        _product = productData;
        _reviews = reviews;
        _isLoading = false;
        _ratingAverage = average;
      });
    } catch (e) {
      debugPrint("Error loading product details: $e");
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
    final user = supabase.auth.currentUser;
    // Temporary variable to hold rating from the rating bar before submission.
    double? userRating = 4.0;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    /// Implements the logic to add the current product to the user's shopping cart.
    /// This logic duplicates the "Get or Create Cart" pattern used elsewhere.
    Future<void> _addToCart(Map<String, dynamic> product) async {
      try {
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

    // TODO: implement this after rating form submission exists
    /// Handles the submission of a new review
    Future addComment() async {
      try {
        await supabase.from('reviews').insert({
          'product_id': _product?['id'],
          'user_id': user?.id,
          'comment': _commentController.text,
          'rating': userRating,// Uses the rating value set by the RatingBar's onRatingUpdate.
          'user_email': user?.email,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully!')),
        );
        _loadProductDetails();
      } catch (e) {
        debugPrint("Error loading product details: $e");
        setState(() => _isLoading = false);
      }
    }

    final imageUrl =
        _product?['image_url'] ??
        'https://via.placeholder.com/300x300.png?text=No+Image';

    return Scaffold(
      appBar: AppBar(
        // Custom app bar styling with back and edit actions.
        backgroundColor: HSLColor.fromAHSL(0, 197, 0.28, 0.95).toColor(),
        titleSpacing: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);// Go back to previous screen.
          },
          icon: Icon(
            Icons.west,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
        ),
        toolbarHeight: 80,
        actions: [
          // Edit button to navigate to the product editing screen
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProduct(
                    // Pass current product data to the edit screen.
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
          // Customize scroll behavior to remove visual scroll indicators.
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: false, overscroll: false),
          child: ListView(
            clipBehavior: Clip.none,
            children: [
              // TODO: replace the image and data here with the product received from the db
              // --- Product Details Card ---
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
                    // Product Image
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
                          // Product Description
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
                          // Average Rating Display
                          Row(
                            children: [
                              Text(
                                _ratingAverage.toString(),
                                style: TextStyle(
                                  fontFamily: "ubuntu",
                                  fontSize: 27,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 10),
                              // Display full stars
                              ...List.generate(
                                _ratingAverage!.floor(),
                                (index) => Icon(
                                  Icons.star_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30,
                                ),
                              ),
                              if (_ratingAverage! >= _ratingAverage!.floor())
                                Icon(
                                  Icons.star_half_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30,
                                ),
                            ],
                          ),
                          // Price and Add to Cart Button
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
              // --- Reviews Section Title ---
              Text(
                "Reviews",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 30),
              // TODO: replace with builder when real data is fetchable
              // --- Display Reviews List ---
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
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),

                  child: _reviews.isNotEmpty
                      ? ListView.builder(
                          itemCount: _reviews.length,
                          itemBuilder: (BuildContext context, int index) {
                            // Review Item
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.person_2_outlined),
                                  // contentPadding: EdgeInsets.only(right: 0.0),
                                  trailing: SizedBox(
                                    width: 60,
                                    child: Row(
                                      children: [
                                        // Display Review Rating
                                        Text(
                                          _reviews[index]['rating'].toString(),
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
                                    _reviews[index]['user_email'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(fontFamily: "ubuntu"),
                                  ),
                                ),
                                // Review Comment Text
                                Text(
                                  _reviews[index]['comment'],
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiary,
                                      ),
                                ),
                              ],
                            );
                          },
                        )
                      : Center(child: const Text("No reviews yet!")),
                ),
              ),
              const SizedBox(height: 20),
              // --- Add Review Form ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Rating Bar Input
                  RatingBar(
                    initialRating: 0,
                    itemCount: 5,
                    allowHalfRating: true,
                    onRatingUpdate: (rating) {
                      userRating = rating;// Update the userRating variable on change
                    },
                    ratingWidget: RatingWidget(
                      full: Icon(
                        Icons.star_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      half: Icon(
                        Icons.star_half_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      empty: Icon(
                        Icons.star_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    itemPadding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  // Comment Text Field and Submit Button
                  ListTile(
                    contentPadding: EdgeInsets.only(right: 0.0),
                    title: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "Add Comment",
                          hintStyle: TextStyle(
                            fontFamily: 'ubuntu',
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
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
                        onPressed: () => addComment(),
                      ),
                    ),
                  ),
                ],
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
