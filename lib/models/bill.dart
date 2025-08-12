import 'package:mongo_dart/mongo_dart.dart';

enum PaymentMethod { cash, bank, upi, credit }

enum BillStatus { pending, paid, overdue, cancelled }

class BillItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  BillItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  }) : total = quantity * unitPrice;

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}

class Bill {
  final ObjectId? id;
  final ObjectId shopId;
  final String shopName;
  final List<BillItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final BillStatus status;
  final PaymentMethod? paymentMethod;
  final DateTime createdDate;
  final DateTime? paidDate;
  final DateTime? dueDate;
  final String? notes;

  Bill({
    this.id,
    required this.shopId,
    required this.shopName,
    required this.items,
    this.tax = 0.0,
    this.discount = 0.0,
    this.status = BillStatus.pending,
    this.paymentMethod,
    DateTime? createdDate,
    this.paidDate,
    this.dueDate,
    this.notes,
  }) : 
    subtotal = items.fold(0.0, (sum, item) => sum + item.total),
    total = items.fold(0.0, (sum, item) => sum + item.total) + tax - discount,
    createdDate = createdDate ?? DateTime.now();

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['_id'] as ObjectId?,
      shopId: map['shopId'] as ObjectId,
      shopName: map['shopName'] as String,
      items: (map['items'] as List)
          .map((item) => BillItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      status: BillStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => BillStatus.pending,
      ),
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString().split('.').last == map['paymentMethod'],
              orElse: () => PaymentMethod.cash,
            )
          : null,
      createdDate: map['createdDate'] is String
          ? DateTime.parse(map['createdDate'])
          : map['createdDate'] as DateTime,
      paidDate: map['paidDate'] != null
          ? (map['paidDate'] is String
              ? DateTime.parse(map['paidDate'])
              : map['paidDate'] as DateTime)
          : null,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] is String
              ? DateTime.parse(map['dueDate'])
              : map['dueDate'] as DateTime)
          : null,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'shopId': shopId,
      'shopName': shopName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'createdDate': createdDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
    };
  }

  Bill copyWith({
    ObjectId? id,
    ObjectId? shopId,
    String? shopName,
    List<BillItem>? items,
    double? tax,
    double? discount,
    BillStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? createdDate,
    DateTime? paidDate,
    DateTime? dueDate,
    String? notes,
  }) {
    return Bill(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      items: items ?? this.items,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdDate: createdDate ?? this.createdDate,
      paidDate: paidDate ?? this.paidDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }

  bool get isPaid => status == BillStatus.paid;
  bool get isPending => status == BillStatus.pending;
  bool get isOverdue => status == BillStatus.overdue || 
      (dueDate != null && DateTime.now().isAfter(dueDate!) && !isPaid);

  @override
  String toString() {
    return 'Bill{id: $id, shopName: $shopName, total: $total, status: $status, createdDate: $createdDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill &&
        other.id == id &&
        other.shopId == shopId &&
        other.total == total &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        shopId.hashCode ^
        total.hashCode ^
        status.hashCode;
  }
}
