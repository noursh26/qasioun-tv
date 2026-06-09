import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  static const String defaultWhatsAppNumber = '963945245117'; // Extracted from urls list

  // Launch WhatsApp with a message
  static Future<bool> launchWhatsApp({String? number, String message = 'مرحباً، أود تجديد اشتراكي في قاسيون TV'}) async {
    final cleanNumber = (number ?? defaultWhatsAppNumber).replaceAll(RegExp(r'[+\s-]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    
    // We try multiple formats for maximum compatibility
    final urls = [
      'whatsapp://send?phone=$cleanNumber&text=$encodedMessage',
      'https://wa.me/$cleanNumber?text=$encodedMessage',
      'https://api.whatsapp.com/send?phone=$cleanNumber&text=$encodedMessage',
    ];

    for (var urlString in urls) {
      final uri = Uri.parse(urlString);
      try {
        if (await canLaunchUrl(uri)) {
          final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (success) return true;
        }
      } catch (e) {
        print('Error launching WhatsApp url $urlString: $e');
      }
    }
    return false;
  }

  // General URL launcher
  static Future<bool> launchWebUrl(String urlString) async {
    if (urlString.isEmpty) return false;
    
    // Normalize links
    var cleanUrl = urlString.trim();
    if (cleanUrl == 'whatsapp') {
      return await launchWhatsApp();
    }
    
    // Fix broken links like "https://http://www.qasioun1.net/"
    if (cleanUrl.startsWith('https://http://')) {
      cleanUrl = cleanUrl.replaceFirst('https://http://', 'https://');
    } else if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    final uri = Uri.parse(cleanUrl);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL $cleanUrl: $e');
    }
    return false;
  }
}
