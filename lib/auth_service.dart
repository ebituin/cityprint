import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthService {
  static Future<AuthResponse> signUp(String email, String password) async {
    try {
      print(email);
      print(password);
      return await supabase.auth.signUp(email: email, password: password);
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign-in failed: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  static Future<void> insertUserData({
    required String userId,
    required String name,
    required String email,
    required String role,
    String? businessName,
  }) async {
    try {
      await supabase.from('Users').upsert({
        'id': userId,
        'name': name,
        'email': email,
      });

      if (role == 'seller') {
        await supabase.from('Sellers').upsert({
          'user_id': userId,
          'business_name': businessName,
        });
      } else if (role == 'user') {
        await supabase.from('Customers').upsert({'user_id': userId});
      }
    } catch (e) {
      throw Exception('Failed to insert user data: ${e.toString()}');
    }
  }
}

