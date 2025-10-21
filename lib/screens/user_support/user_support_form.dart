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

  void _submitForm() {
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      // Save the form data
      _formKey.currentState!.save();
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
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                  border: InputBorder.none,
                ),
              ),

              SizedBox(
                width: 200,
                height: 44,
                // decoration: const BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.all(Radius.circular(5)),
                //   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                // ),
                child: Builder(
                  builder: (buttonContext) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Select Order:'),
                    onPressed: () {
                      debugPrint('Click Me pressed'); // sanity check
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
                              child: _userOrders == null || _userOrders!.isEmpty
                                  ? const Center(child: Text('No orders'))
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(12),
                                      itemCount: _userOrders!.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, idx) {
                                        final order = _userOrders![idx];
                                        return Card(
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              "Order #${order['id'] ?? idx}",
                                            ),
                                            subtitle: Text(
                                              "Date: ${order['created_at']?.toString().split('T').first ?? '—'}\nTotal: \$${order['total_amount'] ?? '0.00'}",
                                            ),
                                            trailing: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _statusColor(
                                                  order['status'] ?? '',
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                (order['status'] ?? '')
                                                    .toString()
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
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
                  border: InputBorder.none,
                ),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Submit", style: TextStyle(fontFamily: 'ubuntu')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
