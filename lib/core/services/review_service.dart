import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles in-app review prompts and Play Store / App Store navigation.
///
/// Auto-prompt strategy: request after the user completes [_threshold] tasks,
/// but only once (stored in SharedPreferences). A manual trigger is always
/// available from Settings regardless of whether the auto-prompt has fired.
class ReviewService {
  ReviewService(this._prefs);

  final SharedPreferences _prefs;
  static const _completedKey = 'review_completed_count';
  static const _promptedKey = 'review_prompted';
  static const _threshold = 5;
  static const _androidPackageId = 'com.daniel.students_app';

  static final _review = InAppReview.instance;

  /// Call each time the user completes a task.
  /// Automatically requests the native review sheet once [_threshold] is reached.
  Future<void> onTaskCompleted() async {
    final alreadyPrompted = _prefs.getBool(_promptedKey) ?? false;
    if (alreadyPrompted) return;

    final count = (_prefs.getInt(_completedKey) ?? 0) + 1;
    await _prefs.setInt(_completedKey, count);

    if (count >= _threshold) {
      await _requestReview();
    }
  }

  /// Opens the native in-app review dialog.
  /// Falls back to the Play Store listing if the API is unavailable.
  Future<void> requestManualReview() async {
    final available = await _review.isAvailable();
    if (available) {
      await _review.requestReview();
    } else {
      await _review.openStoreListing(appStoreId: _androidPackageId);
    }
  }

  /// Opens the Play Store / App Store listing directly.
  Future<void> openStoreListing() async {
    await _review.openStoreListing(appStoreId: _androidPackageId);
  }

  Future<void> _requestReview() async {
    try {
      final available = await _review.isAvailable();
      if (available) {
        await _review.requestReview();
        await _prefs.setBool(_promptedKey, true);
      }
    } catch (_) {
      // Silently ignore — review API is best-effort
    }
  }
}
