import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';
import 'create_acc.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _moveLogoUp = false;
  double _contentOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _moveLogoUp = true;
      });

      Timer(const Duration(milliseconds: 600), () {
        setState(() {
          _contentOpacity = 1.0;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width - 40;

    const Color buttonColor = Color(0xFFDCEAF2);
    const Color backgroundColor = Color(0xFFbdd2df);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            alignment: _moveLogoUp ? const Alignment(0, -0.5) : Alignment.center,
            child: Image.asset(
              'assets/logo.png',
              width: 250,
              height: 250,
            ),
          ),

          AnimatedOpacity(
            opacity: _contentOpacity,
            duration: const Duration(milliseconds: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 300),

                const Text(
                  'Welcome to MySpending',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Phasellus lorem arcu, hendrerit ac orci ac,dignissim tristique ante',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF5B5B5B),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 44),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: buttonWidth,
                    height: 60,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF5A7A8C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: buttonWidth,
                    height: 60,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}