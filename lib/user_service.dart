import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class UserService {
  static Future<void> insertUser(String id, String name, String email) async {
    await supabase.from('Users').insert({
      'id': id,
      'name': name,
      'email': email,
    });
  }

  static Future<void> insertSeller(String userId, String businessName) async {
    await supabase.from('Sellers').insert({
      'user_id': userId,
      'business_name': businessName,
    });
  }

  static Future<void> insertCustomer(String userId) async {
    await supabase.from('Customers').insert({
      'user_id': userId,
    });
  }

  static Future<Map<String, dynamic>?> getBusinessName(String userId) async {
    final response = await supabase
        .from('Sellers')
        .select('business_name')
        .eq('user_id', userId)
        .single();
    return response;
  }
}
