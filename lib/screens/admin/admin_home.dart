import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 50,
        toolbarHeight: 100,
        title: Text(
          "Manage Store",
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
            Spacer(),
            Card(
              color: Theme.of(context).colorScheme.tertiary,
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
            Spacer(),
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
