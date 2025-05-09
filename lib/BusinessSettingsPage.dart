/*
import 'package:flutter/material.dart';

class BusinessSettingsPage extends StatefulWidget {
  @override
  _BusinessSettingsPageState createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _itemController = TextEditingController();


  List<String> items = [];
  bool isEditing = false; // starts as false (view-only)
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    //User? user = null;
    if (user != null) {
      //final doc = await _firestore.collection('businesses').doc(user.uid).get();
      /*
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _descController.text = data['description'] ?? '';
        items = List<String>.from(data['items'] ?? []);
      }
      */
    }
    setState(() => isLoading = false);
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
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('businesses').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'items': items,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Business details saved.')),
        );
      }

      setState(() => isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Business Settings')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Business Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
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
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Business Name'),
                readOnly: !isEditing,
                validator: (value) => value!.isEmpty ? 'Enter a business name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                readOnly: !isEditing,
                validator: (value) => value!.isEmpty ? 'Enter a description' : null,
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
                  trailing: isEditing
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
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addItem,
                    ),
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

*/