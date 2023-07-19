import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Common toast message method
toastMessage(String messageContent, Color backgroundColor, Color textColor) {
  Fluttertoast.showToast(
      msg: messageContent,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0);
}

// Error message toast
errorToastMessage(
  String messageContent,
) {
  Fluttertoast.showToast(
      msg: messageContent,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.white,
      textColor: Colors.white,
      fontSize: 16.0);
}
