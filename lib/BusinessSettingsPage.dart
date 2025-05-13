import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'user_service.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({Key? key}) : super(key: key);

  @override
  _BusinessSettingsPageState createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _itemController = TextEditingController();
  final _itemDescController = TextEditingController();
  final _itemPriceController = TextEditingController();

  String? _businessId;
  String? businessName;
  List<Map<String, dynamic>> items = [];
  bool isEditing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _itemController.dispose();
    _itemDescController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessData() async {
    setState(() => isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response =
            await Supabase.instance.client
                .from('business')
                .select('*, item(*)')
                .eq('user_id', user.id)
                .maybeSingle();

        if (response != null) {
          setState(() {
            _businessId = response['business_id'];
            _nameController.text = response['name'] ?? '';
            _descController.text = response['description'] ?? '';
            items =
                (response['item'] as List?)
                    ?.map(
                      (item) => {
                        'name': item['name'] as String,
                        'description': item['description'] as String? ?? '',
                        'price': (item['price'] as num?)?.toDouble() ?? 0.0,
                      },
                    )
                    .toList() ??
                [];
            businessName = response['name'];
          });
        }
      }
    } catch (e) {
      print('Error loading business data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading business data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _addItem() {
    final newItem = _itemController.text.trim();
    final newDesc = _itemDescController.text.trim();
    final priceText = _itemPriceController.text.trim();

    if (newItem.isNotEmpty && priceText.isNotEmpty) {
      try {
        // Simple price parsing
        final price = double.tryParse(priceText);

        if (price == null) {
          print('Failed to parse price: $priceText');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid price number')),
          );
          return;
        }

        if (price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Price must be greater than 0')),
          );
          return;
        }

        print('Successfully parsed price: $price');
        setState(() {
          items.add(<String, Object>{
            'name': newItem,
            'description': newDesc,
            'price': price,
          });
          _itemController.clear();
          _itemDescController.clear();
          _itemPriceController.clear();
        });
      } catch (e) {
        print('Error in _addItem: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding item: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  void _removeItem(int index) async {
    try {
      final item = items[index];
      if (_businessId != null) {
        // Delete from Supabase
        await Supabase.instance.client
            .from('item')
            .delete()
            .eq('business_id', _businessId!)
            .eq('name', item['name'] as String);

        setState(() {
          items.removeAt(index);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Item deleted successfully')));
      }
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('No user logged in');

        if (_businessId != null) {
          // Update business details
          await Supabase.instance.client
              .from('business')
              .update({
                'name': _nameController.text.trim(),
                'description': _descController.text.trim(),
              })
              .eq('business_id', _businessId!);

          // Get existing items
          final existingItems = await Supabase.instance.client
              .from('item')
              .select('name')
              .eq('business_id', _businessId!);

          final existingNames =
              (existingItems as List)
                  .map((item) => (item['name'] as String).trim().toLowerCase())
                  .toSet();

          // Update items
          for (var item in items) {
            final normalizedItem = item['name']!.trim().toLowerCase();
            if (!existingNames.contains(normalizedItem)) {
              await Supabase.instance.client.from('item').insert({
                'business_id': _businessId,
                'name': item['name']!.trim(),
                'description': item['description']!.trim(),
                'price': (item['price'] as num).toDouble(),
              });
            } else {
              // Update existing item
              await Supabase.instance.client
                  .from('item')
                  .update({
                    'description': item['description']!.trim(),
                    'price': (item['price'] as num).toDouble(),
                  })
                  .eq('business_id', _businessId!)
                  .eq('name', item['name']!.trim());
            }
          }
        }

        setState(() {
          businessName = _nameController.text.trim();
          isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Business details saved successfully')),
        );
      } catch (e) {
        print('Error saving business data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving business data: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double businessTitleSize = 24;
    double businessDescriptionSize = 18;
    double itemTitleSize = 24;
    double itemDescriptionSize = 16;
    double itemPriceSize = 18;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB388EB),
        elevation: 0,
        leading: Container(
          width: 47,
          height: 42,
          margin: EdgeInsets.only(left: 23),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF1D1B20), size: 24),
            onPressed: () => Navigator.pushReplacementNamed(context, '/business'),
          ),
        ),
        title: Text(
          businessName ?? 'Store',
          style: TextStyle(
            fontSize: businessTitleSize,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 47),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 85),
                        // Store Information
                        Container(
                          width: 300,
                          height: 240,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child:
                                    isEditing
                                        ? Form(
                                          key: _formKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              TextFormField(
                                                controller: _nameController,
                                                decoration: InputDecoration(
                                                  labelText: 'Business Name',
                                                  border: OutlineInputBorder(),
                                                ),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: businessTitleSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Please enter a business name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 16),
                                              SizedBox(
                                                width: 254,
                                                child: TextFormField(
                                                  controller: _descController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Description',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize:
                                                        businessDescriptionSize,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                  ),
                                                  maxLines: 2,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return 'Please enter a description';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _nameController.text,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: businessTitleSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            SizedBox(
                                              width: 254,
                                              child: Text(
                                                _descController.text,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize:
                                                      businessDescriptionSize,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                              isEditing
                                  ? IconButton(
                                    icon: Icon(
                                      Icons.save,
                                      color: Color(0xFF1E1E1E),
                                      size: 24,
                                    ),
                                    onPressed:
                                        () => {_toggleEdit(), _saveSettings()},
                                  )
                                  : IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Color(0xFF1E1E1E),
                                      size: 24,
                                    ),
                                    onPressed: () => _toggleEdit(),
                                  ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Items',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: itemTitleSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Items List
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              var item = items[index];
                              return Container(
                                width: 300,
                                height: 120,
                                padding: EdgeInsets.all(20),
                                margin: EdgeInsets.only(bottom: 40),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              item['name']?.toString() ?? '',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: itemTitleSize,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            child: Text(
                                              item['description']?.toString() ??
                                                  '',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: itemDescriptionSize,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xFF1E1E1E),
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            // Handle item edit
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add Item Button
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder:
                                (context) => Container(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    left: 40,
                                    right: 40,
                                    bottom: 20,
                                  ),
                                  height: 350,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF49454F),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 4,
                                        margin: EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Add Item',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: itemTitleSize,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFD9D9D9),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SizedBox(
                                              height: 60,
                                              child: TextField(
                                                controller: _itemController,
                                                decoration: InputDecoration(
                                                  labelText: 'Name',
                                                  filled: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            flex: 1,
                                            child: SizedBox(
                                              height: 60,
                                              child: TextField(
                                                controller:
                                                    _itemPriceController,
                                                keyboardType:
                                                    TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(
                                                    RegExp(r'[0-9.]'),
                                                  ),
                                                ],
                                                decoration: InputDecoration(
                                                  labelText: 'Price',
                                                  filled: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        height: 120,
                                        child: TextField(
                                          controller: _itemDescController,
                                          maxLines: 2,

                                          decoration: InputDecoration(
                                            labelText: 'Description',
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      SizedBox(
                                        height: 56,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFD9D9D9),
                                            foregroundColor: Colors.black,
                                          ),
                                          onPressed: () {
                                            _addItem();
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Done',
                                            style: TextStyle(
                                              fontSize: itemTitleSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },

                        child: Icon(
                          Icons.add_circle_rounded,
                          size: 100,
                          color: const Color(0xFFB388EB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
