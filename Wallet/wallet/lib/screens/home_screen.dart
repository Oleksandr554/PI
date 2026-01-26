import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import 'add_transaction.dart';
import 'gallery.dart';
import 'stats.dart';
import 'profile.dart';
import '../models/user_data.dart';
import '../models/transaction_data.dart';

class HomeScreen extends StatefulWidget {
  final UserData userData;
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedChipIndex = 0;
  final List<String> _chipLabels = ["All", "Day", "Week", "Month"];  
  
  List<Transaction> getFilteredTransactions() {
    final now = DateTime.now();

    return transactionList.where((tx) {
      final txDate = DateTime.parse(tx.date);

      switch (_selectedChipIndex) {
        case 0:
          return true;
        case 1:
          return txDate.year == now.year &&
                 txDate.month == now.month &&
                 txDate.day == now.day;
        case 2:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          return txDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                 txDate.isBefore(weekEnd.add(const Duration(days: 1)));
        case 3:
          return txDate.year == now.year &&
                 txDate.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

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
            setState(() {});
          },
        ),
      );
      return;
    }

    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomeScreen(userData: widget.userData);
        break;
      case 1:
        nextPage = StatsScreen(userData: widget.userData);
        break;
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
        pageBuilder: (context, a, b) => nextPage,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildStatBox({required String title, required double amount, required Color color, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              "\$ ${amount.toStringAsFixed(0)}", 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChipFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: List.generate(_chipLabels.length, (idx) {
            final isActive = _selectedChipIndex == idx;

            return GestureDetector(
              onTap: () => setState(() => _selectedChipIndex = idx),
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isActive ? const Color(0xFFbdd2df) : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _chipLabels[idx],
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final formattedName = widget.userData.username.isNotEmpty
        ? widget.userData.username[0].toUpperCase() + widget.userData.username.substring(1).toLowerCase()
        : "Guest";

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Hello,\n$formattedName",
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, height: 1.1),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: const Icon(Icons.search, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    double income = 0;
    double spent = 0;

    for (var tx in transactionList) {
      if (tx.category.toLowerCase() == 'salary') {
        income += tx.amount.abs();
      } else {
        spent += tx.amount.abs();
      }
    }

    final dataMap = {
      "Spent": spent,
      "Income": income,
    };

    final colorList = [
      const Color(0xFFF95C5C),
      const Color(0xFFA4D586),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: 363,
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDCEAF2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(
                    title: "Spent",
                    amount: spent,
                    color: colorList[0],
                ),
                const SizedBox(height: 20),
                _buildStatRow(
                    title: "Income",
                    amount: income,
                    color: colorList[1],
                ),
              ],
            ),
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(
                dataMap: dataMap.isEmpty && income == 0 && spent == 0
                    ? {"No Data": 1}
                    : dataMap,
                chartRadius: 120,
                colorList: dataMap.isEmpty && income == 0 && spent == 0
                    ? [Colors.grey.shade300]
                    : colorList,
                chartType: ChartType.ring,
                baseChartColor: Colors.transparent,
                totalValue: income + spent > 0 ? income + spent : 1,
                chartLegendSpacing: 0,
                initialAngleInDegree: -90,
                legendOptions: const LegendOptions(showLegends: false),
                chartValuesOptions: const ChartValuesOptions(
                    showChartValues: false, showChartValuesInPercentage: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({required String title, required double amount, required Color color}) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            Text("${amount.toStringAsFixed(0)} \$", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isExpense = transaction.amount < 0;
    final amountText = "${transaction.amount.abs().toStringAsFixed(0)} \$";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                transaction.assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.category_outlined),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(transaction.paymentMethod, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amountText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 2),
              Text(transaction.date, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    final filtered = getFilteredTransactions();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent transaction",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GalleryScreen(
                        userData: widget.userData, 
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFF959595),
                    ),
                  ),
                  child: const Text(
                    "See all >",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF959595),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            const Text("No transactions", style: TextStyle(color: Colors.grey, fontSize: 16)),
          Column(
            children: filtered
                .reversed
                .map((tx) => _buildTransactionItem(tx))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildChipFilterRow(),
              const SizedBox(height: 30),
              _buildSummaryCard(),
              const SizedBox(height: 30),
              _buildRecentTransactionsSection(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarWidget(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavIndexChanged,
      ),
    );
  }
}