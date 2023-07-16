import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/domain/entities/product.dart';
import 'package:flutter_firebase/firebase/firebase_entities.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: FutureBuilder(
          future: getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final products = snapshot.data!.docs;
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(products[index].data().name),
                    subtitle: Text(products[index].data().description),
                    trailing: Text('\$${products[index].data().price}'),
                    onLongPress: () {
                      deleteProduct(products[index].id);
                    },
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error'),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<QuerySnapshot<Product>> getProducts() async {
    final productCollectionRef = FirebaseFirestore.instance
        .collection(FirebaseCollections.products)
        .withConverter<Product>(
          fromFirestore: (snapshots, _) => Product.fromJson(snapshots.data()!),
          toFirestore: (product, _) => product.toJson(),
        );

    final query = productCollectionRef.where('userId',
        isEqualTo: FirebaseAuth.instance.currentUser!.uid);

    final products = await query.get();
    return products;
  }

  void deleteProduct(String productId) {
    final productCollectionRef = FirebaseFirestore.instance
        .collection(FirebaseCollections.products)
        .withConverter<Product>(
          fromFirestore: (snapshots, _) => Product.fromJson(snapshots.data()!),
          toFirestore: (product, _) => product.toJson(),
        );

    setState(() {
      productCollectionRef.doc(productId).delete();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Product deleted successfully'),
            duration: Duration(seconds: 3)),
      );
    }
  }
}
