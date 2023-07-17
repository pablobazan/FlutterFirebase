import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/domain/entities/product.dart';
import 'package:flutter_firebase/firebase/firebase_entities.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  late TextEditingController _nameProductController;
  late TextEditingController _descriptionProductController;
  late TextEditingController _priceProductController;
  late TextEditingController _imageUrlProductController;
  final productCollectionRef = FirebaseFirestore.instance
      .collection(FirebaseCollections.products)
      .withConverter<Product>(
        fromFirestore: (snapshots, _) => Product.fromJson(snapshots.data()!),
        toFirestore: (product, _) => product.toJson(),
      );

  @override
  void initState() {
    _nameProductController = TextEditingController();
    _descriptionProductController = TextEditingController();
    _priceProductController = TextEditingController();
    _imageUrlProductController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameProductController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextFormField(
              controller: _descriptionProductController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextFormField(
              controller: _priceProductController,
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
            ),
            TextFormField(
              controller: _imageUrlProductController,
              decoration: const InputDecoration(
                labelText: 'Image Url',
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  addProduct(
                      name: _nameProductController.text,
                      description: _descriptionProductController.text,
                      price: _priceProductController.text);
                },
                child: const Text('Add product'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  addRandomProduct();
                },
                child: const Text('Add random product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addRandomProduct() {
    addProduct(
        name: 'Product ${Random().nextInt(100)}',
        description: 'Description ${Random().nextInt(100)}',
        price: (Random().nextDouble() * 100).toStringAsFixed(2));
  }

  void addProduct(
      {required String name,
      required String description,
      required String price}) async {
    final productData = Product(
      userId: FirebaseAuth.instance.currentUser!.uid,
      name: name,
      description: description,
      price: double.parse(price),
      imageUrl: _imageUrlProductController.text,
    );
    final result = await productCollectionRef.add(productData);
    if (result.id.isNotEmpty) {
      _descriptionProductController.clear();
      _nameProductController.clear();
      _priceProductController.clear();
      _imageUrlProductController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Product added'),
        duration: Duration(seconds: 1),
      ));
    }
  }
}
