import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';

import '../../../common/widgets/alert_packages/show_dialog_package.dart';

showAlertDialog(BuildContext context) {
  showAnimatedDialog(
    context: context,
    barrierDismissible: true,

    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const SizedBox.shrink(),
        content: const Padding(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Text(
            "Do you want to Exit app?",
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: getProportionateScreenHeight(44),
              width: getProportionateScreenWidth(120),
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromARGB(255, 187, 179, 179),
                        // offset: Offset(
                        //   20,
                        //   20,
                        // ),
                        blurRadius: 25),
                  ],
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromRGBO(255, 255, 255, 1)),
              child: const Center(child: Text("Cancel")),
            ),
          ),
          GestureDetector(
            onTap: () async {
              SystemNavigator.pop();
            },
            child: Container(
              height: getProportionateScreenHeight(44),
              width: getProportionateScreenWidth(120),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromRGBO(254, 86, 49, 1)),
              child: const Center(
                  child: Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              )),
            ),
          ),
          SizedBox(
            width: getProportionateScreenWidth(5),
          )
        ],
      );
    },

    animationType: DialogTransitionType.size,

    curve: Curves.fastOutSlowIn,

// duration: const Duration(seconds: 1),
  );
}
