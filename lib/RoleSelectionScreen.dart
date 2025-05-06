import 'package:cityprint/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupBusinessScreen extends StatefulWidget {
  @override
  State<SignupBusinessScreen> createState() => _SignupBusinessScreenState();
}

class _SignupBusinessScreenState extends State<SignupBusinessScreen> {
  final _userController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _userController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      // Sign up the user
      final res = await AuthService.signUp(email, password);
      final user = res.user;

      if (user == null) throw Exception('Signup failed');

      // Insert user data into the database
      await AuthService.insertUserData(
        userId: user.id,
        name: name,
        email: email,
      );

      // Notify user of success
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup successful!')));

      // Navigate to the appropriate screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Log and show the error
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: 'Full Name'),
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
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
