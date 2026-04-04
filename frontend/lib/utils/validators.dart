/// Validators for common form inputs
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be at most 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, underscores, dots, and hyphens';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  // General required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid number';
    }
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    try {
      Uri.parse(value);
      return null;
    } catch (_) {
      return 'Please enter a valid URL';
    }
  }

  // Min length validation
  static String? validateMinLength(
    String? value,
    int minLength,
  ) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < minLength) {
      return 'Must be at least $minLength characters';
    }
    return null;
  }

  // Max length validation
  static String? validateMaxLength(
    String? value,
    int maxLength,
  ) {
    if (value == null) {
      return null;
    }
    if (value.length > maxLength) {
      return 'Must be at most $maxLength characters';
    }
    return null;
  }

  // Range validation
  static String? validateRange(
    String? value,
    int min,
    int max,
  ) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    try {
      final num = int.parse(value);
      if (num < min || num > max) {
        return 'Must be between $min and $max';
      }
      return null;
    } catch (_) {
      return 'Please enter a valid number';
    }
  }

  // Military email validation (specific to SENTRIX)
  static String? validateMilitaryEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Military email is required';
    }
    if (!value.endsWith('.mil') && !value.endsWith('@defense.mil')) {
      return 'Please use a valid military email address (.mil)';
    }
    return validateEmail(value);
  }

  // Message validation
  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }
    if (value.length > 1000) {
      return 'Message is too long (max 1000 characters)';
    }
    return null;
  }
}
