import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'RegisterPage.dart';
import 'account_page.dart';
import 'cart_page.dart';
import 'checkout_page.dart';
import 'login_page.dart';
import 'order_page.dart';
import 'add_product_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(JoyBuyApp());
}

class JoyBuyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JoyBuy',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/account': (context) => AccountPage(),
        '/cart': (context) => CartPage(),
        '/checkout': (context) => CheckoutPage(),
        '/orders': (context) => OrderPage(),
        '/add-product': (context) => AddProductPage(),
      },
    );
  }
}
