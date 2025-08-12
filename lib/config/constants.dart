class AppConstants {
  // App Information
  static const String appName = 'DairyDesk';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Manage your dairy & farm business';

  // Database Collections
  static const String dairyCollection = 'dairy_products';
  static const String farmCollection = 'farm_products';
  static const String shopCollection = 'shops';
  static const String billCollection = 'bills';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';

  // Validation Rules
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const double minPrice = 0.01;
  static const double maxPrice = 999999.99;
  static const int minStock = 0;
  static const int maxStock = 999999;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 50.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Error Messages
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String validationError = 'Please check the entered information.';
  static const String saveError = 'Failed to save data. Please try again.';
  static const String loadError = 'Failed to load data. Please try again.';

  // Success Messages
  static const String saveSuccess = 'Data saved successfully!';
  static const String updateSuccess = 'Data updated successfully!';
  static const String deleteSuccess = 'Data deleted successfully!';

  // Business Categories
  static const List<String> dairyCategories = [
    'Milk',
    'Yogurt',
    'Cheese',
    'Butter',
    'Cream',
    'Ice Cream',
    'Others'
  ];

  static const List<String> farmCategories = [
    'Crops',
    'Livestock',
    'Equipment',
    'Seeds',
    'Fertilizers',
    'Others'
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Card',
    'UPI',
    'Net Banking',
    'Cheque'
  ];

  // Bill Status Options
  static const List<String> billStatuses = [
    'Draft',
    'Pending',
    'Paid',
    'Cancelled',
    'Overdue'
  ];

  // Farm Item Types
  static const List<String> farmItemTypes = [
    'Crop',
    'Livestock'
  ];

  // Crop Status Options
  static const List<String> cropStatuses = [
    'Planted',
    'Growing',
    'Ready',
    'Harvested'
  ];

  // Livestock Health Status
  static const List<String> healthStatuses = [
    'Excellent',
    'Good',
    'Fair',
    'Poor'
  ];

  // Default Tax Rate (GST)
  static const double defaultTaxRate = 0.18; // 18%

  // Backup and Sync
  static const Duration syncInterval = Duration(minutes: 30);
  static const int maxBackupFiles = 5;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Paths
  static const String imagesPath = 'assets/images/';
  static const String animationsPath = 'assets/animations/';
}

class ApiConstants {
  // MongoDB Configuration
  static const String mongoUrl = "mongodb+srv://dairydesk0:BafyS9Ikw8Wd4rcm@cluster0.awdhjs1.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
  static const String databaseName = "dairydesk";

  // Connection Settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration requestTimeout = Duration(seconds: 15);
  static const int maxRetries = 3;
}