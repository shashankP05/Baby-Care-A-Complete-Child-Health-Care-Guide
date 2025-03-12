import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';  // Add this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Add this App Check initialization
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(isDarkMode),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Kidz App',
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ThemeNotifier to manage dark mode globally
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode;

  ThemeNotifier(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }
}
