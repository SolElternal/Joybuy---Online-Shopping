import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Order')
            .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final orderID = data['orderID'] ?? 'Unknown';
              final totalCost = (data['totalCost'] ?? 0.0).toDouble();
              final orderDate = (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
              final firstname = data['firstname'] ?? '';
              final lastname = data['lastname'] ?? '';

              return ListTile(
                title: Text('Order ID: $orderID'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Cost: ${totalCost.toStringAsFixed(2)} THB'),
                    Text('Order Date: ${orderDate.toLocal().toString()}'),
                    Text('Name: $firstname $lastname'),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
