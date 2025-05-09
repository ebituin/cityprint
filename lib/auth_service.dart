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
  }) async {
    try {
      print('Attempting to insert user data for userId: $userId');

      // Insert into users table
      final usersResponse = await supabase.from('users').upsert({
        'user_id': userId,
        'name': name,
        'email': email,
      });
      print('Users table upsert response: $usersResponse');
    } catch (e) {
      print('Error in insertUserData: $e');
      // Check if the error is due to duplicate data
      if (e.toString().contains('duplicate key')) {
        print('Data already exists in the database');
        return; // Silently return if data already exists
      }
      throw Exception('Failed to insert user data: ${e.toString()}');
    }
  }
}
