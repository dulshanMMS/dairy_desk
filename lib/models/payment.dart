class Payment {
  final String? id;
  final String billId;
  final double amount;
  final String method; // cash, card, upi, etc.
  final DateTime date;
  final String? note;

  Payment({
    this.id,
    required this.billId,
    required this.amount,
    required this.method,
    required this.date,
    this.note,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['_id']?.toString(),
      billId: map['billId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      method: map['method'] ?? 'cash',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'amount': amount,
      'method': method,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}

