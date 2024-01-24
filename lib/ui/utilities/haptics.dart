// Flutter imports:
import "package:flutter/services.dart";

// Project imports:
import "package:graded/misc/storage.dart";

//void lightHaptics() => getPreference("haptic_feedback") ? HapticFeedback.lightImpact() : null;
void lightHaptics() => getPreference("haptic_feedback") ? HapticFeedback.lightImpact() : null;

//void heavyHaptics() => getPreference("haptic_feedback") ? HapticFeedback.vibrate() : null;
void heavyHaptics() => getPreference("haptic_feedback") ? HapticFeedback.heavyImpact() : null;
