import 'package:flutter/material.dart';
import 'add_transaction.dart';
import '../widgets/navigation_bar.dart';
import 'home_screen.dart';
import 'stats.dart';
import 'profile.dart';
import '../widgets/categories.dart';
import '../models/user_data.dart';
import 'history.dart';

class CategoryGridWidget extends StatelessWidget {
  final void Function(CategoryItem) onSelected;

  const CategoryGridWidget({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final categories = categoriesGlobal;

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 0,
      ),
      itemBuilder: (_, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => onSelected(category),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    category.assetPath,
                    fit: BoxFit.contain,
                    height: 60,
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }
}

class GalleryScreen extends StatefulWidget {
  final UserData userData;

  const GalleryScreen({super.key, required this.userData});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selectedIndex = 3;

  void _onNavIndexChanged(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomeScreen(userData: widget.userData);
        break;
      case 1:
        nextPage = StatsScreen(userData: widget.userData);
        break;
      case 2:
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
      case 3:
        nextPage = GalleryScreen(userData: widget.userData);
        break;
      case 4:
        nextPage = ProfileScreen(userData: widget.userData);
        break;
      default:
        nextPage = HomeScreen(userData: widget.userData);
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

  @override
  Widget build(BuildContext context) {
    final formattedName = widget.userData.username.isNotEmpty
        ? widget.userData.username[0].toUpperCase() +
            widget.userData.username.substring(1).toLowerCase()
        : "Guest";

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBarWidget(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavIndexChanged,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "All Categories",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CategoryGridWidget(
                onSelected: (category) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    builder: (_) => CategoryTransactionsSheet(
                      categoryName: category.name,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}