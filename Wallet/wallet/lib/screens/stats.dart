import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import 'home_screen.dart';
import 'gallery.dart';
import 'profile.dart';
import 'add_transaction.dart';
import '../models/user_data.dart';
import '../models/transaction_data.dart';
import '../widgets/categories.dart';

class StatsScreen extends StatefulWidget {
  final UserData userData;

  const StatsScreen({super.key, required this.userData});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<double> weeklyData = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    weeklyData = buildWeeklyData();
  }

  List<double> buildWeeklyData() {
    List<double> data = List.filled(7, 0);

    for (var tx in transactionList) {
      DateTime date = DateTime.parse(tx.date);
      int weekday = date.weekday; // 1 = Monday ... 7 = Sunday

      if (tx.category.toLowerCase() != "salary") {
        data[weekday - 1] += tx.amount.abs();
      }
    }

    return data;
  }

  // ----------------------------- НАВІГАЦІЯ -----------------------------
  void _onNavIndexChanged(int index) {
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
            setState(() {
              weeklyData = buildWeeklyData(); // Оновити графік
            });
          },
        ),
      );
      return;
    }

    if (index == 1) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomeScreen(userData: widget.userData);
        break;
      case 3:
        nextPage = GalleryScreen(userData: widget.userData);
        break;
      case 4:
        nextPage = ProfileScreen(userData: widget.userData);
        break;
      default:
        nextPage = StatsScreen(userData: widget.userData);
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextPage,
        transitionDuration: Duration.zero,
      ),
    );
  }

  

  String getCategoryIcon(String categoryName) {
    try {
      final category = categoriesGlobal.firstWhere(
        (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
      );
      return category.assetPath;
    } catch (e) {
      return "assets/spending.png";
    }
  }

  String getMostExpensiveDay() {
    if (transactionList.isEmpty) return "N/A";

    Map<String, double> daySums = {};
    for (var tx in transactionList) {
      if (tx.category.toLowerCase() != 'salary') {
        daySums[tx.date] = (daySums[tx.date] ?? 0) + tx.amount.abs();
      }
    }

    if (daySums.isEmpty) return "N/A";

    final top = daySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return top.first.key;
  }

  String getFavoriteCategory() {
    if (transactionList.isEmpty) return "N/A";

    Map<String, double> sums = {};
    for (var tx in transactionList) {
      if (tx.category.toLowerCase() != 'salary') {
        sums[tx.category] = (sums[tx.category] ?? 0) + tx.amount.abs();
      }
    }

    if (sums.isEmpty) return "N/A";

    final top = sums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return top.first.key;
  }

  String getTotalSpending() {
    double total = 0;

    for (var tx in transactionList) {
      if (tx.category.toLowerCase() != 'salary') {
        total += tx.amount.abs();
      }
    }

    return "${total.toStringAsFixed(0)} \$";
  }

  String getMostProfitableMonth() {
    if (transactionList.isEmpty) return "N/A";

    Map<int, double> monthly = {};

    for (var tx in transactionList) {
      if (tx.category.toLowerCase() == 'salary') {
        final m = DateTime.parse(tx.date).month;
        monthly[m] = (monthly[m] ?? 0) + tx.amount.abs();
      }
    }

    if (monthly.isEmpty) return "N/A";

    final sorted = monthly.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    const names = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return names[sorted.first.key];
  }

  
  Widget statBlock(String title, String value, Widget icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      width: 370,
      decoration: BoxDecoration(
        color: const Color(0xFFDCEAF2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          icon
        ],
      ),
    );
  }

  // ----------------------------- UI -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBarWidget(
        selectedIndex: 1,
        onIndexChanged: _onNavIndexChanged,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),

              // ---------------- TOP BAR ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 10),
                  _smallBtn(Icons.arrow_back),
                  const Spacer(),
                  const Text("Statistics",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  _smallBtn(Icons.menu),
                  const SizedBox(width: 10),
                ],
              ),

              const SizedBox(height: 10),

              
              Container(
  width: 370,
  height: 200,
  decoration: BoxDecoration(
    color: const Color(0xFFDCEAF2),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Stack(
    children: [
      
      Center(
        child: SizedBox(
          width: 295,
          height: 95,
          child: CustomPaint(
            painter: _WeeklyGraphPainter(weeklyData),
            size: const Size(295, 95),
          ),
        ),
      ),

      
      const Positioned(
        top: 12,
        left: 12,
        child: Text(
          "5K\$",
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ),

      
      const Positioned(
        bottom: 38,
        left: 12,
        child: Text(
          "0\$",
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ),

      
      const Positioned(
        bottom: 10,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Mon"),
            Text("Tue"),
            Text("Wed"),
            Text("Thu"),
            Text("Fri"),
            Text("Sat"),
            Text("Sun"),
          ],
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 20),


              statBlock("Most expensive day", getMostExpensiveDay(),
                  Image.asset("assets/MED.png", width: 50, height: 50)),
              const SizedBox(height: 20),

              statBlock(
                "Favorite category",
                getFavoriteCategory(),
                Image.asset(getCategoryIcon(getFavoriteCategory()),
                    width: 50, height: 50),
              ),
              const SizedBox(height: 20),

              statBlock("Spending", getTotalSpending(),
                  Image.asset("assets/spending.png", width: 50, height: 50)),
              const SizedBox(height: 20),

              statBlock("Most profitable month", getMostProfitableMonth(),
                  Image.asset("assets/MPM.png", width: 50, height: 50)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 1.5, color: Colors.black),
      ),
      child: Icon(icon, size: 20),
    );
  }
}

class _WeeklyGraphPainter extends CustomPainter {
  final List<double> data;

  _WeeklyGraphPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    double maxValue = data.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 1;

    double stepX = size.width / 6;

    List<Offset> points = [];

    // 0$ = bottom
    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y = size.height - (data[i] / maxValue) * size.height;
      points.add(Offset(x, y));
    }

    // Smooth curve
    Path smooth = Path();
    smooth.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      smooth.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
    }

    smooth.lineTo(points.last.dx, points.last.dy);

    Paint linePaint = Paint()
      ..color = const Color(0xFF86BBD8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(smooth, linePaint);

    
    Path fill = Path.from(smooth);
    fill.lineTo(points.last.dx, size.height);
    fill.lineTo(points.first.dx, size.height);
    fill.close();

    Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withOpacity(0),
          Colors.blue.withOpacity(0.25),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fill, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

