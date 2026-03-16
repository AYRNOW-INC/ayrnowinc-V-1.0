import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Checks whether the running backend is the correct AyrnowPlanB backend.
/// Prevents the silent confusion of running PlanB frontend against the original AYRNOW backend.
class BackendGuard {
  static const String expectedRepo = 'AyrnowPlanB';
  static String? detectedRepo;
  static bool? lifecycleEnrichment;
  static bool checked = false;

  /// Call once at app startup. Returns true if backend matches, false if mismatch, null if unreachable.
  static Future<bool?> verify() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/health'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        detectedRepo = data['repo'] as String?;
        lifecycleEnrichment = data['lifecycleEnrichment'] == 'true';
        checked = true;
        return detectedRepo == expectedRepo;
      }
    } catch (_) {
      // Backend unreachable
    }
    checked = true;
    return null;
  }

  static bool get isCorrectBackend => detectedRepo == expectedRepo;
  static bool get isMismatch => checked && detectedRepo != null && detectedRepo != expectedRepo;
  static String get mismatchMessage =>
      'Wrong backend detected.\n'
      'Expected: $expectedRepo\n'
      'Detected: ${detectedRepo ?? "unknown (original AYRNOW?)"}\n\n'
      'Start the PlanB backend:\n'
      'cd AyrnowPlanB/backend && mvn spring-boot:run';
}
