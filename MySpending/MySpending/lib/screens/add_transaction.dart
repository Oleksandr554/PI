import '../models/transaction_data.dart';
import 'package:flutter/material.dart';
import '../widgets/categories.dart'; 

class AddTransactionSheet extends StatefulWidget {
  final VoidCallback onTransactionAdded;
  
  const AddTransactionSheet({super.key, required this.onTransactionAdded});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final TextEditingController amountController = TextEditingController();
  CategoryItem? selectedCategory = categoriesGlobal.isNotEmpty 
      ? categoriesGlobal.first 
      : null; 
  bool showCategoryPopup = false;
  String? selectedPayment = "Cash"; 
  DateTime selectedDate = DateTime.now();

  void addTransaction() {
    if (selectedCategory == null) return;
    if (amountController.text.isEmpty) return;

    final double amount = double.tryParse(amountController.text) ?? 0;
    final String formattedDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2,'0')}-${selectedDate.day.toString().padLeft(2,'0')}";

    final newTransaction = Transaction(
      category: selectedCategory!.name,
      paymentMethod: selectedPayment ?? "Cash",
      amount: amount,
      date: formattedDate,
      assetPath: selectedCategory!.assetPath,
    );

    transactionList.add(newTransaction);
    widget.onTransactionAdded();
    Navigator.pop(context);
  }

  Future<void> pickDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      setState(() => selectedDate = newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoriesGlobal; 
    
    return Container(
      height: 797,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          SingleChildScrollView( 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(width: 1.5),
                            ),
                            child: const Icon(Icons.arrow_back, size: 20),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          "Add transaction",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(width: 1.5, color: const Color.fromARGB(255, 0, 0, 0)),
                            ),
                            child: const Icon(Icons.access_time, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 363,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEAF2),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Amount",
                              style: TextStyle(
                                  color: Color(0xFF959595), fontSize: 20)),
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "0\$",
                              ),
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => setState(() => showCategoryPopup = true),
                      child: Container(
                        width: 363,
                        height: 135,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCEAF2),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Category",
                                style: TextStyle(
                                    color: Color(0xFF959595), fontSize: 20)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (selectedCategory != null)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Image.asset(selectedCategory!.assetPath, 
                                        height: 50,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.shopping_bag_outlined, size: 32, color: Color.fromARGB(255, 0, 0, 0));
                                        }),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16)),
                                    child:
                                        const Icon(Icons.category_outlined, size: 28),
                                  ),
                                const SizedBox(width: 16),
                                Text(
                                  selectedCategory?.name ?? "Select category",
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.w500),
                                ),
                                const Spacer(),
                                const Icon(Icons.keyboard_arrow_down, size: 26),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text("Payment type",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),
                  
                  paymentButton("Cash"),
                  const SizedBox(height: 12),
                  paymentButton("Card"),
                  const SizedBox(height: 12),
                  paymentButton("Check"),

                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start, 
                    children: [
                      bottomBtn("Draft", const Color(0xFFDCEAF2)),
                      const SizedBox(width: 20), 
                      GestureDetector(
                        onTap: addTransaction,
                        child: bottomBtn("Add", const Color(0xFFBDD2E0)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          if (showCategoryPopup) categoryPopup(),
        ],
      ),
    );
  }

  Widget categoryPopup() {
    final categories = categoriesGlobal;

    return Positioned(
      top: 260,
      left: 15,
      child: Container(
        width: 363,
        height: 200,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  blurRadius: 12,
                  spreadRadius: 3,
                  color: Colors.black.withOpacity(0.15))
            ]),
        child: ListView(
          children: categories
              .map((c) => ListTile(
                    leading: Image.asset(c.assetPath, height: 45,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.category, size: 55);
                        }),
                    title: Text(c.name, style: const TextStyle(fontSize: 20)),
                    onTap: () {
                      setState(() {
                        selectedCategory = c;
                        showCategoryPopup = false;
                      });
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget paymentButton(String text) {
    bool isSelected = selectedPayment == text; 
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = text;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(width: 2, color: isSelected ? const Color(0xFFBDD2E0) : Colors.black), 
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          mainAxisSize: MainAxisSize.min, 
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.circle_outlined, 
                 size: 22,
                 color: isSelected ? const Color(0xFFBDD2E0) : const Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 20, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget bottomBtn(String text, Color color) {
    return Container(
      width: 165,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }
}