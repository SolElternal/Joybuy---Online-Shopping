import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'cart_page.dart';
import 'account_page.dart';
import 'add_product_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalCost = 0;

  @override
  void initState() {
    super.initState();
    _updateTotalCost();
  }

  void _updateTotalCost() async {
    final cartSnapshot = await FirebaseFirestore.instance.collection('Cart').get();
    double newTotalCost = 0;

    for (var doc in cartSnapshot.docs) {
      double productCost = doc['productCost'].toDouble();
      int quantity = doc['quantity'];
      newTotalCost += productCost * quantity;
    }

    setState(() {
      totalCost = newTotalCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'JoyBuy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.orange.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Cost:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '${totalCost.toStringAsFixed(2)} THB',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: ProductList(onProductAdded: _updateTotalCost)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/cart');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/account');
          }
        },
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final VoidCallback onProductAdded;

  ProductList({required this.onProductAdded});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Product').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                title: Text(
                  doc['productName'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${doc['productCost']} THB',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepOrange,
                  ),
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    doc['productImageUrl'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: doc),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('Cart').add({
                      'productID': doc.id,
                      'productName': doc['productName'],
                      'productCost': doc['productCost'],
                      'quantity': 1,
                    });
                    onProductAdded();
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}


class ProductDetailPage extends StatelessWidget {
  final DocumentSnapshot product;

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['productName']),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for image and product details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    child: AspectRatio(
                      aspectRatio: 1, // Aspect ratio of the image (1:1 here for square images)
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product['productImageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['productName'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${product['productCost']} THB',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Product description
              Text(
                product['productDescription'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 16),
              // Add to Cart button
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('Cart').add({
                      'productID': product.id,
                      'productName': product['productName'],
                      'productCost': product['productCost'],
                      'quantity': 1,
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

