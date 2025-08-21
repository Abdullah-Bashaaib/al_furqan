import 'package:flutter/material.dart';

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static void showSnackBarError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  static void showSnackBarSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  static Color getThemeColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static void showDialogLoading({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('يتم تحميل البيانات'),
        content: CircularProgressIndicator(),
      ),
    );
  }
}
