class Product {
  final String userId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
  }
}
