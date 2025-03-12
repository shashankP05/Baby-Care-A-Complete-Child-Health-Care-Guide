import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats/screens/login_screen.dart';
import 'package:whats/parent/user_details_page.dart';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> toggleDarkMode;
  const ProfilePage({super.key, required this.isDarkMode, required this.toggleDarkMode});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = '';
  String _userEmail = '';
  bool _isDarkMode = false;
  bool _isNotificationsOn = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _isDarkMode = widget.isDarkMode;
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userName = userData.data()?['name'] ?? 'User';
        _userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _isNotificationsOn);
  }

  Future<void> _changePassword() async {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text == confirmPasswordController.text &&
                  newPasswordController.text.isNotEmpty) {
                try {
                  await _auth.currentUser?.updatePassword(newPasswordController.text);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed successfully!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match!')),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildProfileMenuSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, size: 50, color: Colors.blue.shade700),
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (_userEmail.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(_userEmail, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        ],
      ],
    );
  }

  Widget _buildProfileMenuSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildProfileMenuItem('Update Profile', Icons.edit, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserDetailsPage()),
            ).then((_) => _loadUserData());
          }),
          _buildDivider(),
          _buildProfileMenuItem('Change Password', Icons.lock_outline, _changePassword),
          _buildDivider(),
          _buildProfileMenuItem('Settings', Icons.settings, () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() => _isDarkMode = value);
                              widget.toggleDarkMode(value);
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Notifications'),
                            value: _isNotificationsOn,
                            onChanged: (value) {
                              setState(() => _isNotificationsOn = value);
                              _saveSettings();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }),
          _buildDivider(),
          _buildProfileMenuItem('Help & Support', Icons.help_outline, _showHelpDialog),
          _buildDivider(),
          _buildProfileMenuItem('Logout', Icons.logout, _logout, isLogout: true),
        ],
      ),
    );
  }

  Future<void> _showHelpDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('For support, contact: prathviz.111@gmail.com 8546954246'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(String title, IconData icon, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => const Divider(height: 1, thickness: 1);
}
