import 'package:flutter/material.dart';

class CustomColorContainer extends StatelessWidget {
  const CustomColorContainer({
    Key? key,
    required this.child,
    this.bgColor,
    this.shape = BoxShape.rectangle,
    this.left = 0.0,
    this.right = 0.0,
    this.verticalPadding = 0.0,
  }) : super(key: key);

  final dynamic bgColor;
  final Widget child;
  final double left;
  final double right;
  final BoxShape shape;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            top: verticalPadding,
            bottom: verticalPadding,
            left: left,
            right: right),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius:
                shape == BoxShape.circle ? null : BorderRadius.circular(10),
            color: bgColor ?? Colors.transparent,
            shape: shape),
        child: child);
  }
}
