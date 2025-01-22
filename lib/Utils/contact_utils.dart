import 'package:flutter/cupertino.dart';
import '../Utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUtils {

  static void makeCall(String phoneNumber, BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
        UIUtils.showErrorDialog(
            context, 'Error', 'Unable to make call. Try again later');
    }
  }

  static void sendMessage(String phoneNumber, {String? message}) async {
    final whatsappMessage = message != null
        ? 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$phoneNumber';
    final uri = Uri.parse(whatsappMessage);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}