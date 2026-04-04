import 'formatters.dart';

// String extensions
extension StringExtensions on String {
  /// Capitalize the first character
  String get toCapitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case
  String get toTitleCase {
    return Formatters.toTitleCase(this);
  }

  /// Convert to camel case
  String get toCamelCase {
    return Formatters.toCamelCase(this);
  }

  /// Check if email is valid
  bool get isValidEmail {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }

  /// Check if phone is valid
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[\s\-]'), ''));
  }

  /// Check if URL is valid
  bool get isValidUrl {
    try {
      Uri.parse(this);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check if string is numeric
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Check if string is alphabetic
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Check if string is alphanumeric
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Check if string contains only whitespace
  bool get isBlank {
    return trim().isEmpty;
  }

  /// Check if string is not empty
  bool get isNotEmpty {
    return isNotEmpty;
  }

  /// Remove all whitespace
  String get removeAllWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Reverse string
  String get reversed {
    return split('').reversed.join('');
  }

  /// Check if string is palindrome
  bool get isPalindrome {
    final cleaned = removeAllWhitespace.toLowerCase();
    return cleaned == cleaned.reversed;
  }

  /// Repeat string n times
  String repeat(int times) {
    return List.filled(times, this).join('');
  }

  /// Get word count
  int get wordCount {
    return split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  /// Truncate string to maximum length
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Safe substring - doesn't throw error
  String safeSubstring(int start, [int? end]) {
    if (start < 0) start = 0;
    if (end != null && end > length) end = length;
    return substring(start, end);
  }

  /// Mask sensitive data
  String get masked {
    return Formatters.maskEmail(this);
  }

  /// Convert to slug (for URLs)
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  /// Check if string contains any emoji
  bool get hasEmoji {
    return RegExp(
      r'[\u{1f600}-\u{1f64f}]|[\u{1f300}-\u{1f5ff}]|[\u{1f680}-\u{1f6ff}]|[\u{1f700}-\u{1f77f}]|[\u{1f780}-\u{1f7ff}]|[\u{1f800}-\u{1f8ff}]|[\ud83c][\udf00-\udfff]|[\ud83d][\ude00-\ude4f]',
      unicode: true,
    ).hasMatch(this);
  }

  /// Remove all emojis
  String get removeEmojis {
    return replaceAll(
      RegExp(
        r'[\u{1f600}-\u{1f64f}]|[\u{1f300}-\u{1f5ff}]|[\u{1f680}-\u{1f6ff}]|[\u{1f700}-\u{1f77f}]|[\u{1f780}-\u{1f7ff}]|[\u{1f800}-\u{1f8ff}]|[\ud83c][\udf00-\udfff]|[\ud83d][\ude00-\ude4f]',
        unicode: true,
      ),
      '',
    );
  }
}

// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Get formatted date string
  String get formattedDate {
    return Formatters.formatDate(this);
  }

  /// Get formatted time string
  String get formattedTime {
    return Formatters.formatTime(this);
  }

  /// Get formatted datetime string
  String get formattedDateTime {
    return Formatters.formatDateTime(this);
  }

  /// Get time ago string
  String get timeAgo {
    return Formatters.formatTimeAgo(this);
  }

  /// Get chat formatted time
  String get chatFormattedTime {
    return Formatters.formatChatTime(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Check if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999, 999);
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
  }

  /// Get start of year
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// Get end of year
  DateTime get endOfYear {
    return DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));
  }

  /// Get next day
  DateTime get nextDay {
    return add(const Duration(days: 1));
  }

  /// Get previous day
  DateTime get previousDay {
    return subtract(const Duration(days: 1));
  }

  /// Get age from birthday
  int get ageFromBirthday {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Check if is leap year
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}

// int extensions
extension IntExtensions on int {
  /// Format as currency
  String get asCurrency {
    return '\$$this';
  }

  /// Format as ordinal
  String get toOrdinal {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Check if even
  bool get isEven {
    return this % 2 == 0;
  }

  /// Check if odd
  bool get isOdd {
    return this % 2 != 0;
  }

  /// Check if positive
  bool get isPositive {
    return this > 0;
  }

  /// Check if negative
  bool get isNegative {
    return this < 0;
  }

  /// Get absolute value
  int get abs {
    return this.abs();
  }

  /// Convert seconds to duration
  Duration get toDuration {
    return Duration(seconds: this);
  }

  /// Repeat action n times
  void times(Function action) {
    for (int i = 0; i < this; i++) {
      action();
    }
  }
}

// double extensions
extension DoubleExtensions on double {
  /// Format as currency
  String get asCurrency {
    return '\$${toStringAsFixed(2)}';
  }

  /// Format as percentage
  String get asPercentage {
    return '${(this * 100).toStringAsFixed(1)}%';
  }

  /// Round to n decimal places
  double roundTo(int decimals) {
    return double.parse(toStringAsFixed(decimals));
  }

  /// Check if in range
  bool inRange(double min, double max) {
    return this >= min && this <= max;
  }

  /// Clamp value between min and max
  double clamp(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

// List extensions
extension ListExtensions<T> on List<T> {
  /// Check if list is empty
  bool get isEmpty {
    return isEmpty;
  }

  /// Check if list is not empty
  bool get isNotEmpty {
    return isNotEmpty;
  }

  /// Get random element
  T? get random {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecond + length) % length];
  }

  /// Shuffle list
  List<T> get shuffled {
    final list = [...this];
    list.shuffle();
    return list;
  }

  /// Flatten nested lists
  List<T> flatten() {
    final result = <T>[];
    for (var element in this) {
      if (element is List) {
        result.addAll((element as List<T>).flatten());
      } else {
        result.add(element);
      }
    }
    return result;
  }

  /// Unique elements
  List<T> get unique {
    return toSet().toList();
  }

  /// Reverse list without modifying original
  List<T> get reversed {
    return List<T>.from(this.toList().reversed);
  }
}

// Duration extensions
extension DurationExtensions on Duration {
  /// Get formatted duration string
  String get formatted {
    return Formatters.formatDuration(this);
  }

  /// Check if duration is more than hours
  bool isMoreThan(Duration other) {
    return compareTo(other) > 0;
  }

  /// Check if duration is less than hours
  bool isLessThan(Duration other) {
    return compareTo(other) < 0;
  }
}
