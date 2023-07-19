import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    super.key,
    required this.buttonValues,
    required this.onChanged,
  });
  // final String notificationTitles;
  final bool buttonValues;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Transform.scale(
        scaleY: 0.89,
        scaleX: 0.95,
        child: CupertinoSwitch(
            thumbColor: Colors.white,
            activeColor: const Color.fromRGBO(253, 206, 47, 1),
            trackColor: const Color.fromRGBO(217, 217, 217, 1),
            value: buttonValues,
            onChanged: onChanged),
      ),
    );
  }
}
