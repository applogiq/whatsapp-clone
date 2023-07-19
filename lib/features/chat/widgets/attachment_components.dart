import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';

class AttachmentWidgets extends StatelessWidget {
  const AttachmentWidgets(
      {super.key,
      required this.icons,
      required this.color,
      required this.title});
  final IconData icons;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          child: Icon(
            icons,
            color: Colors.black,
          ),
          backgroundColor: color,
        ),
        const VerticalBox(height: 4),
        Text(title)
      ],
    );
  }
}
