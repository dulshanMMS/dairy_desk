import 'package:flutter/material.dart';
import '../models/bill.dart';

class BillStatusChip extends StatelessWidget {
  final BillStatus status;
  final bool compact;

  const BillStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case BillStatus.paid:
        backgroundColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
        label = 'Paid';
        break;
      case BillStatus.pending:
        backgroundColor = const Color(0xFFFF9800);
        textColor = Colors.white;
        label = 'Pending';
        break;
      case BillStatus.overdue:
        backgroundColor = const Color(0xFFF44336);
        textColor = Colors.white;
        label = 'Overdue';
        break;
      case BillStatus.cancelled:
        backgroundColor = const Color(0xFF9E9E9E);
        textColor = Colors.white;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
