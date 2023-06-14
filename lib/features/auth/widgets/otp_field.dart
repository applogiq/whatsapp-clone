import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/widgets/otp_text_field.dart';

class OTPField extends ConsumerStatefulWidget {
  const OTPField({Key? key, required this.verificationId}) : super(key: key);
  final String verificationId;
  @override
  ConsumerState<OTPField> createState() => _OTPFieldState();
}

class _OTPFieldState extends ConsumerState<OTPField> {
  FocusNode? pin1FN;
  FocusNode? pin2FN;
  FocusNode? pin3FN;
  FocusNode? pin4FN;
  FocusNode? pin5FN;
  FocusNode? pin6FN;
  List focusNodes = [];
  List controller = [];
  String otpValue = "";
  TextEditingController otpController1 = TextEditingController();
  TextEditingController otpController2 = TextEditingController();
  TextEditingController otpController3 = TextEditingController();
  TextEditingController otpController4 = TextEditingController();
  TextEditingController otpController5 = TextEditingController();
  TextEditingController otpController6 = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  bool isLoading = false;

  void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
    setState(() {
      isLoading = true;
    });
    ref.read(authControllerProvider).verifyOTP(
          context,
          widget.verificationId,
          userOTP,
        );
    Future.delayed(const Duration(milliseconds: 2000), () {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    pin1FN = FocusNode();
    pin2FN = FocusNode();
    pin3FN = FocusNode();
    pin4FN = FocusNode();
    pin5FN = FocusNode();
    pin6FN = FocusNode();
    focusNodes = [pin1FN, pin2FN, pin3FN, pin4FN, pin5FN, pin6FN];
    controller = [
      otpController1,
      otpController2,
      otpController3,
      otpController4,
      otpController5,
      otpController6
    ];
  }

  @override
  void dispose() {
    otpController1.dispose();
    otpController2.dispose();
    otpController3.dispose();
    otpController4.dispose();
    otpController5.dispose();
    otpController6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
              controller.length,
              (index) => Form(
                    child: SizedBox(
                      width: size.width / 7.4,
                      child: OTPFormField(
                          focusNode: focusNodes[index],
                          controller: controller[index],
                          onChange: (String value) {
                            checkFocus(value,
                                index == controller.length - 1 ? true : false);
                          }),
                    ),
                  )),
        ),
        const SizedBox(
          height: 150,
        ),
        InkWell(
          onTap: () => verifyOTP(ref, context, ''),
          child: Container(
            height: 54,
            width: double.maxFinite,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(41),
                color: const Color.fromRGBO(237, 84, 60, 1)),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('Continue',
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      )),
            ),
          ),
        ),
      ],
    );
  }

  void checkFocus(String value, bool isLast) {
    if (value.length == 1) {
      if (isLast) {
        FocusScope.of(context).unfocus();
      } else {
        FocusScope.of(context).nextFocus();
      }
    } else if (value.isEmpty) {
      FocusScope.of(context).previousFocus();
    }
    if (otpController1.text.isNotEmpty &&
        otpController2.text.isNotEmpty &&
        otpController3.text.isNotEmpty &&
        otpController4.text.isNotEmpty &&
        otpController5.text.isNotEmpty &&
        otpController6.text.isNotEmpty) {
      // widget.loginProvider.loginButtonEnabled(true);
      otpValue = otpController1.text +
          otpController2.text +
          otpController3.text +
          otpController4.text +
          otpController5.text +
          otpController6.text;
      verifyOTP(ref, context, otpValue.trim());
      // context.read<LoginProvider>().login(context);
    } else {
      // widget.loginProvider.loginButtonEnabled(false);
    }
  }
}
