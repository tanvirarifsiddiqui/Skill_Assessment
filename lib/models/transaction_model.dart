class Transaction {
  final int id;
  final String transactionNo;
  final int type;
  final double amount;
  final DateTime transactionDate;
  final String details;
  final String billNo;
  final String? image;
  final String? imageFullPath;
  final int status;

  Transaction({
    required this.id,
    required this.transactionNo,
    required this.type,
    required this.amount,
    required this.transactionDate,
    required this.details,
    required this.billNo,
    required this.image,
    required this.imageFullPath,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      transactionNo: json['transaction_no'],
      type: json['type'],
      amount: double.parse(json['amount']),
      transactionDate: DateTime.parse(json['transaction_date']),
      details: json['details'],
      billNo: json['bill_no'],
      image: json['image'],
      imageFullPath: json['image_full_path'],
      status: json['status'],
    );
  }
}
