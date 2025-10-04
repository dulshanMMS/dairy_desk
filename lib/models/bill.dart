enum BillStatus { draft, pending, paid, cancelled, overdue }

enum PaymentMethod { cash, card, upi, netBanking, cheque }

class BillItem {
  final String productId;
  final String productName;
  final double buyPrice;
  final double sellPrice;
  final double unitPrice; // Alias for sellPrice for UI compatibility
  final int quantity;
  final double totalAmount;
  final double discount;

  BillItem({
    required this.productId,
    required this.productName,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.totalAmount,
    this.discount = 0,
  }) : unitPrice = sellPrice;

  // Calculate profit for this line item
  double get profit => (sellPrice - buyPrice) * quantity;

  // Calculate profit margin percentage
  double get profitMargin =>
      buyPrice > 0 ? ((sellPrice - buyPrice) / buyPrice) * 100 : 0;

  // Total price after discount (alias for totalAmount)
  double get totalPrice => totalAmount - discount;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'discount': discount,
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
    );
  }
}

class Bill {
  final String? id;
  final String billNumber;
  final String shopId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final DateTime date;
  final DateTime createdDate;
  final List<BillItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String status;
  final String paymentMethod;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String? notes;
  final Map<String, dynamic>? metadata;

  Bill({
    this.id,
    required this.billNumber,
    required this.shopId,
    required this.customerName,
    this.customerPhone = '',
    this.customerAddress = '',
    required this.date,
    DateTime? createdDate,
    required this.items,
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    this.pendingAmount = 0,
    this.status = 'pending',
    this.paymentMethod = 'cash',
    this.dueDate,
    this.paidDate,
    this.notes,
    this.metadata,
  }) : createdDate = createdDate ?? date;

  // Calculate total profit from all items in this bill
  double get totalProfit => items.fold(0, (sum, item) => sum + item.profit);

  // Calculate total cost (sum of buy prices * quantities)
  double get totalCost =>
      items.fold(0, (sum, item) => sum + (item.buyPrice * item.quantity));

  // Calculate overall profit margin for this bill
  double get profitMargin => totalCost > 0 ? (totalProfit / totalCost) * 100 : 0;

  // Check if bill is fully paid
  bool get isFullyPaid => paidAmount >= totalAmount;

  // Get remaining amount to be paid
  double get remainingAmount => totalAmount - paidAmount;

  // Check if bill is overdue
  bool get isOverdue =>
      dueDate != null &&
      DateTime.now().isAfter(dueDate!) &&
      !isFullyPaid;

  Bill copyWith({
    String? id,
    String? billNumber,
    String? shopId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    DateTime? date,
    DateTime? createdDate,
    List<BillItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? totalAmount,
    double? paidAmount,
    double? pendingAmount,
    String? status,
    String? paymentMethod,
    DateTime? dueDate,
    DateTime? paidDate,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return Bill(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      shopId: shopId ?? this.shopId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      date: date ?? this.date,
      createdDate: createdDate ?? this.createdDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'billNumber': billNumber,
      'shopId': shopId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'date': date.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'dueDate': dueDate?.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['_id']?.toString(),
      billNumber: map['billNumber'] ?? '',
      shopId: map['shopId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      date: DateTime.parse(map['date']),
      createdDate: map['createdDate'] != null ? DateTime.parse(map['createdDate']) : null,
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => BillItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      pendingAmount: (map['pendingAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'cash',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      paidDate: map['paidDate'] != null ? DateTime.parse(map['paidDate']) : null,
      notes: map['notes'],
      metadata: map['metadata'],
    );
  }
}

// Utility class for bill calculations
class BillCalculator {
  static Bill calculateTotals(Bill bill) {
    final subtotal = bill.items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
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
