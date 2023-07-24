import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';

import '../../../common/widgets/alert_packages/show_dialog_package.dart';

showAlertDialogInternet(BuildContext context) {
  showAnimatedDialog(
    context: context,
    barrierDismissible: true,

    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const SizedBox.shrink(),
        content: Text(
          "Check your Internet...!",
          textAlign: TextAlign.center,
          style: authScreenheadingStyle(),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: buttonColor),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Cancel",
                      style: authScreensubTitleStyle()
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },

    animationType: DialogTransitionType.size,

    curve: Curves.fastOutSlowIn,

// duration: const Duration(seconds: 1),
  );
}
