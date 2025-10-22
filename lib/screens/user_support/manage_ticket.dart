import 'package:babyshophub/screens/orders/order_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:babyshophub/main.dart';

class ManageTicket extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final Map<String, dynamic> user;
  const ManageTicket({super.key, required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    Color _statusColor(String s) {
      switch (s) {
        case 'Resolved' || 'Closed':
          return Colors.green;
        case 'Open':
          return Theme.of(context).colorScheme.primary;
        case 'Order':
          return Theme.of(context).colorScheme.secondary;
        case 'Misc':
          return Theme.of(context).colorScheme.tertiary;
        default:
          return Colors.blueGrey;
      }
    }

    Future addReason() async {
      try {
        await supabase
            .from('tickets')
            .update({'response': reasonController.text})
            .eq('id', ticket['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reason added successfully!')),
        );
      } catch (e) {
        debugPrint("Error adding response: $e");
      }
    }

    Future completeTicket() async {
      try {
        await supabase
            .from('tickets')
            .update({'status': 'Resolved'})
            .eq('id', ticket['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket resolved successfully')),
        );
        Navigator.pop(context); // Go back to previous screen.
      } catch (e) {
        debugPrint("Error completing ticket: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
        // Custom app bar styling with back and edit actions.
        backgroundColor: HSLColor.fromAHSL(0, 197, 0.28, 0.95).toColor(),
        titleSpacing: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen.
          },
          icon: Icon(
            Icons.west,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
        ),
        toolbarHeight: 80,
        title: Text(
          "Ticket",
          selectionColor: Theme.of(context).colorScheme.primary,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 30,
          children: [
            ListTile(
              trailing: SizedBox(
                width: 120,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${ticket['created_at']?.toString().split('T').first ?? '—'}",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              leading: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(ticket['category']),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  ticket['status'].toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontFamily: 'ubuntu',
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            Text(
              "User",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Container(
              // height: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(2, 2), // changes position of shadow
                  ),
                  BoxShadow(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    offset: Offset(-3, -2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ListTile(
                    trailing: Text(
                      ticket['user_id'],
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontFamily: 'ubuntu',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    leading: Title(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        "Id:",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Text(
                      "Email:",
                      style: TextStyle(fontFamily: 'ubuntu', fontSize: 15),
                    ),
                    trailing: Text(
                      user['email'],
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  if (user['phone'] != null)
                    ListTile(
                      leading: Text(
                        "Phone:",
                        style: TextStyle(fontFamily: 'ubuntu', fontSize: 15),
                      ),
                      trailing: Text(
                        user['phone'],
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ListTile(
                    leading: Text(
                      "Subject:",
                      style: TextStyle(fontFamily: 'ubuntu', fontSize: 15),
                    ),
                    trailing: Text(
                      ticket['subject'],
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Details",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.only(right: 0.0),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onTertiary,
                        // borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderSummaryPage(orderId: ticket['order_id']),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 100,
                        child: Row(
                          spacing: 5,
                          children: [
                            Text(
                              "Go to Order",
                              style: TextStyle(fontFamily: 'ubuntu'),
                            ),
                            Icon(
                              Icons.north_east,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(2, 2), // changes position of shadow
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      offset: Offset(-3, -2), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Title(
                      color: Theme.of(context).colorScheme.primary,
                      child: ListTile(
                        contentPadding: EdgeInsets.only(right: 0.0),
                        leading: Text(
                          "Id:",
                          style: TextStyle(fontFamily: 'ubuntu', fontSize: 18),
                        ),
                        trailing: Text(
                          "${ticket['id']}",
                          style: TextStyle(fontFamily: 'ubuntu', fontSize: 18),
                        ),
                      ),
                    ),
                    if (ticket['order_id'] != null)
                      Text(
                        "Description:",
                        style: TextStyle(fontFamily: 'ubuntu', fontSize: 15),
                      ),
                    Flexible(child: Text(ticket['description'])),
                    Text(
                      "Reason:",
                      style: TextStyle(fontFamily: 'ubuntu', fontSize: 15),
                    ),
                    ticket['response'] != null
                        ? ListTile(
                            leading: Text(
                              ticket['response'],
                              style: TextStyle(
                                fontFamily: 'ubuntu',
                                fontSize: 15,
                              ),
                            ),
                          )
                        : ListTile(
                            contentPadding: EdgeInsets.only(right: 0.0),
                            title: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: reasonController,
                                decoration: InputDecoration(
                                  hintText: "Add Comment",
                                  hintStyle: TextStyle(
                                    fontFamily: 'ubuntu',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
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
                                onPressed: () => addReason(),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: completeTicket,
                child: const Text(
                  "Complete Ticket",
                  style: TextStyle(fontFamily: "ubuntu", fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
