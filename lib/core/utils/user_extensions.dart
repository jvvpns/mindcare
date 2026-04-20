import 'package:supabase_flutter/supabase_flutter.dart';

extension SmartUserExtension on User {
  /// Safely extracts the user's first name, with backwards compatibility for old users.
  String get firstName {
    final meta = userMetadata;
    if (meta == null) return email?.split('@').first ?? 'Guiding Star';

    // 1. Try new discrete first_name field
    if (meta['first_name'] != null && meta['first_name'].toString().trim().isNotEmpty) {
      return meta['first_name'].toString().trim();
    }

    // 2. Try old full_name field
    if (meta['full_name'] != null && meta['full_name'].toString().trim().isNotEmpty) {
      return meta['full_name'].toString().trim().split(' ').first;
    }

    // 3. Fallback to email
    return email?.split('@').first ?? 'Guiding Star';
  }

  /// Safely extracts the user's last name, with backwards compatibility.
  String get lastName {
    final meta = userMetadata;
    if (meta == null) return '';

    // 1. Try new discrete last_name field
    if (meta['last_name'] != null && meta['last_name'].toString().trim().isNotEmpty) {
      return meta['last_name'].toString().trim();
    }

    // 2. Try old full_name field
    if (meta['full_name'] != null && meta['full_name'].toString().trim().isNotEmpty) {
      final parts = meta['full_name'].toString().trim().split(' ');
      if (parts.length > 1) {
        return parts.sublist(1).join(' '); // Return everything after first name
      }
    }

    return '';
  }

  /// Retrieves the full display name combining first and last name elegantly.
  String get displayName {
    final first = firstName;
    final last = lastName;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  /// Retrieves the user's school
  String get school {
    return userMetadata?['school']?.toString() ?? 'Unknown School';
  }

  /// Retrieves the user's year level
  String get yearLevel {
    return userMetadata?['year_level']?.toString() ?? '1st Year';
  }
}
