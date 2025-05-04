import 'package:cityprint/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final supabase = Supabase.instance.client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedRole =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'user';
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name =
        selectedRole == 'user'
            ? _userController.text.trim()
            : _sellerOwnerController.text.trim();
    final businessName = _sellerBusinessController.text.trim();

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
        role: selectedRole,
        businessName: selectedRole == 'seller' ? businessName : null,
      );

      // Notify user of success
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup successful!')));

      // Navigate to the appropriate screen
      Navigator.pushNamedAndRemoveUntil(context, selectedRole == 'user' ? '/home' : '/business', (Route<dynamic> route) => false);
      
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
      appBar: AppBar(
        title: Text(
          'Sign Up as ${selectedRole[0].toUpperCase()}${selectedRole.substring(1)}',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (selectedRole == 'user') ...[
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
            ElevatedButton(onPressed: _submit, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
