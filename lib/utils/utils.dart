import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSnackBarError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showSnackBarSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
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
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: CupertinoActivityIndicator(
            radius: 25.5,
          ),
        ),
      ),
    );
  }

  static void showToast(String message,
      {Color backgroundColor = Colors.black54,
      Color textColor = Colors.white,
      ToastGravity gravity = ToastGravity.BOTTOM,
      Toast toastLength = Toast.LENGTH_SHORT}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
