import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class UserService {
  static Future<void> insertUser(String id, String name, String email) async {
    await supabase.from('users').insert({
      'user_id': id,
      'name': name,
      'email': email,
    });
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

  final res = await Supabase.instance.client
      .from('Sellers')
      .select('business_name')
      .eq('user_id', user.id)
      .maybeSingle();

  return res?['business_name'];
}

}
