

class Transaction {
  final String category;
  final String paymentMethod;
  final double amount;
  final String date;
  final String assetPath;

  Transaction({
    required this.category,
    required this.paymentMethod,
    required this.amount,
    required this.date,
    required this.assetPath,
  });
}

List<Transaction> transactionList = [];
