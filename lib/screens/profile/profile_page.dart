import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../orders/order_history_page.dart';
import 'edit_profile_page.dart';

// Global Supabase client instance for authenticated operations.
final supabase = Supabase.instance.client;

/// The main profile screen displaying user information and navigation links.
///
/// It fetches user data from the 'profiles' table and provides options
/// to edit the profile, view order history, and log out.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State variable to control the display of the loading indicator.
  bool _isLoading = true;

  // Map to hold the user's profile data fetched from Supabase
  Map<String, dynamic>? _profile;

  // Tracks the current index of the bottom navigation bar (assuming a 5-tab structure).
  int _currentIndex = 4; // last tab (profile)

  @override
  void initState() {
    super.initState();
    // Fetch user profile data immediately upon initialization.
    _loadProfile();
  }

  /// Fetches the user's profile details (name, email, phone, etc.) from the
  /// 'profiles' table using the currently authenticated user ID
  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Query the 'profiles' table.
      final data = await supabase
          .from('profiles')
          .select('full_name, email, phone, created_at')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Signs out the current user and navigates them back to the authentication screen.
  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    // Replace the current screen stack with the '/auth' route.
    Navigator.pushReplacementNamed(context, '/auth');
  }

  /// Helper widget to build a standardized list tile for navigation options.
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: color ?? const Color(0xff006876)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator if data is still being fetched.
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Safely extract profile details, using fallback values if data is null.
    final profile = _profile;
    final name = profile?['full_name'] ?? 'User';
    final email = profile?['email'] ?? 'No email';
    final phone = profile?['phone'] ?? 'Not set';

    return Scaffold(
      backgroundColor: const Color(0xfff5fafc),
      appBar: AppBar(
        title: const Text(
          "PROFILE",
          style: TextStyle(
            color: Color(0xff006876),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 👤 Profile Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xff006876),
                          child: Icon(Icons.person_outline,
                              size: 45, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff006876),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(phone, style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ⚙️ Options List
                _buildListTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () async {
                    // Navigate to EditProfilePage and wait for result
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfilePage()),
                    );
                    // If true is returned (profile saved), reload data.
                    if (updated == true) _loadProfile();
                  },
                ),

                //Order History
                _buildListTile(
                  icon: Icons.history_outlined,
                  title: 'Order History',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OrderHistoryPage()),
                    );
                  },
                ),
                //Help & Support
                _buildListTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                          Text('Support feature coming soon.')),
                    );
                  },
                ),
                //Logout
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.redAccent,
                  onTap: _logout,
                ),

                const SizedBox(height: 30),
                // Footer/Copyright information.
                const Text(
                  "© 2025 BabyShopHub",
                  style: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
