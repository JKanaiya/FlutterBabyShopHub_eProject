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
  bool _isLoading = true;

  void _onSearchChanged(String value) {
    _searchQuery = value;
  }

  Future<void> _fetchTickets() async {
    // setState(() => _isLoading = true);

    try {
      var query = supabase.from('products').select().eq('is_active', true);

      if (_searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$_searchQuery%');
      }

      final data = await query.order('created_at', ascending: false);
      setState(() {
        _tickets = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('Error fetching tickets: $e');
      setState(() => _tickets = []);
    } finally {
      setState(() => _isLoading = false);
    }
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
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
        ],
      ),
    );
  }
}
