import 'package:country_picker/country_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/toast_message.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/alert_widget.dart';

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
  var countrys = Country(
    phoneCode: '+91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
  );

  void defaultpickCountry() {
    showCountryPicker(
        context: context,
        onSelect: (Country _country) {
          setState(() {
            countrys = _country;
          });
        });
  }

  void pickCountry() {
    showCountryPicker(
        showPhoneCode: true,
        context: context,
        onSelect: (Country _country) {
          setState(() {
            country = _country;
          });
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    errortext = '';
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    phonenumberController.dispose();
  }

  bool isLoading = false;
  bool isButtonEnable = false;
  String errortext = '';
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
    } else if (country == null) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '${countrys.phoneCode}$phoneNumber');
    } else {
      showSnackBar(
          context: context, content: 'Please select your country code');
    }
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        isLoad = false;
      });
    });
    print("123$isLoad");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        showAlertDialog(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    onTap: () {
                      showAlertDialog(context);
                    },
                    child: const Icon(Icons.arrow_back_outlined)),
                const VerticalBox(height: 12),

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
                  "Phone number",
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
                      width: getProportionateScreenWidth(62),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromRGBO(242, 242, 242, 1)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (country != null)
                              Text(
                                country!.phoneCode,
                                style: authScreensubTitleStyle(),
                              )
                            else
                              Text(countrys.phoneCode),
                            GestureDetector(
                                onTap: () {
                                  pickCountry();
                                },
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
                            suffixIcon: isButtonEnable
                                ? const Icon(
                                    Icons.done,
                                    color: Colors.green,
                                  )
                                : const SizedBox.shrink(),
                            fillColor: const Color.fromRGBO(242, 242, 242, 1),
                            filled: true,
                            hintText: 'Type here',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.transparent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.transparent)),
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 12, 0, 0)),
                        cursorWidth: 1.2,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (value) {
                          if (value.isEmpty) {
                            isButtonEnable = false;
                            setState(() {
                              errortext = 'Field is Required';
                            });
                          } else if (value.length < 10) {
                            isButtonEnable = false;

                            setState(() {
                              errortext = 'Please enter valid mobile number';
                            });
                          } else {
                            isButtonEnable = true;
                            setState(() {});
                          }
                        },
                        style: authScreensubTitleStyle().copyWith(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                // Text(
                //   errortext,
                //   style: const TextStyle(color: Colors.red),
                // ),
                const VerticalBox(height: 12),
                Center(
                  child: Text(
                    "Carrier charges may apply",
                    style: authScreensubTitleStyle(),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: isButtonEnable
                      ? () => sendPhoneNumber()
                      : () {
                          toastMessage(errortext, Colors.red, Colors.white);
                        },
                  child: Container(
                    height: 54,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(41),
                        color: isButtonEnable
                            ? const Color.fromRGBO(237, 84, 60, 1)
                            : const Color.fromARGB(139, 120, 6, 2)),
                    child: Center(
                        child: isLoad
                            ? const CircularProgressIndicator(
                                color: Colors.white)
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
      ),
    );
  }
}
