import 'package:cityprint/BusinessSettingsPage.dart';
import 'package:flutter/material.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({Key? key}) : super(key: key);

  @override
  _BusinessPageState createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  final List<Map<String, String>> pendingOrders = [
    {'order': 'Order #1001', 'details': '3x A4 Posters, 1x Banner'},
    {'order': 'Order #1002', 'details': '50x Business Cards'},
  ];

  final List<Map<String, String>> acceptedOrders = [];
  final List<Map<String, String>> declinedOrders = [];

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
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFB388EB),
              ),
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Business Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/businessSettings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
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
