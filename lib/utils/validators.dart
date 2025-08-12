class Validators {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    
    return null;
  }

  static String? validateNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }
    
    return null;
  }

  static String? validatePositiveNumber(String? value, [String? fieldName]) {
    final numberValidation = validateNumber(value, fieldName);
    if (numberValidation != null) return numberValidation;
    
    final number = double.parse(value!.trim());
    if (number <= 0) {
      return '${fieldName ?? 'Value'} must be greater than 0';
    }
    
    return null;
  }

  static String? validateInteger(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (int.tryParse(value.trim()) == null) {
      return 'Enter a valid whole number';
    }
    
    return null;
  }

  static String? validateMinLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (value.trim().length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    
    return null;
  }
}
