import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/domain/entities/product.dart';
import 'package:flutter_firebase/firebase/firebase_entities.dart';

class ProductListRealtime extends StatelessWidget {
  const ProductListRealtime({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List Realtime'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: StreamBuilder(
          stream: getProducts(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: Text('Not connected to the internet'),
                );
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(products[index].data().name),
                      subtitle: Text(products[index].data().description),
                      trailing: Text('\$${products[index].data().price}'),
                      onLongPress: () {
                        deleteProduct(context, products[index].id);
                      },
                    );
                  },
                );
              case ConnectionState.done:
                return const SizedBox.shrink();
              default:
                return const SizedBox.shrink();
            }

            // }
            // if (snapshot.connectionState == ConnectionState.done) {
            // } else if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
            // } else if (snapshot.connectionState == ConnectionState.active) {
            //   final products = snapshot.data!.docs;
            //   return ListView.builder(
            //     itemCount: products.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text(products[index].data().name),
            //         subtitle: Text(products[index].data().description),
            //         trailing: Text('\$${products[index].data().price}'),
            //         onLongPress: () {
            //           deleteProduct(context, products[index].id);
            //         },
            //       );
            //     },
            //   );
            // }

            // if (snapshot.hasError) {
            //   return const Center(
            //     child: Text('Error'),
            //   );
            // }
            // return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Product>> getProducts() async* {
    final productCollectionRef = FirebaseFirestore.instance
        .collection(FirebaseCollections.products)
        .withConverter<Product>(
          fromFirestore: (snapshots, _) => Product.fromJson(snapshots.data()!),
          toFirestore: (product, _) => product.toJson(),
        );

    yield* productCollectionRef
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  void deleteProduct(BuildContext context, String productId) {
    FirebaseFirestore.instance
        .collection(FirebaseCollections.products)
        .withConverter<Product>(
          fromFirestore: (snapshots, _) => Product.fromJson(snapshots.data()!),
          toFirestore: (product, _) => product.toJson(),
        )
        .doc(productId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Product deleted successfully'),
          duration: Duration(seconds: 3)),
    );
  }
}
