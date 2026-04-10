import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles in-app review prompts and Play Store navigation.
///
/// Auto-prompt strategy: show native review dialog after [_threshold] task
/// completions (once only, only in release mode on a real device).
///
/// Manual trigger: always opens the Play Store listing via url_launcher,
/// which works in both debug and release regardless of whether the native
/// review API is available.
class ReviewService {
  ReviewService(this._prefs);

  final SharedPreferences _prefs;
  static const _completedKey = 'review_completed_count';
  static const _promptedKey = 'review_prompted';
  static const _threshold = 5;
  static const _packageId = 'com.daniel.students_app';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=$_packageId';

  static final _review = InAppReview.instance;

  /// Call each time the user completes a task.
  /// Triggers the native review sheet once [_threshold] is reached (release only).
  Future<void> onTaskCompleted() async {
    final alreadyPrompted = _prefs.getBool(_promptedKey) ?? false;
    if (alreadyPrompted) return;

    final count = (_prefs.getInt(_completedKey) ?? 0) + 1;
    await _prefs.setInt(_completedKey, count);

    if (count >= _threshold) {
      try {
        if (await _review.isAvailable()) {
          await _review.requestReview();
          await _prefs.setBool(_promptedKey, true);
        }
      } catch (_) {
        // Best-effort — silently ignore in debug / unsupported environments
      }
    }
  }

  /// Opens the Play Store listing directly.
  /// Works in both debug and release on any Android device.
  Future<void> requestManualReview() async {
    // Try the market:// deep-link first (opens Play Store app)
    final marketUri = Uri.parse('market://details?id=$_packageId');
    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri);
      return;
    }
    // Fall back to the web URL
    final webUri = Uri.parse(_playStoreUrl);
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}
