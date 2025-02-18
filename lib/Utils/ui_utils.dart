import 'package:flutter/material.dart';

class UIUtils {
  /// Displays a SnackBar with the provided message in the given context.
  static void showMessage(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
        ),
      );
  }

  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium,),
        content: Text(message, style: Theme.of(context).textTheme.bodySmall),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Delete',
    required VoidCallback onConfirm,
    String cancelText = 'Cancel',
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.bodyMedium,),
          content: Text(content,  style: Theme.of(context).textTheme.bodySmall,),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Perform the confirmation action
              },
              child: Text(
                confirmText,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}