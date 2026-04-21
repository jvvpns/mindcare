import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'dart:async';
import 'dart:js' as js;

/// Service to handle app versioning and update prompts without hard resets.
class UpdateService {
  static final UpdateService instance = UpdateService._();
  UpdateService._();

  final _dio = Dio();

  /// Checks if a new version is available on the server.
  Future<bool> checkForUpdate() async {
    if (!kIsWeb) return false;

    try {
      // Fetch version.json from the same origin
      final response = await _dio.get('/version.json', queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch,
      });
      
      if (response.statusCode == 200) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        final serverVersion = data['version'] as String;
        
        if (serverVersion != AppConstants.appVersion) {
          debugPrint('UpdateService: New version available ($serverVersion). Current: ${AppConstants.appVersion}');
          return true;
        }
      }
    } catch (e) {
      debugPrint('UpdateService: Failed to check for updates: $e');
    }
    return false;
  }

  /// Forces a clean reload of the PWA
  void performUpdate() {
    if (kIsWeb) {
      // Force reload ignoring cache
      js.context.callMethod('eval', ['window.location.reload(true)']);
    }
  }
}
