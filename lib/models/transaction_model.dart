class TransactionModel {
  final int? id;
  final String type; // 'expense' hoặc 'income'
  final String category;
  final double amount;
  final String date; // dd/MM/yyyy
  final String note;

  TransactionModel({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'category': category,
        'amount': amount,
        'date': date,
        'note': note,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel(
        id: map['id'],
        type: map['type'],
        category: map['category'],
        amount: (map['amount'] as num).toDouble(),
        date: map['date'],
        note: map['note'] ?? '',
      );
}
