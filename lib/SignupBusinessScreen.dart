import 'package:cityprint/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupBusinessScreen extends StatefulWidget {
  const SignupBusinessScreen({Key? key}) : super(key: key);

  @override
  State<SignupBusinessScreen> createState() => _SignupBusinessScreenState();
}

class _SignupBusinessScreenState extends State<SignupBusinessScreen> {
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _DescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final businessName = _businessNameController.text.trim();
    final itemName = _itemNameController.text.trim();
    final itemPrice = _itemPriceController.text.trim();
    final itemDescription = _itemDescriptionController.text.trim();

    try {
      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Check if user already has a store
      

      // Insert business data into the database
      final businessResponse =
          await Supabase.instance.client.from('business').insert({
            'business_id': user.id,
            'name': businessName,
            'user_id': user.id,
            'description': _DescriptionController.text.trim(),
          }).select();

      if (businessResponse == null || businessResponse.isEmpty) {
        throw Exception('Failed to create business profile');
      }

      final businessId = businessResponse[0]['business_id'];

      // Insert item data directly linked to business
      await Supabase.instance.client.from('item').insert({
        'item_id': user.id,
        'name': itemName,
        'price': double.parse(itemPrice),
        'business_id': businessId,
        'description': itemDescription,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business registration successful!')),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/business',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print(e);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: ${e.toString()}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Business Sign Up'),
        backgroundColor: const Color(0xFFB388EB),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Colors.white,
                  width: 320,
                  height: 55,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 40),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Store Name',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: TextFormField(
                                controller: _businessNameController,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  hintText: 'Input Store Name',
                                  hintStyle: TextStyle(fontSize: 12),
                                  isDense: true,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                validator:
                                    (value) =>
                                        value?.isEmpty ?? true
                                            ? 'Please enter store name'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  width: 320,
                  height: 125,
                  padding: EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 40),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 90,
                              child: TextFormField(
                                controller: _DescriptionController,
                                maxLines: 4,
                                maxLength: 50,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  hintText: 'Input Description',
                                  hintStyle: TextStyle(fontSize: 12),
                                  isDense: true,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                validator:
                                    (value) =>
                                        value?.isEmpty ?? true
                                            ? 'Please enter description'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.white,
                      width: 205,
                      height: 55,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store_outlined, size: 40),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Item Name',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: TextFormField(
                                    controller: _itemNameController,
                                    cursorColor: Colors.grey,
                                    decoration: InputDecoration(
                                      hintText: 'Input Item Name',
                                      hintStyle: TextStyle(fontSize: 12),
                                      isDense: true,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    validator:
                                        (value) =>
                                            value?.isEmpty ?? true
                                                ? 'Please enter item name'
                                                : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      color: Colors.white,
                      width: 105,
                      height: 55,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  width: 50,
                                  child: TextFormField(
                                    controller: _itemPriceController,
                                    cursorColor: Colors.grey,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Input Item Price',
                                      hintStyle: TextStyle(fontSize: 12),
                                      isDense: true,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true)
                                        return 'Please enter price';
                                      if (double.tryParse(value!) == null)
                                        return 'Please enter a valid number';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  width: 320,
                  height: 125,
                  padding: EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 40),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item Description',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 90,
                              child: TextFormField(
                                controller: _itemDescriptionController,
                                maxLines: 4,
                                maxLength: 50,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  hintText: 'Input Item Description',
                                  hintStyle: TextStyle(fontSize: 12),
                                  isDense: true,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                validator:
                                    (value) =>
                                        value?.isEmpty ?? true
                                            ? 'Please enter item description'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                SizedBox(
                  height: 40,
                  width: 320,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Create Store',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB388EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
