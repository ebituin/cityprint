import 'package:cityprint/service/database.dart';
import 'package:cityprint/mediaSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  bool hasStore;
  HomePage({this.hasStore = false, super.key});
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
    _checkIfUserHasStore();
  }

  Future<void> _checkIfUserHasStore() async {
    final result = await checkIfUserHasStore();
    if (!mounted) return; // ensures the widget is still in the tree
    setState(() {
      widget.hasStore = result;
    });
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
    SizeConfig.init(context);
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
      drawer: Drawer(
        backgroundColor: const Color(0xFFD9D9D9),
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                  widget.hasStore
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
        ),
      ),
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

  Future<void> _placeOrder({bool? isPayment}) async {
    bool isPaid = isPayment ?? false;
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to place an order.")),
      );
      return;
    }

    final storeOwnerId = widget.business['user_id'];
    if (currentUser.id == storeOwnerId) {
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

      try {
        if (quantity > 0) {
          if (!mounted) return;
          await Supabase.instance.client.from('orders').insert({
            'user_id': currentUser.id,
            'business_id': widget.business['business_id'],
            'item_id': item['item_id'],
            'quantity': quantity,
            'total_price': item['price'] * quantity,
            'status': isPaid ? 'paid' : 'pending',
          });
          print('ordered!.');
          !isPaid
              ? ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Color(0xFFB388EB),
                  content: Text('Order placed. Proceed to payment.'),
                ),
              )
              : null;
          print('ordered1!.');
        }
        print('ordered2!.');
        return;
      } catch (e) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Color(0xFFB388EB),
                contentPadding: EdgeInsets.all(16),
                content: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Prevents it from expanding too much
                  children: [
                    Text(
                      'Error placing order!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
        );

        print('Error placing order: $e');
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
            child: CircularProgressIndicator(color: Color(0xFFB388EB)),
          );
        },
      );

      // Simulate payment processing
      await Future.delayed(Duration(seconds: 2));

      // Update order status to paid
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        if (!mounted) return;
        await Supabase.instance.client
            .from('orders')
            .update({'status': 'paid'})
            .eq('user_id', currentUser.id)
            .eq('status', 'pending_payment');
        _placeOrder(isPayment: true);
        print('paid!.');
        Navigator.pop(context);
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Color(0xFFB388EB),
                title: Text(
                  'payment successful',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Your order has been successfully processed.',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
        );
      }
      print('paid1!.');
      // Close loading indicator
      print('paid2!.');

      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        await Supabase.instance.client
            .from('orders')
            .update({'status': 'declined'})
            .eq('user_id', currentUser.id)
            .eq('status', 'pending_payment');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFFB388EB),
          content: Text('Payment failed. Please try again.'),
        ),
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
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color(0xFFB388EB),
                            content: Text('No items selected.'),
                          ),
                        );
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
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_quantities.values.any((quantity) => quantity > 0)) {
                        _processPayment();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color(0xFFB388EB),
                            content: Text('No items selected.'),
                          ),
                        );
                      }
                    },
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
  String? _selectedGender;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _name;
  String? _email;
  String? _birthdate;
  String? _phone;
  String? _emergencyContact;
  String? _address;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    try {
      await getUserProfile();
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _name = prefs.getString('name');
        _email = prefs.getString('email');
        _birthdate = prefs.getString('birthdate');
        _phone = prefs.getString('phone');
        _emergencyContact = prefs.getString('emergency_contact');
        _address = prefs.getString('address');
        _gender = prefs.getString('gender');
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user profile: $e');
    }
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();

      final name =
          _usernameController.text.trim().isNotEmpty
              ? _usernameController.text.trim()
              : prefs.getString('name') ?? '';

      final email =
          _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : prefs.getString('email') ?? '';

      final birthdate =
          _birthdateController.text.trim().isNotEmpty
              ? _birthdateController.text.trim()
              : prefs.getString('birthdate') ?? '';

      final phone =
          _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : prefs.getString('phone') ?? '';

      final emergencyContact =
          _emergencyContactController.text.trim().isNotEmpty
              ? _emergencyContactController.text.trim()
              : prefs.getString('emergencyContact') ?? '';

      final address =
          _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : prefs.getString('address') ?? '';

      final gender =
          _selectedGender != null && _selectedGender!.isNotEmpty
              ? _selectedGender
              : prefs.getString('gender') ?? '';

      await UserService.insertUser(
        true,
        name,
        email,
        birthdate,
        phone,
        emergencyContact,
        address,
        gender!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
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
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.purple.shade50],
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
                                    labelText: _name,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.person),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  enabled: _isEditing,
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _birthdateController,
                                  decoration: InputDecoration(
                                    labelText: _birthdate,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.calendar_today),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  enabled: _isEditing,
                                  readOnly: true,
                                  onTap:
                                      _isEditing
                                          ? () async {
                                            final DateTime? picked =
                                                await showDatePicker(
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
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedGender,
                                      isExpanded: true,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      items:
                                          ['Male', 'Female', 'Other']
                                              .map(
                                                (gender) => DropdownMenuItem(
                                                  value: gender,
                                                  child: Text(gender),
                                                ),
                                              )
                                              .toList(),
                                      onChanged:
                                          _isEditing
                                              ? (value) {
                                                if (value != null) {
                                                  setState(
                                                    () =>
                                                        _selectedGender = value,
                                                  );
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
                                    labelText: _phone,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.phone),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.phone,
                                  validator:
                                      _phone == null
                                          ? (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your phone number';
                                            }
                                            return null;
                                          }
                                          : null,
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: _email,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.email),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _emergencyContactController,
                                  decoration: InputDecoration(
                                    labelText: _emergencyContact,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.emergency),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.phone,
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
                                    labelText: _address,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.location_on),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  enabled: _isEditing,
                                  maxLines: 3,
                                  validator:
                                      _address == null
                                          ? (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your address';
                                            }
                                            return null;
                                          }
                                          : null,
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
