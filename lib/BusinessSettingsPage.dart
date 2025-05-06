import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'user_service.dart';

class BusinessSettingsPage extends StatefulWidget {
  @override
  _BusinessSettingsPageState createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _itemController = TextEditingController();

  String? businessName;

  List<String> items = [];
  bool isEditing = false; // starts as false (view-only)
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    UserService.getBusinessName().then((name) {
      setState(() {
        businessName = name ?? 'No Business Name';
      });
    });
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _addItem() {
    final newItem = _itemController.text.trim();
    if (newItem.isNotEmpty) {
      setState(() {
        items.add(newItem);
        _itemController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business details saved locally.')),
      );

      setState(() => isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Settings'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveSettings();
              } else {
                _toggleEdit();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                child: Column(children: [Text('Business Name'), Text('$businessName')]),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Business Name'),
                readOnly: !isEditing,
                validator:
                    (value) => value!.isEmpty ? 'Enter a business name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                readOnly: !isEditing,
                validator:
                    (value) => value!.isEmpty ? 'Enter a description' : null,
              ),
              SizedBox(height: 24),
              Text(
                'Items Offered',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...items.asMap().entries.map((entry) {
                int index = entry.key;
                String item = entry.value;
                return ListTile(
                  title: Text(item),
                  trailing:
                      isEditing
                          ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          )
                          : null,
                );
              }),
              if (isEditing)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        decoration: InputDecoration(hintText: 'New Item'),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.add), onPressed: _addItem),
                  ],
                ),
              SizedBox(height: 24),
              if (isEditing)
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: Text('Save All Changes'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
