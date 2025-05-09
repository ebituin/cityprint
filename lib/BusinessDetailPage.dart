import 'package:flutter/material.dart';

class BusinessDetailPage extends StatefulWidget {
  final Map<String, dynamic> business;

  const BusinessDetailPage({Key? key, required this.business})
    : super(key: key);

  @override
  _BusinessDetailPageState createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    final items = widget.business['item'] ?? [];
    for (var item in items) {
      _quantities[item['name']] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.business['item'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.business['name'] ?? 'Business Details'),
        backgroundColor: const Color(0xFFB388EB),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.business['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text('\$${item['price']}'),
                    trailing: Container(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
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
                          Text('${_quantities[item['name']]}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _quantities[item['name']] =
                                    (_quantities[item['name']] ?? 0) + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement order submission
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed successfully!')),
                );
              },
              child: Text('Place Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB388EB),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
