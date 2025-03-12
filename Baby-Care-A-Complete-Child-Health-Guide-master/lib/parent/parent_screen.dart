import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats/screens/register_screen.dart';
import 'package:whats/parent/home_page.dart';
import 'package:whats/parent/videos_page.dart';
import 'package:whats/parent/community_page.dart';
import 'package:whats/parent/profile_page.dart';
import 'package:whats/parent/chatbot_page.dart';

class ParentScreen extends StatefulWidget {
  final String name;

  const ParentScreen({super.key, required this.name});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _pages = [
      HomePage(name: widget.name),
      const VideosPage(),
      const CommunityPage(),
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
      MaterialPageRoute(builder: (context) =>  RegisterScreen()),
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
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'Videos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotPage()),
            );
          },
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),
    );
  }
}
