// Dart imports:
import "dart:io" show Platform;

// Flutter imports:
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

// Package imports:
import "package:url_launcher/url_launcher.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/localization/translations.dart";

enum Link { website, store, github, email, issueTracker, translate, twitter, instagram, linkedin, facebook }

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries.map((MapEntry<String, String> e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}").join("&");
}

final Uri websiteUrl = Uri.parse("https://nightdreamgames.com/");
final Uri playStoreUrl = Uri.https("play.google.com", "/store/apps/details", {"id": "com.NightDreamGames.Grade.ly"});
final Uri appStoreUrl = Uri.parse("https://apps.apple.com/us/app/graded-suivi-de-notes/id6444681284");
final Uri githubUrl = Uri.parse("https://github.com/NightDreamGames/Graded");
final Uri issueUrl = Uri.parse("https://github.com/NightDreamGames/Graded/issues");
final Uri translateUrl = Uri.parse("https://poeditor.com/join/project/6qnhP0EM5w");
final Uri emailUrl = Uri(
  scheme: "mailto",
  path: "contact@nightdreamgames.com",
  query: encodeQueryParameters(<String, String>{
    "subject": "Graded feedback",
    "body": "Thank you for your feedback!",
  }),
);
final Uri twitterUrl = Uri.parse("https://twitter.com/nightdreamgames");
final Uri instagramUrl = Uri.parse("https://www.instagram.com/graded.mobile");
final Uri facebookUrl = Uri.parse("https://www.facebook.com/profile.php?id=61551463161459");
final Uri linkedinUrl = Uri.parse("https://www.linkedin.com/company/nightdreamgames");

Future<void> launchURL(Link type) async {
  Uri link = websiteUrl;

  switch (type) {
    case Link.website:
      link = websiteUrl;
    case Link.store:
      if (isAndroid) {
        link = playStoreUrl;
      } else if (isiOS) {
        link = appStoreUrl;
      } else {
        link = websiteUrl;
      }
    case Link.github:
      link = githubUrl;
    case Link.issueTracker:
      link = issueUrl;
    case Link.translate:
      link = translateUrl;
    case Link.email:
      link = emailUrl;

    case Link.twitter:
      link = twitterUrl;
    case Link.instagram:
      link = instagramUrl;
    case Link.facebook:
      link = facebookUrl;
    case Link.linkedin:
      link = linkedinUrl;
  }

  if (!await launchUrl(
    link,
    mode: LaunchMode.externalApplication,
  )) {
    throw "Error while opening link: $link";
  }
}

bool isAndroid = !kIsWeb && Platform.isAndroid;
bool isiOS = !kIsWeb && Platform.isIOS;
bool isWeb = kIsWeb;

String? thresholdValidator(String? value, {int threshold = 0, bool inclusive = true}) {
  final double? number = Calculator.tryParse(value);

  if (number != null && ((inclusive && number < threshold) || (!inclusive && number <= threshold))) {
    return translations.invalid;
  }

  return null;
}

String? nullValidator(String? value) {
  final double? number = Calculator.tryParse(value);

  if (number == null) {
    return translations.invalid;
  }

  return null;
}

Size calculateTextSize({required BuildContext context, required String text, TextStyle? style}) {
  final TextScaler textScaler = MediaQuery.of(context).textScaler;
  final TextDirection textDirection = Directionality.of(context);

  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout();

  return textPainter.size;
}
