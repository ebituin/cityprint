import 'package:cityprint/auth_service.dart';
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
                  title: Text('Profile', style: TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfilePage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shopping_cart_outlined, size: 24),
                  title: Text('Orders', style: TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrdersPage()),
                    );
                  },
                ),
                hasStore
                    ? ListTile(
                      leading: Icon(Icons.shopping_bag_outlined, size: 24),
                      title: Text('Store', style: TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/business');
                      },
                    )
                    : ListTile(
                      leading: Icon(Icons.shopping_bag_outlined, size: 24),
                      title: Text(
                        'Create Store',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/signupbusiness',
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
                  Navigator.pushReplacementNamed(context, '/');
                  AuthService.signOut();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.exit_to_app, size: 40, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
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
  int totalPrice = 99;
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
      // 🛑 Show error: cannot order from own store
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can't order from your own store.")),
      );
      return;
    }

    // Calculate total price
    double totalPrice = 0;
    for (var item in items) {
      final int quantity = _quantities[item['name']] ?? 0;
      if (quantity > 0) {
        totalPrice += (item['price'] as num) * quantity;
      }
    }

    // Create order with pending payment status
    for (var item in items) {
      final int quantity = _quantities[item['name']] ?? 0;

      if (quantity > 0) {
        await Supabase.instance.client.from('orders').insert({
          'user_id': currentUser.id,
          'business_id': widget.business['business_id'],
          'item_id': item['item_id'],
          'quantity': quantity,
          'total_price': totalPrice,
          'status': 'pending_payment',
        });
      }
    }
  }

  Future<void> _processPayment() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Simulate payment processing
      await Future.delayed(Duration(seconds: 2));

      // Update order status to paid
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        await Supabase.instance.client
            .from('orders')
            .update({'status': 'paid'})
            .eq('user_id', currentUser.id)
            .eq('status', 'pending_payment');
      }

      // Close loading indicator
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      // Close loading indicator
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed. Please try again.')),
      );
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_quantities.values.any((quantity) => quantity > 0)) {
                        _placeOrder();
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Order placed. Proceed to payment.')));
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('No items selected.')));
                      }
                    },
                    icon: Icon(Icons.shopping_cart_checkout),
                    label: Text(
                      'Add to Cart',
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
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _processPayment,
                    icon: Icon(Icons.payment),
                    label: Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Page
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  String _selectedGender = 'Male';
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _birthdateController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .single();

        if (response != null) {
          setState(() {
            _usernameController.text = response['username'] ?? '';
            _phoneController.text = response['phone'] ?? '';
            _emailController.text = response['email'] ?? '';
            _addressController.text = response['address'] ?? '';
            _birthdateController.text = response['birthdate'] ?? '';
            _emergencyContactController.text = response['emergency_contact'] ?? '';
            _selectedGender = response['gender'] ?? 'Male';
            _isLoading = false;
          });
        } else {
          // Create new profile if it doesn't exist
          await Supabase.instance.client.from('profiles').insert({
            'user_id': user.id,
            'email': user.email,
          });
          setState(() {
            _emailController.text = user.email ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'user_id': user.id,
          'username': _usernameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'birthdate': _birthdateController.text,
          'emergency_contact': _emergencyContactController.text,
          'gender': _selectedGender,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFB388EB),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.purple.shade50,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: const Color(0xFFB388EB),
                                ),
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFB388EB),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.camera_alt, size: 20),
                                    color: Colors.white,
                                    onPressed: () {
                                      // TODO: Implement image upload
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB388EB),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(Icons.person),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                enabled: _isEditing,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _birthdateController,
                                decoration: InputDecoration(
                                  labelText: 'Birthdate',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(Icons.calendar_today),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                enabled: _isEditing,
                                readOnly: true,
                                onTap: _isEditing
                                    ? () async {
                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          _birthdateController.text =
                                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                        }
                                      }
                                    : null,
                              ),
                              SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedGender,
                                    isExpanded: true,
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    items: ['Male', 'Female', 'Other']
                                        .map((gender) => DropdownMenuItem(
                                              value: gender,
                                              child: Text(gender),
                                            ))
                                        .toList(),
                                    onChanged: _isEditing
                                        ? (value) {
                                            if (value != null) {
                                              setState(() => _selectedGender = value);
                                            }
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB388EB),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(Icons.phone),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(Icons.email),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                enabled: _isEditing,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _emergencyContactController,
                                decoration: InputDecoration(
                                  labelText: 'Emergency Contact',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(Icons.emergency),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter emergency contact';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB388EB),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: 'Complete Address',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(Icons.location_on),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                enabled: _isEditing,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
