import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Cache user data after successful login
      final user = response.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id);
        await prefs.setString('email', email);
      }

      return response;
    } catch (e) {
      throw Exception('Sign-in failed: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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

      // Save in cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('name', name);
      await prefs.setString('email', email);
    } catch (e) {
      print('Error in insertUserData: $e');
      if (e.toString().contains('duplicate key')) {
        print('Data already exists in the database');
        return;
      }
      throw Exception('Failed to insert user data: ${e.toString()}');
    }
  }
}

class UserService {
  static Future<void> insertUser(
    bool update,
    String name,
    String email,
    String birthdate,
    String phone,
    String emergencyContact,
    String address,
    String gender,
  ) async {
    try {
      final userId = (await Supabase.instance.client.auth.currentUser)!.id;

      if (update) {
        await supabase
            .from('users')
            .update({
              'name': name,
              'email': email,
              'birthdate': birthdate,
              'phone': phone,
              'emergency_contact': emergencyContact,
              'address': address,
              'gender': gender,
            })
            .eq('user_id', userId);
      } else {
        if (userId == null) return;
        await supabase.from('users').insert({
          'user_id': userId,
          'name': name,
          'email': email,
        });
      }
    } catch (e) {
      print('Error in insertUser: $e');
      throw Exception('Failed to insert user: $e');
    }
  }

  static Future<void> insertBusiness(String userId, String businessName) async {
    await supabase.from('business').insert({
      'business_id': userId,
      'name': businessName,
    });
  }

  static Future<String?> getBusinessName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final res =
        await Supabase.instance.client
            .from('Sellers')
            .select('business_name')
            .eq('user_id', user.id)
            .maybeSingle();

    return res?['business_name'];
  }

  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response =
          await supabase
              .from('orders')
              .update({'status': status})
              .eq('order_id', orderId)
              .select()
              .maybeSingle();

      if (response == null) {
        throw Exception('Order not found or failed to update.');
      }

      print('Order status updated to $status');
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchOrdersForBusiness(
    String businessId,
  ) async {
    try {
      final response = await supabase
          .from('orders')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }
}

Future<bool> checkIfUserHasStore() async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final response =
          await Supabase.instance.client
              .from('business')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
      return response != null;
    }
    return false;
  } catch (e) {
    print('Error checking store: $e');
    return false;
  }
}

Future<Map<String, dynamic>?> getUserProfile() async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final response =
        await supabase
            .from('users')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

    if (response == null) return null;

    final prefs = await SharedPreferences.getInstance();

    // Save to prefs
    await prefs.setString('name', response['name'] ?? '');
    await prefs.setString('email', response['email'] ?? '');

    await prefs.setString('birthdate', response['birthdate'].toString());

    if (response['phone'] != null) {
      await prefs.setString('phone', response['phone'].toString());
    }
    if (response['emergency_contact'] != null) {
      await prefs.setString(
        'emergency_contact',
        response['emergency_contact'].toString(),
      );
    }
    await prefs.setString('address', response['address'] ?? '');
    if (response['gender'] != null) {
      await prefs.setString('gender', response['gender'] ?? '');
    }

    print(response?['name']);
    print(response?['email']);
    print(response?['birthdate']);
    print(response?['phone']);
    print(response?['emergency_contact']);
    print(response?['address']);
    print(response?['gender']);
    return response;
  } catch (e) {
    print('Error getting user profile: $e');
    return null;
  }
}
