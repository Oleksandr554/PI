import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import 'home_screen.dart';
import 'gallery.dart';
import 'stats.dart';
import '../models/user_data.dart';
import 'dart:io';
import 'add_transaction.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  final UserData userData;

  const ProfileScreen({super.key, required this.userData});

  void _onNavIndexChanged(BuildContext context, int index) {
    if (index == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (_) => AddTransactionSheet(
          onTransactionAdded: () {
            (context as Element).markNeedsBuild();
          },
        ),
      );
      return;
    }
    if (index == 4) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomeScreen(userData: userData);
        break;
      case 1:
        nextPage = StatsScreen(userData: userData);
        break;
      case 3:
        nextPage = GalleryScreen(userData: userData);
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    final nextPage = HomeScreen(userData: userData);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildProfileCTA(
    BuildContext context,
    String assetPath,
    String title,
    VoidCallback? onTap, {
    bool isLogout = false,
  }) {
    const Color boxColor = Color(0xFFDCEAF2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(width: 1.5, color: Colors.black),
              ),
              child: Image.asset(
                'assets/$assetPath',
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(width: 1.5, color: Colors.black),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double screenWidth = 393;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBarWidget(
        selectedIndex: 4,
        onIndexChanged: (index) => _onNavIndexChanged(context, index),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: 270 + MediaQuery.of(context).padding.top,
              decoration: const BoxDecoration(
                color: Color(0xFFDCEAF2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(width: 1.5, color: Colors.black),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(userData: userData),
                            ),
                          );

                          if (updated == true) {
                            (context as Element).markNeedsBuild();
                          }
                        },
                        child: const Icon(Icons.edit_outlined, size: 20),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black26),
                          ],
                        ),
                        child: ClipOval(
                          child: userData.imagePath != null
                              ? Image.file(File(userData.imagePath!), fit: BoxFit.cover)
                              : const Icon(Icons.person, size: 60, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userData.username,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData.email,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF5B5B5B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: screenWidth,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFDCEAF2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _buildProfileCTA(context, 'support.png', 'Support', () => _navigateToHome(context)),
                  const SizedBox(height: 10),
                  Container(width: 364, height: 2, color: const Color(0xFFBDD2E0)),
                  const SizedBox(height: 50),
                  _buildProfileCTA(context, 'faq.png', 'FAQs', () => _navigateToHome(context)),
                  const SizedBox(height: 10),
                  Container(width: 364, height: 2, color: const Color(0xFFBDD2E0)),
                  const SizedBox(height: 50),
                  _buildProfileCTA(context, 'settings.png', 'Settings', () => _navigateToHome(context)),
                  const SizedBox(height: 10),
                  Container(width: 364, height: 2, color: const Color(0xFFBDD2E0)),
                  const SizedBox(height: 50),
                  _buildProfileCTA(context, 'logout.png', 'Log out', () => _navigateToHome(context)),
                  const SizedBox(height: 10),
                  Container(width: 364, height: 2, color: const Color(0xFFBDD2E0)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}