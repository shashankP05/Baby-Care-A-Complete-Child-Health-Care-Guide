import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats/screens/login_screen.dart';
import 'package:whats/doctor/home_page.dart';
import 'package:whats/doctor/messages_page.dart';
import 'package:whats/doctor/profile_page.dart';
import 'package:whats/doctor/chatbot_page.dart';

class DoctorScreen extends StatefulWidget {
  final String name;

  const DoctorScreen({super.key, required this.name});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _pages = [
      HomePage(name: widget.name),
      const MessagesPage(),
      ProfilePage(
        isDarkMode: _isDarkMode,
        toggleDarkMode: _toggleDarkMode,
      ),
    ];
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        body: SafeArea(child: _pages[_currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 0 // Only show Chatbot on HomePage
            ? FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotPage()),
            );
          },
          heroTag: null,
          child: const Icon(Icons.chat, color: Colors.white),
        )
            : null,
      ),
    );
  }
}

// Extension to capitalize first letter of the name
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}