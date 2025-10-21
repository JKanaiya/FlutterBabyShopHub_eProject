import 'package:babyshophub/screens/admin/admin_manage_front_page.dart';
import 'package:flutter/material.dart';

/// The main dashboard screen for administrative users.
///
/// This screen provides a navigable list of cards linking to various
/// management sections of the e-commerce store (Products, Front Page, Customers, Orders, Settings).
class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Adjust spacing and height for a prominent title
        titleSpacing: 50,
        toolbarHeight: 100,
        title: Text(
          "Manage Store",
          // Text styling using the primary color from the app theme.
          selectionColor: Theme.of(context).colorScheme.primary,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 35,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 30),
        child: Column(
          children: [
            ///Products Management Card
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    // TODO: Add proper functionality to navigate to the appt page here
                    MaterialPageRoute(builder: (context) => AdminHome()),
                  );
                },
                minTileHeight: 100,
                titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                iconColor: Theme.of(context).colorScheme.onPrimary,
                leading: Icon(Icons.inventory_2_outlined, size: 40),
                title: Text(
                  "Products",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: "ubuntu",
                  ),
                ),
              ),
            ),
            Spacer(),// Provides even spacing between cards
            //Front Page Management Card
            Card(
              color: Theme.of(context).colorScheme.tertiary,
              child: ListTile(
                onTap: () {
                  // Navigates to the dedicated front page management screen.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminManageFrontPage(),
                    ),
                  );
                },
                minTileHeight: 100,
                titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                iconColor: Theme.of(context).colorScheme.onPrimary,
                leading: Icon(Icons.home_outlined, size: 40),
                title: Text(
                  "Front Page",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: "ubuntu",
                  ),
                ),
              ),
            ),
            Spacer(),
            //Customers Management Card
            Card(
              color: Theme.of(context).colorScheme.secondary,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    // TODO: Add proper functionality to navigate to the appt page here
                    MaterialPageRoute(builder: (context) => AdminHome()),
                  );
                },
                minTileHeight: 100,
                titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                iconColor: Theme.of(context).colorScheme.onPrimary,
                leading: Icon(Icons.support_agent_outlined, size: 40),
                title: Text(
                  "Customers",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: "ubuntu",
                  ),
                ),
              ),
            ),
            Spacer(),// Provides even spacing between cards


            //Orders Management Card
            Card(
              color: Color.fromARGB(255, 36, 104, 167),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    // TODO: Add proper functionality to navigate to the appt page here
                    MaterialPageRoute(builder: (context) => AdminHome()),
                  );
                },
                minTileHeight: 100,
                titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                iconColor: Theme.of(context).colorScheme.onPrimary,
                leading: Icon(Icons.manage_search, size: 40),
                title: Text(
                  "Orders",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: "ubuntu",
                  ),
                ),
              ),
            ),
            Spacer(),
            //Settings Management Card
            Card(
              color: Color.fromARGB(255, 250, 155, 145),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    // TODO: Add proper functionality to navigate to the appt page here
                    MaterialPageRoute(builder: (context) => AdminHome()),
                  );
                },
                minTileHeight: 100,
                titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                iconColor: Theme.of(context).colorScheme.onPrimary,
                leading: Icon(Icons.settings, size: 40),
                title: Text(
                  "Settings",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: "ubuntu",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
