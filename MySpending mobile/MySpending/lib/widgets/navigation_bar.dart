import 'package:flutter/material.dart';

class NavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const NavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });


  final List<Map<String, dynamic>> icons = const [
    {"path": "assets/home.png", "w": 45.0, "h": 45.0},      
    {"path": "assets/stats.png", "w": 35.0, "h": 35.0},     
    {"path": "assets/add.png", "w": 70.0, "h": 70.0},       
    {"path": "assets/gallery.png", "w": 40.0, "h": 40.0},   
    {"path": "assets/profile.png", "w": 40.0, "h": 40.0},   
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 105,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final bool isActive = selectedIndex == index;
          final bool isCenter = index == 2;

          return GestureDetector(
            onTap: () => onIndexChanged(index),
            child: SizedBox(
              width: 55,
              height: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCenter
                          ? const Color(0xFFbdd2df) 
                          : Colors.transparent,
                      boxShadow: isCenter
                          ? [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Image.asset(
                        icons[index]["path"],
                        width: icons[index]["w"],
                        height: icons[index]["h"],
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  
                  if (isActive && !isCenter)
                    Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
