import 'package:url_launcher/url_launcher.dart';

// URL Launcher
void openURL(String? url) async {
  if (url != null && url.isNotEmpty) {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening URL: $e');
    }
  }
}
