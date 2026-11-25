import 'dart:convert';
import 'package:flutter/services.dart';

class Product {
  final String id, name, category, description;
  final double price;
  final int image;
  final List<String> sizes, colors;
  Product.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      category = j['category'] as String,
      description = j['description'] as String,
      price = (j['price'] as num).toDouble(),
      image = j['image'] as int,
      sizes = List<String>.unmodifiable(j['sizes'] as List),
      colors = List<String>.unmodifiable(j['colors'] as List);
}

class ProductRepository {
  Future<List<Product>> load() async {
    final json =
        jsonDecode(await rootBundle.loadString('assets/data/products.json'))
            as Map<String, dynamic>;
    return List.unmodifiable(
      (json['products'] as List).map(
        (p) => Product.fromJson(p as Map<String, dynamic>),
      ),
    );
  }
}
