import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addProduct() async {
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController productCostController = TextEditingController();
    final TextEditingController productDescriptionController = TextEditingController();
    final TextEditingController productImageUrlController = TextEditingController();
    final TextEditingController productStockController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: productCostController,
                  decoration: InputDecoration(labelText: 'Product Cost'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: productDescriptionController,
                  decoration: InputDecoration(labelText: 'Product Description'),
                ),
                TextField(
                  controller: productImageUrlController,
                  decoration: InputDecoration(labelText: 'Product Image URL'),
                ),
                TextField(
                  controller: productStockController,
                  decoration: InputDecoration(labelText: 'Product Stock'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () async {
                await _firestore.collection('Product').add({
                  'productName': productNameController.text,
                  'productCost': int.parse(productCostController.text),
                  'productDescription': productDescriptionController.text,
                  'productImageUrl': productImageUrlController.text,
                  'productStock': int.parse(productStockController.text),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProduct(DocumentSnapshot doc) async {
    final TextEditingController productNameController = TextEditingController(text: doc['productName']);
    final TextEditingController productCostController = TextEditingController(text: doc['productCost'].toString());
    final TextEditingController productDescriptionController = TextEditingController(text: doc['productDescription']);
    final TextEditingController productImageUrlController = TextEditingController(text: doc['productImageUrl']);
    final TextEditingController productStockController = TextEditingController(text: doc['productStock'].toString());

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: productCostController,
                  decoration: InputDecoration(labelText: 'Product Cost'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: productDescriptionController,
                  decoration: InputDecoration(labelText: 'Product Description'),
                ),
                TextField(
                  controller: productImageUrlController,
                  decoration: InputDecoration(labelText: 'Product Image URL'),
                ),
                TextField(
                  controller: productStockController,
                  decoration: InputDecoration(labelText: 'Product Stock'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () async {
                await _firestore.collection('Product').doc(doc.id).update({
                  'productName': productNameController.text,
                  'productCost': int.parse(productCostController.text),
                  'productDescription': productDescriptionController.text,
                  'productImageUrl': productImageUrlController.text,
                  'productStock': int.parse(productStockController.text),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String docId) async {
    await _firestore.collection('Product').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Manage Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addProduct,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Product').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(data['productImageUrl']),
                title: Text(data['productName']),
                subtitle: Text('Cost: ${data['productCost']}, Stock: ${data['productStock']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editProduct(document),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteProduct(document.id),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        int newStock = data['productStock'] + 1;
                        _firestore.collection('Product').doc(document.id).update({
                          'productStock': newStock,
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          // Implement any additional save functionality if needed
        },
      ),
    );
  }
}
