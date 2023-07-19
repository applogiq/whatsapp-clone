import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
// import 'package:whatsapp_ui/common/utils/colors.dart';
// import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/widgets/otp_field.dart';
import 'package:whatsapp_ui/features/chat/widgets/alert_widget.dart';

class OTPScreen extends ConsumerWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
    // isLoad = true;
    ref.read(authControllerProvider).verifyOTP(
          context,
          verificationId,
          userOTP,
        );
    // isLoad = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        showAlertDialog(context);
        FocusScope.of(context).unfocus();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(''),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your OTP",
                style: authScreenheadingStyle(),
              ),
              const VerticalBox(height: 16),
              Row(
                children: [
                  Text(
                    "The OTP has been sent to :",
                    style: authScreensubTitleStyle(),
                  ),
                  Text(
                    " $phoneNumber",
                    style: authScreensubTitleStyle().copyWith(
                        color: const Color.fromRGBO(237, 84, 60, 1),
                        fontSize: 14),
                  ),
                ],
              ),
              const VerticalBox(height: 24),
              Text(
                "Enter OTP",
                style: authScreensubTitleStyle(),
              ),
              const VerticalBox(height: 4),
              OTPField(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
              ),
              const VerticalBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
