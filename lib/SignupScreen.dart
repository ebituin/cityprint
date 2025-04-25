import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String selectedRole;

  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _sellerBusinessController = TextEditingController();
  final _sellerOwnerController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedRole = ModalRoute.of(context)?.settings.arguments as String? ?? 'user';
  }

  Future<void> saveUserToFirestore({
    required String role,
    required String name,
    required String email,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _submit() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = selectedRole == 'user'
          ? _userController.text.trim()
          : _sellerOwnerController.text.trim();

      // Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save to Firestore
      await saveUserToFirestore(
        role: selectedRole,
        name: name,
        email: email,
      );

      // Navigate based on role
      if (selectedRole == 'user') {
        Navigator.pushNamed(context, '/home');
      } else {
        Navigator.pushNamed(context, '/business');
      }
    } catch (e) {
      print('Signup error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up as ${selectedRole[0].toUpperCase()}${selectedRole.substring(1)}')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (selectedRole == 'user') ...[
              TextField(
                controller: _userController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ] else ...[
              TextField(
                controller: _sellerBusinessController,
                decoration: InputDecoration(labelText: 'Business Name'),
              ),
              TextField(
                controller: _sellerOwnerController,
                decoration: InputDecoration(labelText: 'Owner Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
extension StringExtensions on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}