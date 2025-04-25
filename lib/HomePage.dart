import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    routes: {
      '/login': (context) => Placeholder(), // Replace with actual LoginPage
    },
  ));
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      drawer: AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('businesses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No businesses available yet.'));
          }

          final businesses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              var business = businesses[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(business['name'] ?? 'No Name'),
                subtitle: Text(business['location'] ?? 'No Location'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessDetailPage(business: business),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class BusinessDetailPage extends StatefulWidget {
  final Map<String, dynamic> business;

  const BusinessDetailPage({Key? key, required this.business}) : super(key: key);

  @override
  _BusinessDetailPageState createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  final Map<String, int> _quantities = {}; // Track quantities for each item

  @override
  void initState() {
    super.initState();
    // Initialize quantities for each item to 0 by default
    final items = widget.business['items'] ?? [];
    for (var item in items) {
      _quantities[item] = 0;  // Set default quantity to 0
    }
  }

  // Function to place an order with quantity
  Future<void> _placeOrder(BuildContext context) async {
    try {
      final items = widget.business['items'] ?? [];
      final List<Map<String, dynamic>> orders = [];

      // Check the quantity for each item and create an order if the quantity is greater than 0
      for (var item in items) {
        final quantity = _quantities[item] ?? 0;
        if (quantity > 0) {
          orders.add({
            'item': item,
            'quantity': quantity,
            'status': 'pending',
          });
        }
      }

      if (orders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one item to order.')));
        return;
      }

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You need to be logged in to place an order')));
        return;
      }

      // Store the order in Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'user_id': user.uid,
        'business_id': widget.business['id'], // Assuming the business has an 'id' field
        'items': orders,
        'total': orders.fold(0, (sum, order) {
          // Ensure quantity is treated as an integer for multiplication
          int quantity = (order['quantity'] as num).toInt();
          return sum + (quantity * 10);
        }),
        // You can calculate total dynamically
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.business['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.business['name'] ?? 'Business Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              widget.business['name'] ?? 'No Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.business['description'] ?? 'No Description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Location: ${widget.business['location'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Text('Available Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ...items.map((item) {
              return ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(item.toString())),
                    Text(' - '),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_quantities[item] != null && _quantities[item]! > 0) {
                            _quantities[item] = _quantities[item]! - 1;
                          }
                        });
                      },
                    ),
                    Text(_quantities[item].toString()),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _quantities[item] = (_quantities[item] ?? 0) + 1;
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _placeOrder(context),  // Order confirmation button
              child: Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}


class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
