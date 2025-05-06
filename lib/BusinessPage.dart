import 'package:cityprint/BusinessSettingsPage.dart';
import 'package:flutter/material.dart';
import 'BusinessSettingsPage.dart';

class BusinessPage extends StatefulWidget {
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['order'] ?? 'No Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(order['details'] ?? 'No Details'),
            if (showButtons) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onAccept,
                    child: Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onDecline,
                    child: Text('Decline'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
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
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BusinessSettingsPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Container(
                alignment: Alignment.center,
                child: Text('Business Name', style: TextStyle()),
              ),
            ),
            ListTile(title: Text('data')),
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
              if (pendingOrders.isEmpty) Text('No pending orders.'),
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

              SizedBox(height: 24),
              _buildSectionTitle('Accepted Orders'),
              if (acceptedOrders.isEmpty) Text('No accepted orders.'),
              ...acceptedOrders.map((order) => _buildOrderCard(order)).toList(),

              SizedBox(height: 24),
              _buildSectionTitle('Declined Orders'),
              if (declinedOrders.isEmpty) Text('No declined orders.'),
              ...declinedOrders.map((order) => _buildOrderCard(order)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
