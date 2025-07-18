import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({required this.baseUrl});

  final String baseUrl;

  /// All products loaded from backend
  List<Product> _all = [];

  /// Filtered (search) + possibly sorted
  List<Product> _visible = [];
  List<Product> get products => _visible;

  bool isLoading = false;
  String? errorMessage;

  // --- FETCH ---
  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resp = await http.get(Uri.parse('$baseUrl/products'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        _all = data.map((e) => Product.fromJson(e)).toList();
        _visible = List.of(_all);
        // _currentPage = 1;
      } else {
        errorMessage = 'Failed: ${resp.statusCode}';
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // --- SEARCH ---
  void applySearch(String query) {
    if (query.trim().isEmpty) {
      _visible = List.of(_all);
    } else {
      final q = query.trim().toLowerCase();
      _visible = _all
          .where((p) => p.productName.toLowerCase().contains(q))
          .toList();
    }
    // _currentPage = 1;
    notifyListeners();
  }

  // --- SORT ---
  void sortByPrice({bool ascending = true}) {
    _visible.sort((a, b) =>
    ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    // _currentPage = 1;
    notifyListeners();
  }

  void sortByStock({bool ascending = true}) {
    _visible.sort((a, b) =>
    ascending ? a.stock.compareTo(b.stock) : b.stock.compareTo(a.stock));
    // _currentPage = 1;
    notifyListeners();
  }

  // --- ADD ---
  Future<bool> addProduct({
    required String name,
    required double price,
    required int stock,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'PRODUCTNAME': name,
          'PRICE': price,
          'STOCK': stock,
        }),
      );
      if (resp.statusCode == 201) {
        await fetchProducts();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // --- UPDATE ---
  Future<bool> updateProduct(Product product) async {
    try {
      final resp = await http.put(
        Uri.parse('$baseUrl/products?id=${product.productId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (resp.statusCode == 200) {
        await fetchProducts();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // --- DELETE ---
  Future<bool> deleteProduct(int id) async {
    try {
      final resp =
      await http.delete(Uri.parse('$baseUrl/products?id=$id'));
      if (resp.statusCode == 200) {
        _all.removeWhere((p) => p.productId == id);
        _visible.removeWhere((p) => p.productId == id);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
