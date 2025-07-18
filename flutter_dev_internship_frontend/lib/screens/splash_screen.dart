import 'package:flutter/material.dart';
import '../theme.dart';
import 'product_list.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProductListScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.cream.withOpacity(.6),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'An Evolving\ncollection of treatments',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Skincare Shop is born to disallow commodity to be disguised as ingenuity.".',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 48),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.sage,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const ProductListScreen()),
                  );
                },
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
