import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-information';
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  File? image;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  bool isLoading = false;
  bool isButtonEnable = false;

  void storeUserData() async {
    String name = nameController.text.trim();
    setState(() {
      isLoading = true;
    });
    if (name.isNotEmpty) {
      ref.read(authControllerProvider).saveUserDataToFirebase(
            context,
            name,
            image,
          );
    } else {
      showSnackBar(context: context, content: 'Please Select Your Photo');
    }
    Future.delayed(const Duration(milliseconds: 2000), () {
      isLoading = false;
      setState(() {});
    });
    // Restart.restartApp();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VerticalBox(height: 40),
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_outlined)),
            const VerticalBox(height: 28),
            Text(
              "Setup your profile",
              style: authScreenheadingStyle(),
            ),
            const VerticalBox(height: 16),
            Text(
              "Please provide your name and an optional\nprofile picture",
              style: authScreensubTitleStyle(),
            ),
            const VerticalBox(height: 24),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                image == null
                    ? const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
                        ),
                        radius: 80,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(
                          image!,
                        ),
                        radius: 80,
                      ),
                Positioned(
                  child: Center(
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // const VerticalBox(height: 16),
            Text(
              "Enter your name",
              style: textFieldHeadingStyle(),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: size.width,
              child: TextField(
                textCapitalization: TextCapitalization.words,
                controller: nameController,
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
                    contentPadding: const EdgeInsets.fromLTRB(10, 12, 0, 0)),
                cursorWidth: 1.2,
                cursorColor: Colors.black,
                onChanged: (value) {
                  if (value.isEmpty) {
                    isButtonEnable = false;
                    setState(() {});
                  } else if (RegExp(r"\s").hasMatch(value)) {
                    isButtonEnable = false;
                    setState(() {});
                  } else {
                    isButtonEnable = true;
                    setState(() {});
                  }
                },
                style: authScreensubTitleStyle().copyWith(fontSize: 15),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: isButtonEnable ? () => storeUserData() : () {},
              child: Container(
                height: 54,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(41),
                    color: isButtonEnable
                        ? Colors.green
                        : const Color.fromRGBO(237, 84, 60, 1)),
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
            const VerticalBox(height: 5)
          ],
        ),
      ),
    );
  }
}

//https://img.jagranjosh.com/imported/images/E/GK/sachin-records.webp