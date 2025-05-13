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
      final response = await supabase
          .from('orders')
          .update({'status': status})
          .eq('order_id', orderId);

      if (response.error != null) {
        throw Exception(
          'Error updating order status: ${response.error?.message}',
        );
      }

      print('Order status updated to $status');
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }
  static Future<List<Map<String, dynamic>>> fetchOrdersForBusiness(String businessId) async {
  try {
    final response = await supabase
        .from('orders')
        .select()
        .eq('business_id', businessId)
        .order('created_at', ascending: false);

    // Ensure the response is properly cast to a list of maps
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error fetching orders: $e');
    throw Exception('Failed to fetch orders: $e');
  }
}

}
