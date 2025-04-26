import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrdersPage()),
              );
            },
          ),
        ],
      ),
      
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

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Orders')),
        body: Center(child: Text('You must be logged in to view orders.')),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Orders'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: ['pending', 'accepted', 'cancelled'].map((status) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .where('status', isEqualTo: status)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final orders = snapshot.data!.docs;
                if (orders.isEmpty) return Center(child: Text('No $status orders.'));

                return ListView(
                  children: orders.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['item']),
                      subtitle: Text('Quantity: ${data['quantity']}'),
                      trailing: Text(data['status']),
                    );
                  }).toList(),
                );
              },
            );
          }).toList(),
        ),
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
  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;

    for (var entry in _quantities.entries) {
      if (entry.value > 0) {
        await firestore.collection('orders').add({
          'userId': user.uid,
          'item': entry.key,
          'quantity': entry.value,
          'status': 'pending', // default on creation
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed!')),
    );

    setState(() {
      _quantities.clear(); // clear cart
    });
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
          padding: EdgeInsets.all(16),
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
              onPressed: () => _placeOrder(),  // Order confirmation button
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
