enum BillStatus { draft, pending, paid, cancelled, overdue }

enum PaymentMethod { cash, card, upi, netBanking, cheque }

class BillItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double discount;

  BillItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
  });

  double get totalPrice => (quantity * unitPrice) - discount;

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
    };
  }
}

class Bill {
  final String? id;
  final String billNumber;
  final String shopId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<BillItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double totalAmount;
  final BillStatus status;
  final PaymentMethod? paymentMethod;
  final DateTime createdDate;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final Map<String, dynamic> metadata;

  Bill({
    this.id,
    required this.billNumber,
    required this.shopId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    required this.createdDate,
    this.dueDate,
    this.paidDate,
    this.metadata = const {},
  });

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['_id']?.toString(),
      billNumber: map['billNumber'] ?? '',
      shopId: map['shopId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => BillItem.fromMap(item))
          .toList() ?? [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: BillStatus.values.firstWhere(
            (e) => e.toString().split('.').last == map['status'],
        orElse: () => BillStatus.draft,
      ),
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
            (e) => e.toString().split('.').last == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      )
          : null,
      createdDate: DateTime.parse(map['createdDate'] ?? DateTime.now().toIso8601String()),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      paidDate: map['paidDate'] != null ? DateTime.parse(map['paidDate']) : null,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'billNumber': billNumber,
      'shopId': shopId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isPaid => status == BillStatus.paid;
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isPaid;

  int get daysSinceCreated => DateTime.now().difference(createdDate).inDays;
  int? get daysUntilDue => dueDate?.difference(DateTime.now()).inDays;

  Bill copyWith({
    String? id,
    String? billNumber,
    String? shopId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<BillItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? totalAmount,
    BillStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? createdDate,
    DateTime? dueDate,
    DateTime? paidDate,
    Map<String, dynamic>? metadata,
  }) {
    return Bill(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      shopId: shopId ?? this.shopId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Bill(id: $id, billNumber: $billNumber, customerName: $customerName, totalAmount: $totalAmount, status: $status)';
  }
}

// Utility class for bill calculations
class BillCalculator {
  static Bill calculateTotals(Bill bill) {
    final subtotal = bill.items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final tax = subtotal * 0.18; // 18% GST
    final totalAmount = subtotal + tax - bill.discount;

    return bill.copyWith(
      subtotal: subtotal,
      tax: tax,
      totalAmount: totalAmount,
    );
  }

  static String generateBillNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'BILL-${now.year}${now.month.toString().padLeft(2, '0')}-${timestamp.toString().substring(timestamp.toString().length - 6)}';
  }
}