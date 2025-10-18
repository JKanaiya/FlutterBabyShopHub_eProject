import 'package:babyshophub/screens/admin/admin_home.dart';
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

      // ✅ Static Routes (no arguments)
      routes: {
        '/': (context) => const SplashOrAuthGate(),
        '/auth': (context) => const AuthPage(),
        '/shop': (context) => const ShopPage(),
        '/products': (context) => const ProductsPage(),
        '/cart': (context) => const CartPage(),
        '/order_history': (context) => const OrderHistoryPage(),
        '/admin_home': (context) => const AdminHome(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/product_detail') {
          final productId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(productId: productId),
          );
        }

        if (settings.name == '/checkout') {
          final cartId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => CheckoutPage(cartId: cartId),
          );
        }

        if (settings.name == '/order_summary') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => OrderSummaryPage(orderId: orderId),
          );
        }

        if (settings.name == '/track_order') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => TrackOrderPage(orderId: orderId),
          );
        }

        return null;
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

    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        Navigator.pushReplacementNamed(context, '/shop');
      } else if (isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin_home');
      } else if (event == AuthChangeEvent.signedOut) {
        Navigator.pushReplacementNamed(context, '/auth');
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
