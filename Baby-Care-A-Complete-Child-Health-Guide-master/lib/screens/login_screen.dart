import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats/parent/parent_screen.dart';
import 'package:whats/doctor/doctor_screen.dart';
import 'package:whats/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == true) {
      String? role = prefs.getString('role');
      String? name = prefs.getString('name');

      if (role != null && name != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => role == 'doctor'
                ? DoctorScreen(name: name)
                : ParentScreen(name: name),
          ),
        );
      }
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          throw Exception("User data not found");
        }

        String role = userDoc['role'];
        String name = userDoc['name'];

        await _saveLoginInfo(role, name);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => role == 'doctor'
                ? DoctorScreen(name: name)
                : ParentScreen(name: name),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveLoginInfo(String role, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('role', role);
    await prefs.setString('name', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDEEAF6), Color(0xFF76B5C5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                color: Colors.white, // Darker shade for better contrast
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png',
                          height: 100, width: 100),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      const Text('Login to your account',
                          style:
                              TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your email';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value))
                                  return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              obscureText: true,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.blueGrey)
                                    : const Text(
                                        'Log In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterScreen()),
                                );
                              },
                              child: const Text(
                                'Don’t have an account? Register',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
