import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/custom_button.dart';
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

  bool isLoading = false; // Add a boolean variable to track the loading state

  void sendPhoneNumber() {
    print("123");
    setState(() {
      isLoading = true; // Set isLoading to true to display the loader
    });
    print(isLoading);

    String phoneNumber = phonenumberController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      log(123);
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      showSnackBar(context: context, content: 'Fill out all the fields');
    }
    setState(() {
      isLoading = false; // Set isLoading to false to hide the loader
    });
    print(isLoading);
    print("213");
  }

// void sendPhoneNumber() async {
//   setState(() {
//     isLoading = true; // Set isLoading to true to display the loader
//   });

//   String phoneNumber = phonenumberController.text.trim();
//   if (country != null && phoneNumber.isNotEmpty) {
//     log(123);
//     await ref
//         .read(authControllerProvider)
//         .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
//   } else {
//     showSnackBar(context: context, content: 'Fill out all the fields');
//   }

//   setState(() {
//     isLoading = false; // Set isLoading to false to hide the loader
//   });
// }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Verify your phone number"),
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                "Applogiq will send an SMS message to verify your phone number. Enter your country code and phone number",
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
                onPressed: pickCountry, child: const Text("Pick country")),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                if (country != null) Text("+${country!.phoneCode}"),
                const SizedBox(
                  width: 10,
                ),
                // SizedBox(
                //   width: size.width * 0.7,
                // ),
                SizedBox(
                  width: size.width * 0.7,
                  child: TextField(
                    controller: phonenumberController,
                    decoration: const InputDecoration(hintText: 'Phone Number'),
                  ),
                )
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 50,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(text: "Go Next", onPressed: sendPhoneNumber),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text("Carrier SMS charges may apply")
          ],
        ),
      ),
      // bottomNavigationBar: SizedBox(
      //   height: 80,
      //   child: Column(
      //     children: [
      //       CustomButton(text: "Go Next", onPressed: sendPhoneNumber),
      //       const Text("Carrier SMS charges may apply")
      //     ],
      //   ),
      // ),
    );
  }
}
