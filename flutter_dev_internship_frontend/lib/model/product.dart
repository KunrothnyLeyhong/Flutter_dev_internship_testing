class Product {
  final int productId;
  final String productName;
  final double price;
  final int stock;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json['PRODUCTID'],
    productName: json['PRODUCTNAME'],
    price: (json['PRICE'] as num).toDouble(),
    stock: json['STOCK'],
  );

  Map<String, dynamic> toJson() => {
    'PRODUCTNAME': productName,
    'PRICE': price,
    'STOCK': stock,
  };

  Product copyWith({
    int? productId,
    String? productName,
    double? price,
    int? stock,
  }) =>
      Product(
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        price: price ?? this.price,
        stock: stock ?? this.stock,
      );
}
