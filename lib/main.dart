import 'package:babyshophub/screens/admin/admin_manage_front_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'util.dart';

// Screens
import 'screens/auth_page.dart';
import 'screens/shop/shop_page.dart';
import 'screens/products_page.dart';
import 'screens/shop/product_detail_page.dart';
import 'screens/shop/cart_page.dart';
import 'screens/shop/checkout_page.dart';
import 'screens/orders/order_summary_page.dart';
import 'screens/orders/order_history_page.dart';
import 'screens/orders/track_order_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/admin/admin_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://olovqmyqfrlatninpcue.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sb3ZxbXlxZnJsYXRuaW5wY3VlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyNTk5MDksImV4cCI6MjA3NDgzNTkwOX0.-C7iI6wiAP9h-WACNKnRX5V_Okh4t-NBDT4jGT39UTM',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(
      context,
      "Delius Swash Caps",
      "Delius Unicase",
    );
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BabyShopHub',
      theme: theme.light().copyWith(
        scrollbarTheme: const ScrollbarThemeData(interactive: false),
      ),

      // ✅ Main routes
      routes: {
        '/': (context) => const SplashOrAuthGate(),
        '/auth': (context) => const AuthPage(),
        '/shop': (context) => const ShopPage(),
        '/products': (context) => const ProductsPage(),
        '/cart': (context) => const CartPage(),
        '/order_history': (context) => const OrderHistoryPage(),
        '/profile': (context) => const ProfilePage(),
        '/admin_home': (context) => const AdminHome(),
      },

      // ✅ Routes with arguments
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/product_detail':
            final productId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(productId: productId),
            );
          case '/checkout':
            final cartId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => CheckoutPage(cartId: cartId),
            );
          case '/order_summary':
            final orderId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => OrderSummaryPage(orderId: orderId),
            );
          case '/track_order':
            final orderId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => TrackOrderPage(orderId: orderId),
            );
          default:
            return null;
        }
      },
    );
  }
}

class SplashOrAuthGate extends StatefulWidget {
  const SplashOrAuthGate({super.key});

  @override
  State<SplashOrAuthGate> createState() => _SplashOrAuthGateState();
}

class _SplashOrAuthGateState extends State<SplashOrAuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = supabase.auth.currentSession;
    if (!mounted) return;
    setState(() {
      _isAuthenticated = session != null;
      _isLoading = false;
    });

    final user = await supabase.auth.getUser();

    final email = user.user!.email.toString();

    final response = await supabase
        .from('profiles')
        .select("id")
        .eq("email", email)
        .eq("is_admin", true)
        .limit(1);

    final isAdmin = response.isNotEmpty;

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              isAdmin ? const AdminManageFrontPage() : const ShopPage(),
        ),
        (route) => false,
      );
    }

    // ✅ Listen for auth state changes globally
    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (!mounted) return;

      if (event == AuthChangeEvent.signedIn && session != null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => isAdmin ? const AdminHome() : const ShopPage(),
            ),
            (route) => false,
          );
        }
      } else if (event == AuthChangeEvent.signedOut) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isAuthenticated ? const ShopPage() : const AuthPage();
  }
}
