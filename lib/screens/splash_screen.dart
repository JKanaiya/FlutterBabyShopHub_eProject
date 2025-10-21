import 'package:babyshophub/main.dart' as main;
import 'package:babyshophub/screens/admin/edit_front_page_sections.dart';
import 'package:babyshophub/screens/products_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<Uint8List>? _splashImageBytes;
  List<Map<int, String>>? _splashText;
  final splashImages = ['splashscreen1', 'splashscreen2', 'splashscreen3'];

  String? getValueByKey(int key) {
    try {
      return _splashText!.firstWhere((map) => map.containsKey(key))[key];
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadSplashText() async {
    final response = await main.supabase
        .from('app_data_upserts')
        .select("section, sectionText");

    _splashText = (response as List)
        .map((row) => {row['section'] as int: row['sectionText'] as String})
        .toList();
  }

  Future<void> _loadSplashImages() async {
    final downloadFutures = splashImages.map((image) async {
      return await main.supabase.storage
          .from('product-images/Splash Screen')
          .download(image);
    }).toList();

    try {
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
    _loadSplashImages();
    _loadSplashText();
  }

  @override
  Widget build(BuildContext context) {
    if (_splashImageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: SizedBox(
        height: screenHeight * 1.05,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  child: Image.memory(_splashImageBytes![0]),
                ),
                Positioned(
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        // TODO: Add proper functionality to navigate to the appt page here
                        MaterialPageRoute(
                          builder: (context) =>
                              EditSection(section: 1, text: getValueByKey(1)!),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        // TODO: Add proper functionality to navigate to the appt page here
                        MaterialPageRoute(builder: (context) => ProductsPage()),
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
            Stack(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  child: Image.memory(_splashImageBytes![1], fit: BoxFit.fill),
                ),
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
                Positioned(
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditSection(section: 2, text: getValueByKey(2)!),
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
                Positioned(
                  bottom: 70,
                  right: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.all(25),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        // TODO: Add proper functionality to navigate to the appt page here
                        MaterialPageRoute(builder: (context) => ProductsPage()),
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
            Expanded(
              child: Stack(
                children: [
                  Row(
                    children: [
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
                                color: Theme.of(context).colorScheme.onPrimary,
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductsPage(),
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
                  Positioned(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          // TODO: Add proper functionality to navigate to the appt page here
                          MaterialPageRoute(
                            builder: (context) => EditSection(
                              section: 3,
                              text: getValueByKey(3)!,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
