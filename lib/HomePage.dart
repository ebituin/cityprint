import 'package:cityprint/auth_service.dart';
import 'package:cityprint/mediaSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cityprint/BusinessDetailPage.dart';

// App Drawer
class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool hasStore = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasStore();
  }

  Future<void> _checkIfUserHasStore() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final response =
            await Supabase.instance.client
                .from('business')
                .select()
                .eq('user_id', userId)
                .maybeSingle();
        setState(() {
          hasStore = response != null;
        });
      }
    } catch (e) {
      print('Error checking store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Drawer(
      backgroundColor: const Color(0xFFD9D9D9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: SizeConfig.screenHeight * 0.25,
                  color: Colors.deepPurple,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40,
                        child: Icon(
                          Icons.person,
                          size: 42,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Account Name',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        'Welcome to CityPrint!',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildAccountSection(Icon(Icons.add_ic_call_outlined), 'hi'),
        ],
      ),
    );
  }
}

Widget _buildAccountSection(Icon icon, String text) {
  return Row(
    children: [
      GestureDetector(
        onTap: () {},
        child: Expanded(
          child: Container(
            child: Row(
              children: [icon, Text(text, style: TextStyle(fontSize: 20))],
            ),
          ),
        ),
      ),
    ],
  );
}

// Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 UserAccountsDrawerHeader(
//                   accountName: Text('CityPrint'),
//                   accountEmail: Text('Welcome to CityPrint!'),
//                   currentAccountPicture: CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child:
//                   ),
//                   decoration: BoxDecoration(color: Colors.deepPurple),
//                 ),
//                 ListTile(
//                   leading:
//                   title: Text('Account', style: TextStyle(fontSize: 20)),
//                   onTap: () {
//                     Navigator.pushReplacementNamed(context, '/business');
//                   },
//                 ),
//                 hasStore
//                     ? ListTile(
//                       leading: Icon(Icons.shopping_bag_outlined, size: 24),
//                       title: Text('Store', style: TextStyle(fontSize: 20)),
//                       onTap: () {
//                         Navigator.pushReplacementNamed(context, '/business');
//                       },
//                     )
//                     : ListTile(
//                       leading: Icon(Icons.shopping_bag_outlined, size: 24),
//                       title: Text(
//                         'Create Store',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       onTap: () {
//                         Navigator.pushReplacementNamed(
//                           context,
//                           '/signupbusiness',
//                         );
//                       },
//                     ),
//                 ListTile(
//                   leading: Icon(Icons.settings_outlined, size: 24),
//                   title: Text('Settings', style: TextStyle(fontSize: 20)),
//                   onTap: () {
//                     Navigator.pushReplacementNamed(context, '/business');
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             color: Colors.deepPurple,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pushReplacementNamed(context, '/');
//                   AuthService.signOut();
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.exit_to_app, size: 40, color: Colors.white),
//                     SizedBox(width: 10),
//                     Text(
//                       'Logout',
//                       style: TextStyle(fontSize: 20, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

// Home Page
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _businesses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId != null) {
        final response = await Supabase.instance.client
            .from('business')
            .select('*, item(*)')
            .order('name');

        if (response is List) {
          setState(() {
            // Filter out the user's own business
            _businesses =
                List<Map<String, dynamic>>.from(
                  response,
                ).where((business) => business['user_id'] != userId).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading businesses: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _businessMatchesSearch(Map<String, dynamic> business) {
    final name = (business['name'] ?? '').toString().toLowerCase();
    final items = (business['item'] ?? []) as List<dynamic>;

    if (name.contains(_searchQuery)) return true;

    for (var item in items) {
      if (item['name'].toString().toLowerCase().contains(_searchQuery)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final filteredBusinesses =
        _businesses.where((b) => _businessMatchesSearch(b)).toList();

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
                suffixIcon:
                    _searchController.text.isNotEmpty
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
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredBusinesses.isEmpty
                    ? Center(child: Text('No businesses found.'))
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredBusinesses.length,
                      itemBuilder: (context, index) {
                        var business = filteredBusinesses[index];
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
                            title: Text(
                              business['name']?.toString() ?? 'No Name',
                            ),
                            subtitle: Text(
                              business['description']?.toString() ??
                                  'No Description',
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => BusinessDetailPage(
                                        business: business,
                                      ),
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
class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> pending = [];
  List<Map<String, dynamic>> accepted = [];
  List<Map<String, dynamic>> cancelled = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('orders')
          .select('*, item(name)')
          .eq('user_id', user.id);

      final data = List<Map<String, dynamic>>.from(response);

      if (!mounted) return; // ⛔ prevent setState if widget is disposed

      setState(() {
        pending = data.where((o) => o['status'] == 'pending').toList();
        accepted = data.where((o) => o['status'] == 'accepted').toList();
        cancelled = data.where((o) => o['status'] == 'declined').toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      if (!mounted) return; // ⛔ check again before setting state
      setState(() => isLoading = false);
    }
  }

  Widget buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(child: Text('No orders in this section.'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final itemName = order['item']?['name'] ?? 'Unknown item';
        return ListTile(
          leading: Icon(Icons.receipt),
          title: Text(itemName),
          subtitle: Text(
            'Qty: ${order['quantity']} • ₱${order['total_price']}',
          ),
          trailing: Text(order['status']),
        );
      },
    );
  }

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
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    buildOrderList(pending),
                    buildOrderList(accepted),
                    buildOrderList(cancelled),
                  ],
                ),
      ),
    );
  }
}

// Business Detail Page
class BusinessDetailPage extends StatefulWidget {
  final Map<String, dynamic> business;

  const BusinessDetailPage({Key? key, required this.business})
    : super(key: key);

  @override
  _BusinessDetailPageState createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  final Map<String, int> _quantities = {};
  late int totalPrice;
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    final items = widget.business['item'] ?? [];
    for (var item in items) {
      _quantities[item['name']] = 0;
    }
    quantity = _quantities['item1'] ?? 0;
  }

  List<dynamic> items = [];

  Future<void> _placeOrder() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      print('User not authenticated');
      return;
    }

    final storeOwnerId = widget.business['user_id'];
    if (currentUser.id == storeOwnerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can't order from your own store.")),
      );
      return;
    }

    for (var item in items) {
      final int quantity = _quantities[item['name']] ?? 0;

      if (quantity > 0) {
        await Supabase.instance.client.from('orders').insert({
          'user_id': currentUser.id,
          'business_id': widget.business['business_id'],
          'item_id': item['item_id'],
          'quantity': quantity,
          'total_price': item['price'] * quantity,
          'status': 'pending',
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    items = widget.business['item'] ?? [];

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
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: const Color(0xFFB388EB),
                ),
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
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item['description'] != null)
                                  Text(
                                    item['description'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '₱${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            color: const Color(0xFFB388EB),
                            onPressed: () {
                              setState(() {
                                if (_quantities[item['name']] != null &&
                                    _quantities[item['name']]! > 0) {
                                  _quantities[item['name']] =
                                      _quantities[item['name']]! - 1;
                                }
                              });
                            },
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_quantities[item['name']]}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            color: const Color(0xFFB388EB),
                            onPressed: () {
                              setState(() {
                                _quantities[item['name']] =
                                    (_quantities[item['name']] ?? 0) + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_quantities.values.any((quantity) => quantity > 0)) {
                  _placeOrder();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Order simulated.')));
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('No items selected.')));
                }
              },
              icon: Icon(Icons.shopping_cart_checkout),
              label: Text(
                'Place Order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
