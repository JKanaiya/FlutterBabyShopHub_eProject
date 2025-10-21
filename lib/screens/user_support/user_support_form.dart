import 'package:flutter/material.dart';
import 'package:babyshophub/main.dart';
import 'package:popover/popover.dart';

class UserSupportForm extends StatefulWidget {
  final String userId;
  const UserSupportForm({super.key, required this.userId});

  @override
  State<UserSupportForm> createState() => _UserSupportFormState();
}

class _UserSupportFormState extends State<UserSupportForm> {
  List<Map<String, dynamic>>? _userOrders;

  String _subject = '';
  String _description = '';
  String? _orderId;
  Map<String, dynamic>? _selectedOrder;

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.orange;
      case 'processing':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  void _getUserOrders() async {
    final orders = await supabase
        .from('orders')
        .select()
        .eq('user_id', widget.userId);
    setState(() {
      _userOrders = orders;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitForm() async {
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      // Save the form data
      _formKey.currentState!.save();

      final user = await supabase.auth.getUser();

      try {
        await supabase.from('tickets').insert({
          'user_id': user.user!.id,
          'subject': _subject,
          'description': _description,
          'category': _selectedOrder != null ? "Order" : "Misc",
          'status': 'Open',
          'order_id': _orderId,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket created successfullly')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint("Ticket failed: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create ticket.')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserOrders();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Create Ticket',
          selectionColor: Theme.of(context).colorScheme.primary,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 80,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a subject.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _subject = value!;
                },
                decoration: InputDecoration(
                  label: Text("Subject:"),
                  hintStyle: TextStyle(
                    fontFamily: 'ubuntu',
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontSize: 17,
                  ),
                  // border: InputBorder.none,
                ),
              ),
              _selectedOrder != null
                  ? Container(
                      padding: EdgeInsets.all(15),
                      height: 300,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(2, 2), // changes position of shadow
                          ),
                          BoxShadow(
                            color: Theme.of(context).colorScheme.surfaceBright,
                            offset: Offset(
                              -5,
                              -2,
                            ), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ListTile(
                            title: Title(
                              color: Theme.of(context).colorScheme.primary,
                              child: Text(
                                "${_selectedOrder!['created_at']?.toString().split('T').first ?? '—'}",
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      fontFamily: 'ubuntu',
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.close),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () {
                                setState(() {
                                  _selectedOrder = null;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            leading: Text(
                              "Order ID:",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            trailing: Text(
                              _selectedOrder!["id"],
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    fontFamily: 'ubuntu',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                          ListTile(
                            leading: Text(
                              "Status:",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  _selectedOrder!['status'] ?? '',
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _selectedOrder!["status"]?.toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      fontFamily: 'ubuntu',
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Text(
                              "Price:",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            trailing: Text(
                              _selectedOrder!['total_amount'].toString(),
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontFamily: 'ubuntu',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order:",
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge!.copyWith(fontSize: 16),
                        ),
                        SizedBox(
                          width: 200,
                          height: 44,
                          child: Builder(
                            builder: (buttonContext) => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                              child: Text('Select Order:'),
                              onPressed: () {
                                showPopover(
                                  context: buttonContext,
                                  width: 320,
                                  height: 380,
                                  direction: PopoverDirection.bottom,
                                  arrowHeight: 12,
                                  arrowWidth: 20,
                                  barrierColor: Colors.black.withOpacity(0.3),
                                  bodyBuilder: (context) {
                                    return Material(
                                      child: SizedBox(
                                        width: 320,
                                        height: 380,
                                        child:
                                            _userOrders == null ||
                                                _userOrders!.isEmpty
                                            ? const Center(
                                                child: Text('No orders'),
                                              )
                                            : ListView.separated(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                itemCount: _userOrders!.length,
                                                separatorBuilder: (_, __) =>
                                                    const SizedBox(height: 8),
                                                itemBuilder: (context, idx) {
                                                  final order =
                                                      _userOrders![idx];
                                                  return Card(
                                                    margin: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: ListTile(
                                                      title: Text(
                                                        "${order['created_at']?.toString().split('T').first ?? '—'}",
                                                      ),
                                                      subtitle: Text(
                                                        "\$${order['total_amount'] ?? '0.00'}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary,
                                                            ),
                                                      ),
                                                      trailing: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: _statusColor(
                                                            order['status'] ??
                                                                '',
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          (order['status'] ??
                                                                  '')
                                                              .toString()
                                                              .toUpperCase(),
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .titleSmall!
                                                              .copyWith(
                                                                color: Theme.of(context)
                                                                    .colorScheme
                                                                    .onSecondary,
                                                              ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        debugPrint(
                                                          'Selected order id: ${order['id']}',
                                                        );
                                                        setState(() {
                                                          _orderId = order['id']
                                                              ?.toString();
                                                          _selectedOrder =
                                                              order;
                                                        });
                                                        Navigator.of(
                                                          context,
                                                        ).pop(); // close the popover
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
                decoration: InputDecoration(
                  label: Text("Description:"),
                  hintStyle: TextStyle(
                    fontFamily: 'ubuntu',
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontSize: 17,
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: _submitForm,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Submit",
                      style: TextStyle(fontFamily: 'ubuntu', fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
