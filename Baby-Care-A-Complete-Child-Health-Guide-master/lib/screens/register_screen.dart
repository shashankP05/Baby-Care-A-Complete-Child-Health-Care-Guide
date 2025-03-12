import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats/doctor/doctor_screen.dart';
import 'package:whats/parent/parent_screen.dart';
import 'package:whats/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'parent';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveLoginInfo(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('role', role);
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
        });

        await _saveLoginInfo(_selectedRole);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _selectedRole == 'doctor'
                ? DoctorScreen(name: _nameController.text)
                : ParentScreen(name: _nameController.text),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An unexpected error occurred.';
        if (e.code == 'email-already-in-use') {
          errorMessage =
              'This email is already registered. Please log in instead.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password should be at least 6 characters long.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email format.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F5F5), Color(0xFFA3DAE5)],
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png',
                          height: 100, width: 100),
                      const SizedBox(height: 16),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      const Text('Join us today!',
                          style:
                              TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your full name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
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
                                  return 'Please enter a valid email';
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
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                prefixIcon: Icon(Icons.group),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              dropdownColor: Colors.white,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.black54),
                              items: ['parent', 'doctor']
                                  .map((role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(
                                          role.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedRole = value!),
                              menuMaxHeight: 150,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        'Register',
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
                              onPressed: _navigateToLogin,
                              child:
                                  const Text('Already have an account? Log in'),
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
