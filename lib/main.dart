import 'package:babyshophub/screens/admin/admin_manage_front_page.dart';
import 'package:babyshophub/screens/splash_screen.dart';
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

class Globals {
  static bool isAdmin = false;
}

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

      // ✅ Static Routes
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

      // ✅ Dynamic Routes
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

/// ✅ Splash Screen + Auth Gate
/// Handles login/logout redirection and session check cleanly
class SplashOrAuthGate extends StatefulWidget {
  const SplashOrAuthGate({super.key});

  @override
  State<SplashOrAuthGate> createState() => _SplashOrAuthGateState();
}

class _SplashOrAuthGateState extends State<SplashOrAuthGate>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation for splash
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Listen for auth state changes
    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (!mounted) return;

      if (event == AuthChangeEvent.signedIn && session != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _redirectTo(
            Globals.isAdmin ? const AdminHome() : const ShopPage(),
          );
        });
      } else if (event == AuthChangeEvent.signedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _redirectTo(const AuthPage());
        });
      }
    });

    // Perform initial session check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    try {
      final session = supabase.auth.currentSession;

      if (session == null) {
        _redirectTo(const AuthPage());
        return;
      }

      final userResponse = await supabase.auth.getUser();
      final user = userResponse.user;
      if (user == null) {
        _redirectTo(const AuthPage());
        return;
      }

      // ✅ Safely unwrap the nullable email
      final email = user.email ?? '';

      // Check if user is admin
      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .eq('is_admin', true)
          .limit(1);

      Globals.isAdmin = response.isNotEmpty;

      // Redirect accordingly
      _redirectTo(
        Globals.isAdmin ? const AdminManageFrontPage() : const ShopPage(),
      );
    } catch (e) {
      debugPrint("Error checking session: $e");
      _redirectTo(const AuthPage());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _redirectTo(Widget page) {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),
              Text(
                "BabyShopHub",
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }
}
