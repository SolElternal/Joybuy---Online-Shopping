import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late double totalCost;
  List<Map<String, dynamic>> selectedItems = [];
  final _addressController = TextEditingController();
  String userName = 'Loading...';
  String userAddress = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    totalCost = args['totalCost'] as double;
    selectedItems = List<Map<String, dynamic>>.from(args['selectedItems']);
    _loadUserDetails();
  }

  void _loadUserDetails() async {
    var accountSnapshot = await FirebaseFirestore.instance
        .collection('Account')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (accountSnapshot.exists) {
      setState(() {
        userName = '${accountSnapshot['firstname']} ${accountSnapshot['lastname']}';
        userAddress = accountSnapshot['address'];
      });
      if (_addressController.text.isEmpty) {
        _addressController.text = userAddress;
      }
    }
  }

  void _placeOrder() async {
    var accountSnapshot = await FirebaseFirestore.instance
        .collection('Account')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    await FirebaseFirestore.instance.collection('Order').add({
      'orderDate': Timestamp.now(),
      'orderID': DateTime.now().millisecondsSinceEpoch,
      'totalCost': totalCost,
      'firstname': accountSnapshot['firstname'],
      'lastname': accountSnapshot['lastname'],
      'address': _addressController.text,
      'items': selectedItems,
    });

    await FirebaseFirestore.instance.collection('Cart').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Pop up แสดงรายละเอียด order
    _showOrderConfirmation();
  }

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Confirmation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: $userName'),
              Text('Address: ${_addressController.text}'),
              Text('Total Cost: ${totalCost.toStringAsFixed(2)} THB'),
              Text('Order Date: ${DateTime.now()}'),
              SizedBox(height: 16),
              Text('Items:'),
              ...selectedItems.map((item) {
                return Text('${item['productName']} x ${item['quantity']}');
              }).toList(),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.deepOrange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Text(
                  'Total Cost: ${totalCost.toStringAsFixed(2)} THB',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Shipping Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: selectedItems.map((item) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: Text('${item['productName']} x ${item['quantity']}'),
                        subtitle: Text('${item['productCost']} THB'),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange, // Background color
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Size
                    textStyle: TextStyle(
                      fontSize: 18, // Font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _placeOrder,
                  child: Text('Pay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
