import 'package:country_picker/country_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phonenumberController = TextEditingController();
  Country? country;
  bool isLoad = false;
  void pickCountry() {
    showCountryPicker(
        context: context,
        onSelect: (Country _country) {
          setState(() {
            country = _country;
          });
        });
  }

  @override
  void dispose() {
    super.dispose();

    phonenumberController.dispose();
  }

  bool isLoading = false;
  // Add a boolean variable to track the loading state
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  void sendPhoneNumber() async {
    String phoneNumber = phonenumberController.text.trim();
    setState(() {
      isLoad = true;
    });
    if (country != null && phoneNumber.isNotEmpty) {
      print(isLoad);
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      showSnackBar(context: context, content: 'Fill out all the fields');
    }
    Future.delayed(const Duration(milliseconds: 2000), () {
      isLoad = false;
      setState(() {});
    });
    print("123$isLoad");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_outlined)),
              Text(
                "Enter your\nphone number",
                style: authScreenheadingStyle(),
              ),
              const VerticalBox(height: 12),
              Text(
                "Our app will verify your phone number",
                style: authScreensubTitleStyle(),
              ),
              const VerticalBox(height: 24),
              Text(
                "Mobile number",
                style: textFieldHeadingStyle(),
              ),
              // TextButton(
              //     onPressed: pickCountry, child: const Text("Pick country")),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: getProportionateScreenHeight(45),
                    width: getProportionateScreenWidth(60),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color.fromRGBO(242, 242, 242, 1)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (country != null)
                            Text("+${country!.phoneCode}")
                          else
                            const Text(''),
                          GestureDetector(
                              onTap: pickCountry,
                              child: const Icon(Icons.expand_more_rounded))
                        ],
                      ),
                    ),
                  ),
                  const HorizontalBox(width: 8),
                  SizedBox(
                    height: getProportionateScreenHeight(45),
                    width: size.width * 0.7,
                    child: TextField(
                      controller: phonenumberController,
                      autofocus: true,
                      decoration: InputDecoration(
                          fillColor: const Color.fromRGBO(242, 242, 242, 1),
                          filled: true,
                          hintText: 'type here',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 12, 0, 0)),
                      cursorWidth: 1.2,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (value) {},
                      style: authScreensubTitleStyle().copyWith(fontSize: 15),
                    ),
                  )
                  // SizedBox(
                  //   width: size.width * 0.4,
                  //   child: TextField(
                  //     controller: phonenumberController,
                  //     decoration:
                  //         const InputDecoration(hintText: 'Phone Number'),
                  //   ),
                  // )
                ],
              ),
              const VerticalBox(height: 12),
              Center(
                child: Text(
                  "Carrier charges may apply",
                  style: authScreensubTitleStyle(),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => sendPhoneNumber(),
                child: Container(
                  height: 54,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(41),
                      color: const Color.fromRGBO(237, 84, 60, 1)),
                  child: Center(
                      child: isLoad
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Continue',
                              style: GoogleFonts.manrope(
                                textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
