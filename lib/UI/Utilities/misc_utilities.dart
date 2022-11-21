// Package imports:
import 'package:url_launcher/url_launcher.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
}

final Uri websiteLaunchUri = Uri.parse('https://nightdreamgames.com/');
final Uri playStoreLaunchUri = Uri.https('play.google.com', '/store/apps/details', {'id': 'com.NightDreamGames.Grade.ly'});
final Uri githubLaunchUri = Uri.parse('https://github.com/NightDreamGames/Grade.ly');
final Uri emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'contact.nightdreamgames@gmail.com',
  query: encodeQueryParameters(<String, String>{
    'subject': 'Grade.ly feedback',
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
      link = playStoreLaunchUri;
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
