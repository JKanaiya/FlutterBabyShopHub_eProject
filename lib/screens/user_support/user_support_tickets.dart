import 'package:babyshophub/screens/admin/admin_manage_front_page.dart';
import 'package:babyshophub/screens/user_support/manage_ticket.dart';
import 'package:babyshophub/widgets/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:babyshophub/main.dart';

class UserSupportTicket extends StatefulWidget {
  const UserSupportTicket({super.key});

  @override
  State<UserSupportTicket> createState() => _UserSupportTicketState();
}

class _UserSupportTicketState extends State<UserSupportTicket> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _allTickets = [];
  bool _isLoading = true;
  Map<String, dynamic>? userData;
  int _selectedCategoryIndex = 0;
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final List<String> _categories = ["All", "Order", "Resolved", "Misc"];

  List<Map<String, dynamic>> _applySearchFilter(
    List<Map<String, dynamic>> list,
    String query,
  ) {
    if (query.isEmpty) {
      return list;
    }
    final lowerCaseQuery = query.toLowerCase();

    return list.where((ticket) {
      final subject = (ticket['subject'] as String? ?? '').toLowerCase();
      final description = (ticket['description'] as String? ?? '')
          .toLowerCase();
      final status = (ticket['status'] as String? ?? '').toLowerCase();
      final userId = (ticket['user_id'] as String? ?? '').toLowerCase();

      return subject.contains(lowerCaseQuery) ||
          description.contains(lowerCaseQuery) ||
          status.contains(lowerCaseQuery) ||
          userId.contains(lowerCaseQuery);
    }).toList();
  }

  void _applyFilters(int? newCategoryIndex) {
    if (!mounted) return;

    if (newCategoryIndex != null) {
      _selectedCategoryIndex = newCategoryIndex;
    }

    List<Map<String, dynamic>> workingList = _applySearchFilter(
      _allTickets,
      _searchQuery,
    );

    final selectedCategory = _categories[_selectedCategoryIndex];

    if (selectedCategory != "All") {
      if (selectedCategory == "Resolved") {
        workingList = workingList
            .where(
              (ticket) =>
                  ticket['status'] == 'Resolved' ||
                  ticket['status'] == 'Closed',
            )
            .toList();
      } else {
        workingList = workingList
            .where((ticket) => ticket['category'] == selectedCategory)
            .toList();
      }
    }

    setState(() {
      _tickets = workingList;
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

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

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _debouncer.call(() {
      _applyFilters(null);
    });
  }

  void _getUserDetails() async {
    final user = await supabase.auth.getUser();
    final user_id = user.user!.id;
    final userDetails = await supabase
        .from("profiles")
        .select()
        .eq('id', user_id)
        .maybeSingle();
    setState(() {
      userData = userDetails;
    });
  }

  Future<void> _fetchInitialTickets() async {
    try {
      final data = await supabase.from('tickets').select();

      final fetchedTickets = List<Map<String, dynamic>>.from(data);

      setState(() {
        _allTickets = fetchedTickets;
        _isLoading = false;
      });

      _applyFilters(null);
    } catch (e) {
      debugPrint('Error fetching initial tickets: $e');
      setState(() {
        _tickets = [];
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialTickets();
    _getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = ["All", "Orders", "Resolved", "Misc"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HSLColor.fromAHSL(0, 197, 0.28, 0.95).toColor(),
        titleSpacing: 50,
        toolbarHeight: 80,
        title: Text(
          'Tickets',
          selectionColor: Theme.of(context).colorScheme.primary,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Column(
            children: [
              Wrap(
                spacing: 40,
                children: List<Widget>.generate(4, (int index) {
                  return ChoiceChip(
                    disabledColor: Theme.of(context).colorScheme.tertiary,
                    showCheckmark: false,
                    selectedColor: Theme.of(context).colorScheme.tertiary,
                    selected: _selectedCategoryIndex == index,
                    labelStyle: Theme.of(context).textTheme.titleSmall!
                        .copyWith(
                          fontFamily: 'ubuntu',
                          color: _selectedCategoryIndex == index
                              ? Theme.of(context).colorScheme.onTertiary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                    iconTheme: IconThemeData(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    label: Text('${categories[index]}'),
                    onSelected: (bool selected) {
                      if (selected) {
                        // Immediate call to apply filters (passes the new category index)
                        _applyFilters(index);
                      }
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.03),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search tickets...',
                    prefixIcon: Icon(Icons.search, color: Color(0xff006876)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _allTickets.isEmpty
                    ? const Center(child: Text("No tickets available"))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return ScrollConfiguration(
                            // Customize scroll behavior to remove visual scroll indicators.
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false, overscroll: false),
                            child: ListView.separated(
                              clipBehavior: Clip.none,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 30,
                                    color: Colors.white,
                                  ),
                              padding: const EdgeInsets.only(
                                bottom: 12,
                                top: 12,
                              ),
                              itemCount: _tickets.length,
                              itemBuilder: (context, index) {
                                final ticket = _tickets[index];
                                return GestureDetector(
                                  // Navigate to product detail on card tap
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      // TODO: fix routing to page with admin functionality
                                      MaterialPageRoute(
                                        builder: (context) => ManageTicket(
                                          ticket: ticket,
                                          user: userData!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 200,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(
                                            alpha: 0.5,
                                          ),
                                          spreadRadius: 2,
                                          blurRadius: 2,
                                          offset: Offset(
                                            2,
                                            2,
                                          ), // changes position of shadow
                                        ),
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceBright,
                                          offset: Offset(
                                            -3,
                                            -2,
                                          ), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ListTile(
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(
                                                ticket['status'] ?? '',
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              ticket["status"]?.toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                    fontFamily: 'ubuntu',
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                                  ),
                                            ),
                                          ),
                                          leading: Title(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            child: Text(
                                              "${ticket['subject']}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    fontSize: 20,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Text(
                                            "User Id:",
                                            style: TextStyle(
                                              fontFamily: 'ubuntu',
                                              fontSize: 15,
                                            ),
                                          ),
                                          trailing: Text(
                                            "${ticket['user_id']}",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        ListTile(
                                          leading: SizedBox(
                                            width: 300,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time_rounded,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "${ticket['created_at']?.toString().split('T').first ?? '—'}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.secondary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(
                                                ticket['category'] ?? '',
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              ticket["category"]?.toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                    fontFamily: 'ubuntu',
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
