import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            color:
                Colors.black.withOpacity(0.3), // Set opacity value (0.0 to 1.0)
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No internet here",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Optionally, set text color
                    ),
                  ),
                  const VerticalBox(height: 20),
                  // Image.asset("assets/no_internet.png"),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: buttonColor),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Refresh",
                        style: authScreensubTitleStyle()
                            .copyWith(color: Colors.white),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
