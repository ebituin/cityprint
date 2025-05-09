import 'package:cityprint/BusinessSettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cityprint/auth_service.dart';

// App Drawer
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
                      color: Colors.deepPurple,
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
                      Navigator.pushReplacementNamed(context, '/business');
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
  bool hasStore = false;
  bool isLoading = true;

  final List<Map<String, String>> pendingOrders = [
    {'order': 'Order #1001', 'details': '3x A4 Posters, 1x Banner'},
    {'order': 'Order #1002', 'details': '50x Business Cards'},
  ];

  final List<Map<String, String>> acceptedOrders = [];
  final List<Map<String, String>> declinedOrders = [];

  @override
  void initState() {
    super.initState();
    _checkStore();
  }

  Future<void> _checkStore() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response =
            await Supabase.instance.client
                .from('business')
                .select()
                .eq('user_id', user.id)
                .maybeSingle();
        setState(() {
          hasStore = response != null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking store: $e');
      setState(() => isLoading = false);
    }
  }

  void _acceptOrder(int index) {
    setState(() {
      acceptedOrders.add(pendingOrders[index]);
      pendingOrders.removeAt(index);
    });
  }

  void _declineOrder(int index) {
    setState(() {
      declinedOrders.add(pendingOrders[index]);
      pendingOrders.removeAt(index);
    });
  }

  Widget _buildOrderCard(
    Map<String, String> order, {
    bool showButtons = false,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['order'] ?? 'No Name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(order['details'] ?? 'No Details'),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        backgroundColor: const Color(0xFFB388EB),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/businessSettings');
            },
          ),
        ],
      ),
      drawer: AppDrawer(hasStore: hasStore),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Pending Orders'),
              if (pendingOrders.isEmpty)
                const Center(child: Text('No pending orders.')),
              ...pendingOrders.asMap().entries.map((entry) {
                int index = entry.key;
                var order = entry.value;
                return _buildOrderCard(
                  order,
                  showButtons: true,
                  onAccept: () => _acceptOrder(index),
                  onDecline: () => _declineOrder(index),
                );
              }),

              const SizedBox(height: 24),
              _buildSectionTitle('Accepted Orders'),
              if (acceptedOrders.isEmpty)
                const Center(child: Text('No accepted orders.')),
              ...acceptedOrders.map((order) => _buildOrderCard(order)).toList(),

              const SizedBox(height: 24),
              _buildSectionTitle('Declined Orders'),
              if (declinedOrders.isEmpty)
                const Center(child: Text('No declined orders.')),
              ...declinedOrders.map((order) => _buildOrderCard(order)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
