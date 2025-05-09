import 'package:cityprint/auth_service.dart';
import 'package:flutter/material.dart';
 
// App Drawer
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('CityPrint'),
            accountEmail: Text('Welcome to CityPrint!'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 42, color: Colors.deepPurple),
            ),
            decoration: BoxDecoration(color: Colors.deepPurple),
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Seller'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/business');
            },
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Seller'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/business');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () {
              AuthService.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}

// Home Page
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _businessMatchesSearch(Map<String, dynamic> business) {
    final name = (business['name'] ?? '').toString().toLowerCase();
    final items = (business['items'] ?? []) as List<dynamic>;

    if (name.contains(_searchQuery)) return true;

    for (var item in items) {
      if (item.toString().toLowerCase().contains(_searchQuery)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final dummyBusinesses = [
      {
        'name': 'QuickPrint Center',
        'description': 'Fast and affordable document printing.',
        'location': 'Downtown Plaza',
        'items': ['Black & White Prints', 'Color Prints', 'Laminating'],
      },
      {
        'name': 'TeeDesign Studio',
        'description': 'Custom t-shirt and apparel printing.',
        'location': '5th Avenue',
        'items': ['T-Shirt Printing', 'Hoodie Printing', 'Logo Embroidery'],
      },
      {
        'name': '3D Forge Lab',
        'description': 'On-demand 3D printing services.',
        'location': 'Innovation Park',
        'items': ['3D Prototypes', 'Resin Prints', 'Model Printing'],
      },
    ];

    final businesses =
        dummyBusinesses.where((b) => _businessMatchesSearch(b)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('CityPrint', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFB388EB),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search businesses or items...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: businesses.isEmpty
                ? Center(child: Text('No businesses found.'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      var business = businesses[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFB388EB),
                            child: Icon(Icons.store, color: Colors.white),
                          ),
                          title: Text(business['name']?.toString() ?? 'No Name'),
                          subtitle:
                              Text(business['location']?.toString() ?? 'No Location'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BusinessDetailPage(business: business),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Orders Page
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Orders', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFB388EB),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('No pending orders.')),
            Center(child: Text('No accepted orders.')),
            Center(child: Text('No cancelled orders.')),
          ],
        ),
      ),
    );
  }
}

// Business Detail Page
class BusinessDetailPage extends StatefulWidget {
  final Map<String, dynamic> business;

  const BusinessDetailPage({Key? key, required this.business}) : super(key: key);

  @override
  _BusinessDetailPageState createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    final items = widget.business['items'] ?? [];
    for (var item in items) {
      _quantities[item] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.business['items'] ?? [];

    bool isSeller = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.business['name'] ?? 'Business Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFB388EB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              widget.business['name'] ?? 'No Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.business['description'] ?? 'No Description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: const Color(0xFFB388EB)),
                SizedBox(width: 5),
                Text(
                  widget.business['location'] ?? 'Unknown Location',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Available Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            ...items.map((item) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(item.toString()),
                  trailing: Container(
                    width: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_quantities[item] != null &&
                                  _quantities[item]! > 0) {
                                _quantities[item] = _quantities[item]! - 1;
                              }
                            });
                          },
                        ),
                        Text('${_quantities[item]}'),
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
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Order simulated.')));
              },
              icon: Icon(Icons.shopping_cart_checkout),
              label: Text(
                'Place Order',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB388EB),
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
