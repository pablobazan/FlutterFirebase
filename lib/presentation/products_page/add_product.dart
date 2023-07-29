import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/domain/entities/product.dart';
import 'package:flutter_firebase/firebase/firebase_entities.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _isLoading = false;
  String? imagePath;
  String? imageUrl;

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
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: Padding(
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
                  const SizedBox(
                    height: 16.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      label: const Text('Add image'),
                      icon: const Icon(Icons.image),
                      onPressed: () {
                        takePicture();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 48.0,
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
          ),
          Visibility(
            visible: _isLoading,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: const SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> takePicture() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 480,
        maxHeight: 320);
    if (image != null) {
      imagePath = image.path;
    }
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
    if (name.isEmpty || description.isEmpty || price.isEmpty) {
      return;
    }
    setIsLoading(true);

    await uploadImage();
    final productData = Product(
      userId: FirebaseAuth.instance.currentUser!.uid,
      name: name,
      description: description,
      price: double.tryParse(price) ?? 0.0,
      imageUrl: imageUrl ?? '',
    );
    final result = await productCollectionRef.add(productData);
    if (result.id.isNotEmpty) {
      _descriptionProductController.clear();
      _nameProductController.clear();
      _priceProductController.clear();
      _imageUrlProductController.clear();

      setIsLoading(false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Product added'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> uploadImage() async {
    if (imagePath == null) return;

    final imagesStorageRef = FirebaseStorage.instance.ref().child('images');
    final uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadTask = await imagesStorageRef
        .child(uniqueName)
        .putFile(File(imagePath!), SettableMetadata(contentType: 'image/jpeg'));
    imageUrl = await uploadTask.ref.getDownloadURL();
  }

  void setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }
}
