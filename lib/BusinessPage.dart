import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_service.dart'; // Ensure UserService is imported

class AppDrawer extends StatefulWidget {
  final bool hasStore;
  const AppDrawer({Key? key, required this.hasStore}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFD9D9D9),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text('CityPrint'),
                  accountEmail: Text('Welcome to CityPrint!'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 42,
                      color: Color(0xFFB388EB),
                    ),
                  ),
                  decoration: BoxDecoration(color: Colors.deepPurple),
                ),
                ListTile(
                  leading: Icon(Icons.person_2_outlined, size: 24),
                  title: Text('Account', style: TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/business');
                  },
                ),
                if (widget.hasStore)
                  ListTile(
                    leading: Icon(Icons.store, size: 24),
                    title: Text(
                      'Store Settings',
                      style: TextStyle(fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/businessSettings',
                      );
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.settings_outlined, size: 24),
                  title: Text('Settings', style: TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/business');
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exit_to_app_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Back to User',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BusinessPage extends StatefulWidget {
  const BusinessPage({Key? key}) : super(key: key);

  @override
  _BusinessPageState createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  bool hasStore = true;
  bool isLoading = true;
  List<Map<String, dynamic>> pendingOrders = [];
  List<Map<String, dynamic>> acceptedOrders = [];
  List<Map<String, dynamic>> declinedOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Fetch business ID using user ID
        final businessResponse =
            await Supabase.instance.client
                .from('business')
                .select('business_id')
                .eq('user_id', user.id)
                .maybeSingle();

        // Log the business response
        print('Business Response: $businessResponse');

        if (businessResponse == null ||
            businessResponse['business_id'] == null) {
          throw Exception('No business found for this user.');
        }

        final businessId = businessResponse['business_id'] as String;

        // Fetch orders using the business_id
        final ordersResponse = await Supabase.instance.client
            .from('orders')
            .select('order_id, status, item_id, quantity, total_price')
            .eq('business_id', businessId);

        // Log the orders response to debug
        print('Orders Response: $ordersResponse');

        if (ordersResponse is List) {
          final List<Map<String, dynamic>> orders = [];

          for (var order in ordersResponse) {
            final itemId = order['item_id'];

            // Fetch the item details using the item_id
            final itemResponse =
                await Supabase.instance.client
                    .from('item')
                    .select('name, price')
                    .eq('item_id', itemId)
                    .maybeSingle();

            // Log the item response
            print('Item Response for item_id $itemId: $itemResponse');

            if (itemResponse != null) {
              order['name'] = itemResponse['name'];
              order['price'] = itemResponse['price'];
            } else {
              // If no item found, log it
              print('Item with item_id $itemId not found.');
            }

            orders.add(order);
          }

          setState(() {
            // Separate orders by their status
            pendingOrders =
                orders.where((order) => order['status'] == 'pending').toList();
            acceptedOrders =
                orders.where((order) => order['status'] == 'accepted').toList();
            declinedOrders =
                orders.where((order) => order['status'] == 'declined').toList();
            isLoading = false;
          });
        } else {
          print('No orders found for the business.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('No user is currently logged in.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus({
    required Map<String, dynamic> order,
    required String newStatus,
    required List<Map<String, dynamic>> sourceList,
    required List<Map<String, dynamic>> targetList,
  }) async {
    final orderId = order['order_id'];

    if (orderId != null) {
      try {
        await UserService.updateOrderStatus(
          orderId: orderId,
          status: newStatus,
        );

        // Clone the order and update the status
        final updatedOrder = Map<String, dynamic>.from(order);
        updatedOrder['status'] = newStatus;

        setState(() {
          sourceList.removeWhere((o) => o['order_id'] == orderId);
          targetList.add(updatedOrder);
        });
      } catch (e) {
        print('Error updating order status: $e');
      }
    }
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order, {
    bool showButtons = false,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) {
    final itemName = order['name'] ?? 'Unnamed Item';
    final quantity = order['quantity'] ?? 0;
    final price = order['price'] ?? 0;
    final totalPrice = order['total_price'] ?? 0;
    final details = order['details'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Quantity: $quantity'),
            Text('Price per unit: \$${price.toStringAsFixed(2)}'),
            Text('Total price: \$${totalPrice.toStringAsFixed(2)}'),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Details: $details'),
            ],
            if (showButtons) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onDecline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Map<String, dynamic>> orders, {
    bool showButtons = false,
    Function(int)? onAccept,
    Function(int)? onDecline,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (orders.isEmpty)
          const Center(child: Text('No orders in this section.'))
        else
          ...orders.asMap().entries.map((entry) {
            final index = entry.key;
            final order = entry.value;
            return _buildOrderCard(
              order,
              showButtons: showButtons,
              onAccept: () => onAccept?.call(index),
              onDecline: () => onDecline?.call(index),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        backgroundColor: const Color(0xFFB388EB),
      ),
      drawer: AppDrawer(hasStore: hasStore),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Pending Orders',
                      pendingOrders,
                      showButtons: true,
                      onAccept:
                          (index) => _updateOrderStatus(
                            order: pendingOrders[index],
                            newStatus: 'accepted',
                            sourceList: pendingOrders,
                            targetList: acceptedOrders,
                          ),
                      onDecline:
                          (index) => _updateOrderStatus(
                            order: pendingOrders[index],
                            newStatus: 'declined',
                            sourceList: pendingOrders,
                            targetList: declinedOrders,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection('Accepted Orders', acceptedOrders),
                    const SizedBox(height: 24),
                    _buildSection('Declined Orders', declinedOrders),
                  ],
                ),
              ),
    );
  }
}
