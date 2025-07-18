import 'package:flutter/material.dart';
import '../theme.dart';

typedef ProductSubmit = Future<bool> Function({
required String name,
required double price,
required int stock,
String? type,
});

class ProductFormSheet extends StatefulWidget {
  const ProductFormSheet({
    super.key,
    required this.title,
    required this.initialName,
    required this.initialPrice,
    required this.initialStock,
    this.initialType,
    required this.onSubmit,
  });

  final String title;
  final String initialName;
  final double initialPrice;
  final int initialStock;
  final String? initialType;
  final ProductSubmit onSubmit;

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late String _priceStr;
  late String _stockStr;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _priceStr = widget.initialPrice == 0 ? '' : widget.initialPrice.toString();
    _stockStr = widget.initialStock == 0 ? '' : widget.initialStock.toString();
    _type = widget.initialType ?? 'Default';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.textLight.withOpacity(.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildText(
                        label: 'Product Name',
                        initial: _name,
                        onSaved: (v) => _name = v!.trim(),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildText(
                        label: 'Product Price',
                        initial: _priceStr,
                        keyboard: const TextInputType.numberWithOptions(decimal: true),
                        onSaved: (v) => _priceStr = v!.trim(),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = double.tryParse(v);
                          if (n == null || n <= 0) return 'Must be > 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildText(
                        label: 'Product Stock',
                        initial: _stockStr,
                        keyboard: TextInputType.number,
                        onSaved: (v) => _stockStr = v!.trim(),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = int.tryParse(v);
                          if (n == null || n < 0) return 'Must be ≥ 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.sage,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _submit,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText({
    required String label,
    required String initial,
    TextInputType? keyboard,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      initialValue: initial,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final price = double.parse(_priceStr);
    final stock = int.parse(_stockStr);

    setState(() => _isSubmitting = true);
    final ok = await widget.onSubmit(
      name: _name,
      price: price,
      stock: stock,
      type: _type,
    );
    setState(() => _isSubmitting = false);

    if (ok && mounted) Navigator.pop(context, true);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed')),
      );
    }
  }
}
