import 'package:babyshophub/screens/admin/admin_manage_product.dart';
import 'package:babyshophub/screens/admin/admin_products.dart';
import 'package:babyshophub/screens/admin/edit_front_page_sections.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:babyshophub/main.dart';// Required for accessing 'supabase' global variable
// import 'dart:typed_data';
import 'package:flutter/services.dart';// Contains Uint8List and other platform services

/// An administrative screen dedicated to managing and editing the content of the user-facing home/splash page.
///
/// It allows the admin to view the current splash screen elements (images and text)
/// and click an edit icon to modify the text for each section.
class AdminManageFrontPage extends StatefulWidget {
  // Holds the byte data for the splash screen images downloaded from Supabase Storage.
  const AdminManageFrontPage({super.key});

  @override
  State<AdminManageFrontPage> createState() => _AdminManageFrontPageState();
}

class _AdminManageFrontPageState extends State<AdminManageFrontPage> {
  // TODO: Add a method and var to hold the splash screen text
  // Holds the text data for each section, fetched from the 'app_data_upserts' table.
  List<Uint8List>? _splashImageBytes;
  // Holds the text data for each section, fetched from the 'app_data_upserts' table.
  List<Map<int, String>>? _splashText;
  // List of image file names to download from the storage bucket.
  final splashImages = ['splashscreen1', 'splashscreen2', 'splashscreen3'];

  /// Utility method to retrieve the text value associated with a specific section key.
  ///
  /// @param key The integer ID representing the front page section (e.g., 1, 2, 3).
  /// @returns The section's text content, or null if not found.
  String? getValueByKey(int key) {
    try {
      // Find the map in the list that contains the key, and return the value.
      return _splashText!.firstWhere((map) => map.containsKey(key))[key];
    } catch (e) {
      // Handles cases where the key might not be present in any map.
      return null;
    }
  }

  /// Fetches the customizable text content for the splash page sections from the Supabase database.
  Future<void> _loadSplashText() async {
    final response = await supabase
        .from('app_data_upserts')
        .select("section, sectionText");

    // Transforms the raw response list into a list of maps for easier lookup.
    _splashText = (response as List)
        .map((row) => {row['section'] as int: row['sectionText'] as String})
        .toList();
  }

  /// Downloads the splash screen images (as byte arrays) from Supabase Storage.
  Future<void> _loadSplashImages() async {
    // Create a list of futures, one for each image download.
    final downloadFutures = splashImages.map((image) async {
      return await supabase.storage
          .from('product-images/Splash Screen')// Specify the bucket/path
          .download(image);
    }).toList();

    try {
      // Wait for all downloads to complete concurrently.
      var images = await Future.wait(downloadFutures);
      //  Set the state to trigger a rebuild with the downloaded data
      setState(() {
        _splashImageBytes = images;
      });
    } catch (e) {
      // Handle the error
      print('Error loading splash images: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Start loading both text data and image data simultaneously.
    _loadSplashImages();
    _loadSplashText();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until images are downloaded.
    if (_splashImageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Get screen height to ensure the SingleChildScrollView covers the screen.
    final screenHeight = MediaQuery.of(context).size.height;
    /// Logs the admin out and navigates back to the authentication screen
    Future<void> _logout() async {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/auth');
    }

    return Scaffold(
      // TODO change to list view and remove the gap between the 2 sections
      // The body is a scrollable container to fit all three splash sections vertically
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight * 1.05,// Slightly extend height to fit content
          child: Column(
            children: [
              // Top Banner
              Stack(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    // Display the image bytes using Image.memory.
                    child: Image.memory(_splashImageBytes![0]),
                  ),
                  // Edit Icon Positioned Top-Left
                  Positioned(
                    child: IconButton(
                      onPressed: () {
                        // Navigate to the editing screen
                        Navigator.push(
                          context,
                          // TODO: Add proper functionality to navigate to the appt page here
                          MaterialPageRoute(
                            builder: (context) => EditSection(
                              section: 1,
                              text: getValueByKey(1)!,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        size: 40,
                      ),
                    ),
                  ),
                  // Text Overlay Positioned Top-Right
                  Positioned(
                    top: 10,
                    right: 0,
                    child: SizedBox(
                      width: 200,
                      child: Title(
                        color: Theme.of(context).colorScheme.primary,
                        child: Text(
                          getValueByKey(1) ??
                              // Default value is the apps initial section 1 page text
                              'A Bundle for your Joy',
                          style: Theme.of(context).textTheme.displaySmall!
                              .copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                        ),
                      ),
                    ),
                  ),
                  // Shop Now Button Positioned Bottom-Right
                  Positioned(
                    bottom: 30,
                    right: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                      ),
                      // Action navigates to the admin products list
                      onPressed: () {
                        Navigator.push(
                          context,
                          // TODO: Add proper functionality to navigate to the appt page here
                          MaterialPageRoute(
                            builder: (context) => AdminProducts(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "Shop now",
                            style: TextStyle(
                              fontFamily: "ubuntu",
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.north_east),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //Middle Banner
              Stack(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    child: Image.memory(
                      _splashImageBytes![1],
                      fit: BoxFit.fill,
                    ),
                  ),
                  // Text Overlay Positioned Top-Right
                  Positioned(
                    top: 70,
                    right: 20,
                    child: SizedBox(
                      width: 230,
                      child: Title(
                        color: Theme.of(context).colorScheme.primary,
                        child: Text(
                          getValueByKey(2) ??
                              // Default value is the apps initial section 1 page text
                              'Winter Party up to 50% off',
                          style: Theme.of(context).textTheme.displaySmall!
                              .copyWith(
                                fontSize: 27,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ),
                  ),
                  // Edit Icon Positioned Top-Left
                  Positioned(
                    child: IconButton(
                      // Navigate to the editing screen
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditSection(
                              section: 2,
                              text: getValueByKey(2)!,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        size: 40,
                      ),
                    ),
                  ),
                  // Discover Button Positioned Bottom-Middle
                  Positioned(
                    bottom: 70,
                    right: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: EdgeInsets.all(25),
                      ),
                      // Action navigates to the admin products list
                      onPressed: () {
                        Navigator.push(
                          context,
                          // TODO: Add proper functionality to navigate to the appt page here
                          MaterialPageRoute(
                            builder: (context) => AdminProducts(),
                          ),
                        );
                      },
                      child: Text(
                        "Discover",
                        style: TextStyle(fontFamily: "ubuntu", fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom Split
              Expanded(
                child: Stack(
                  children: [
                    Row(
                      children: [
                        // Left Pane
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.all(60),
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            child: Flex(
                              direction: Axis.vertical,
                              children: [
                                Title(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  child: Text(
                                    getValueByKey(3) ??
                                        // Default value is the apps initial section 1 page text
                                        'Clothing for Comfort. Anywhere, Everywhere',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 3,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onTertiary,
                                  ),
                                  // Action navigates to the admin products list
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminProducts(),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 100,
                                    child: Row(
                                      children: [
                                        Text(
                                          "Shop now",
                                          style: TextStyle(
                                            fontFamily: "ubuntu",
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(Icons.north_east),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right Pane
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: double.infinity,
                            child: Image.memory(
                              _splashImageBytes![2],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Edit Icon Positioned Top-Left
                    Positioned(
                      child: IconButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   // TODO: Add proper functionality to navigate to the appt page here
                          //   MaterialPageRoute(
                          //     builder: (context) => EditSection(
                          //       section: 3,
                          //       text: getValueByKey(3)!,
                          //     ),
                          //   ),
                          // );
                          _logout();
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      //--- Bottom Navigation Bar ---
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
