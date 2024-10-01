// Flutter imports:
import "package:flutter/services.dart";

// Project imports:
import "package:graded/misc/storage.dart";

//void lightHaptics() => getPreference("hapticFeedback") ? HapticFeedback.lightImpact() : null;
void lightHaptics() => getPreference("hapticFeedback") ? HapticFeedback.lightImpact() : null;

//void heavyHaptics() => getPreference("hapticFeedback") ? HapticFeedback.vibrate() : null;
void heavyHaptics() => getPreference("hapticFeedback") ? HapticFeedback.heavyImpact() : null;
