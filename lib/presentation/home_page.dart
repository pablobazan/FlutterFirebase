import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/presentation/products_page/add_product.dart';
import 'package:flutter_firebase/presentation/products_page/product_list.dart';
import 'package:flutter_firebase/presentation/products_page/product_list_realtime.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      /**
     * Send email verification
     */
      FirebaseAuth.instance.currentUser?.sendEmailVerification();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Firebase'),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout_outlined))
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
                text: 'Product List',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProductListPage()),
                  );
                }),
            MenuButton(
                text: 'Product List Realtime',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProductListRealtime()),
                  );
                }),
            MenuButton(
                text: 'Add Product',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProductPage()),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 40,
        width: 200,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Text(text),
        ),
      ),
    );
  }
}
