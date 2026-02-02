import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
void main() => runApp(const WalletApp());


class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}