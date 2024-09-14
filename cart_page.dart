import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalCost = 0.0;
  List<String> selectedItems = [];

  void _updateTotalCost() async {
    double newTotalCost = 0.0;
    var snapshot = await FirebaseFirestore.instance.collection('Cart').get();
    for (var doc in snapshot.docs) {
      if (selectedItems.contains(doc.id)) {
        int productCost = doc['productCost'].toInt();
        int quantity = doc['quantity'];
        newTotalCost += productCost * quantity;
      }
    }
    setState(() {
      totalCost = newTotalCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          // พื้นหลังตกแต่ง
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200]!, Colors.orange[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 50,
            child: Icon(Icons.shopping_cart, size: 150, color: Colors.white.withOpacity(0.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Cart').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());

                      List<Widget> cartItems = snapshot.data!.docs.map((doc) {
                        int productCost = doc['productCost'].toInt();
                        int quantity = doc['quantity'];

                        return Card(
                          color: Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(doc['productName']),
                            subtitle: Text('${productCost.toStringAsFixed(2)} THB x $quantity'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () async {
                                    if (quantity > 1) {
                                      await FirebaseFirestore.instance
                                          .collection('Cart')
                                          .doc(doc.id)
                                          .update({
                                        'quantity': quantity - 1,
                                      });
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('Cart')
                                          .doc(doc.id)
                                          .delete();
                                    }
                                    _updateTotalCost();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Cart')
                                        .doc(doc.id)
                                        .update({
                                      'quantity': quantity + 1,
                                    });
                                    _updateTotalCost();
                                  },
                                ),
                                Checkbox(
                                  value: selectedItems.contains(doc.id),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedItems.add(doc.id);
                                      } else {
                                        selectedItems.remove(doc.id);
                                      }
                                      _updateTotalCost();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList();

                      return ListView(children: cartItems);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Cost: ${totalCost.toStringAsFixed(2)} THB',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedItems.isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              '/checkout',
                              arguments: {
                                'totalCost': totalCost,
                                'selectedItems': await _getSelectedItemsDetails(),
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Checkout', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getSelectedItemsDetails() async {
    List<Map<String, dynamic>> items = [];
    var snapshot = await FirebaseFirestore.instance.collection('Cart').get();
    for (var doc in snapshot.docs) {
      if (selectedItems.contains(doc.id)) {
        items.add({
          'productName': doc['productName'],
          'productCost': doc['productCost'],
          'quantity': doc['quantity'],
        });
      }
    }
    return items;
  }
}
