import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AdminProductManage extends StatefulWidget {
  AdminProductManage({super.key});
  // AdminProducts({super.key, this.product});
  var product;

  @override
  State<AdminProductManage> createState() => _AdminProductManageState();
}

class _AdminProductManageState extends State<AdminProductManage> {
  @override
  // TODO: replace the text with the product data from supabase
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HSLColor.fromAHSL(0, 197, 0.28, 0.95).toColor(),
        titleSpacing: 50,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
        toolbarHeight: 100,
        title: Text(
          "Baby Shoes",
          selectionColor: Theme.of(context).colorScheme.primary,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 35,
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
                    Expanded(
                      child: Image.asset(
                        // TODO: replace data here
                        'assets/images/babyshoes.jpg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    // TODO: replace data here
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
                            "These delightful baby shoes are designed with ultimate comfort in mind. Crafted from soft, breathable organic cotton and featuring a flexible, non-slip suede sole, they allow for natural foot movement, which is crucial for developing feet. They're lightweight, machine washable, and so cozy, your little one will barely notice they're wearing them.",
                            style: TextStyle(
                              fontFamily: "ubuntu",
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            // TODO replace data here
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
                            // TODO replace data here
                            leading: Text(
                              "\$13.50",
                              style: Theme.of(context).textTheme.headlineSmall!
                                  .copyWith(
                                    fontFamily: "ubuntu",
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),
                            ),
                            // TODO replace functionality here
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
                              onPressed: () {},
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
              // TODO replace with builder when real data is fetchable
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
                title: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Add Comment",
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
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
