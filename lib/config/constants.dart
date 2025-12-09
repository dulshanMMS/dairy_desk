class AppConstants {
  // Tax rates
  static const double defaultTaxRate = 0.18; // 18% GST

  // Currency
  static const String currency = '₹';

  // App info
  static const String appName = 'Dairy Desk';
  static const String appVersion = '1.0.0';

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Validation
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const double minPrice = 0.0;
  static const double maxPrice = 999999.99;
  static const int minStock = 0;
  static const int maxStock = 999999;

  // Defaults
  static const String defaultBillStatus = 'pending';
  static const String defaultPaymentMethod = 'cash';

  // Messages
  static const String updateSuccess = 'Updated successfully!';
  static const String saveSuccess = 'Saved successfully!';
  static const String deleteSuccess = 'Deleted successfully!';

  // Dairy Categories
  static const List<String> dairyCategories = [
    'Milk',
    'Curd',
    'Butter',
    'Cheese',
    'Ghee',
    'Paneer',
    'Ice Cream',
    'Other',
  ];
}
