import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat shortDateFormatter = DateFormat('dd MMM');

  static String formatCurrency(double amount) {
    return currencyFormatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return dateFormatter.format(date);
  }

  static String formatDateTime(DateTime date) {
    return dateTimeFormatter.format(date);
  }

  static String formatShortDate(DateTime date) {
    return shortDateFormatter.format(date);
  }

  static String formatNumber(num number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }
}
