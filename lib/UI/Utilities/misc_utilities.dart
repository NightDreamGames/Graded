// Dart imports:
import 'dart:io' show Platform;

// Package imports:
import 'package:url_launcher/url_launcher.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
}

final Uri websiteLaunchUri = Uri.parse('https://nightdreamgames.com/');
final Uri playStoreLaunchUri = Uri.https('play.google.com', '/store/apps/details', {'id': 'com.NightDreamGames.Grade.ly'});
final Uri appStoreLaunchUri = Uri.parse('https://apps.apple.com/us/app/graded-suivi-de-notes/id6444681284');
final Uri githubLaunchUri = Uri.parse('https://github.com/NightDreamGames/Graded');
final Uri emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'contact.nightdreamgames@gmail.com',
  query: encodeQueryParameters(<String, String>{
    'subject': 'Graded feedback',
    'body': 'Thank you for your feedback!',
  }),
);

void launchURL(int type) async {
  Uri link = websiteLaunchUri;

  switch (type) {
    case 0:
      link = websiteLaunchUri;
      break;
    case 1:
      if (Platform.isAndroid) {
        link = playStoreLaunchUri;
      } else if (Platform.isIOS) {
        link = appStoreLaunchUri;
      } else {
        link = websiteLaunchUri;
      }
      break;
    case 2:
      link = githubLaunchUri;
      break;
    case 3:
      link = emailLaunchUri;
      break;
  }

  if (!await launchUrl(
    link,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Error while opening link: $link';
  }
}
