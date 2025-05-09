/*import 'package:cityprint/BusinessSettingsPage.dart';
import 'package:flutter/material.dart';

class BusinessPage extends StatefulWidget {
  @override
  _BusinessPageState createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  final List<Map<String, String>> pendingOrders = [
    // {'order': 'Order 1', 'details': 'Details of order 1'},
    // {'order': 'Order 2', 'details': 'Details of order 2'},
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

  Widget _buildOrderCard(Map<String, String> order,
      {bool showButtons = false,
      VoidCallback? onAccept,
      VoidCallback? onDecline}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order['order'] ?? 'No Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onDecline,
                    child: Text('Decline'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
      child:
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

      
    );
  }
}*/
