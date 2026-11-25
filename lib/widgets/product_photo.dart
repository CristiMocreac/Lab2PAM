import 'package:flutter/material.dart';

/// High-resolution product photographs bundled for offline use.
class ProductPhoto extends StatelessWidget {
  final int image;
  const ProductPhoto(this.image, {super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: ColoredBox(
      color: const Color(0xFFF3F1EF),
      child: Image.asset(
        'assets/images/products/product-${image.clamp(0, 5)}.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder:
            (context, error, stack) => const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 42),
            ),
      ),
    ),
  );
}
