import 'package:flutter/material.dart';
import '../model/product.dart';
import '../theme.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on top
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/product_placeholder.png',
              fit: BoxFit.cover,
            ),
          ),
          // Product name
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.textDark,
              ),
            ),
          ),
          // Price and stock
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Price \$${product.price.toStringAsFixed(2)} · Stock ${product.stock}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
            ),
          ),
          const Spacer(),
          // Buttons aligned right
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit, size: 20, color: AppTheme.sageDark),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
