import 'package:intl/intl.dart';

/// Utility class for formatting various data types
class Formatters {
  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MM/dd/yy').format(date);
  }

  // Time formatting
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatTimeAmPm(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatTimeWithSeconds(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  // DateTime formatting
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  static String formatDateTimeFull(DateTime dateTime) {
    return DateFormat('EEEE, MMMM dd, yyyy - hh:mm a').format(dateTime);
  }

  // Relative time formatting
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  // Chat timestamp formatting
  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (messageDate == today) {
      return formatTimeAmPm(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return formatDate(dateTime);
    }
  }

  // Number formatting
  static String formatNumber(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$').format(amount);
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  // String formatting
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => capitalizeFirst(word.toLowerCase()))
        .join(' ');
  }

  static String toCamelCase(String text) {
    final words = text.split(' ');
    return words
        .asMap()
        .entries
        .map((entry) {
          if (entry.key == 0) {
            return entry.value.toLowerCase();
          }
          return capitalizeFirst(entry.value.toLowerCase());
        })
        .join('');
  }

  // Phone number formatting
  static String formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    return phone;
  }

  // Email formatting
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final localPart = parts[0];
    if (localPart.length <= 2) {
      return '${localPart[0]}***@${parts[1]}';
    }
    
    return '${localPart.substring(0, 2)}${'*' * (localPart.length - 2)}@${parts[1]}';
  }

  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // Duration formatting
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Role formatting
  static String formatRole(String role) {
    const roleMap = {
      'personnel': 'Personnel',
      'dependent': 'Dependent',
      'admin': 'Administrator',
      'family': 'Family Member',
    };
    return roleMap[role.toLowerCase()] ?? toTitleCase(role);
  }

  // Status formatting
  static String formatStatus(String status) {
    const statusMap = {
      'active': 'Active',
      'inactive': 'Inactive',
      'pending': 'Pending Approval',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'suspended': 'Suspended',
      'online': 'Online',
      'offline': 'Offline',
      'away': 'Away',
    };
    return statusMap[status.toLowerCase()] ?? toTitleCase(status);
  }

  // Message preview formatting
  static String formatMessagePreview(String message, {int maxLength = 50}) {
    if (message.length <= maxLength) {
      return message;
    }
    return '${message.substring(0, maxLength)}...';
  }
}
