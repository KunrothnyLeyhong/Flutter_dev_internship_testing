import 'package:flutter/material.dart';
import '../util/debouncer.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    required this.onFilterPressed,
    this.hintText = 'Search products',
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed;
  final String hintText;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 350);

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: (text) {
              _debouncer.run(() => widget.onChanged(text));
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Filter Button
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: widget.onFilterPressed,
          tooltip: 'Filters',
        ),
      ],
    );
  }
}
