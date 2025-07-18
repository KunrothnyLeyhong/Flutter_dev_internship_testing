import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'provider/product_provider.dart';
import 'screens/splash_screen.dart';

String _detectBaseUrl() {
  // Adjust for your testing environment
  if (kIsWeb) return 'http://localhost:3000';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // Android emulator
  return 'http://localhost:3000'; // iOS sim & desktop
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final baseUrl = _detectBaseUrl();
  runApp(MyApp(baseUrl: baseUrl));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.baseUrl});
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(baseUrl: baseUrl),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Product CRUD',
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
