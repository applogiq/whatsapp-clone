import 'package:flutter/widgets.dart';

class ErrorSccreen extends StatelessWidget {
  final String error;
  const ErrorSccreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(error),
    );
  }
}
