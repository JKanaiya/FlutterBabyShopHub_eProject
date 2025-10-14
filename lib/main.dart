import 'util.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_page.dart';
import 'theme.dart';

void main() async {
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
      // theme: ThemeData(primarySwatch: Colors.blue),
      theme: theme.light(),
      home: const AuthPage(),
    );
  }
}
