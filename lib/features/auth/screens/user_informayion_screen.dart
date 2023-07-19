import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/alert_widget.dart';

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
  String errorText = "";

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
      setState(() {
        isLoading = false;
      });
    });
    // Restart.restartApp();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        showAlertDialog(context);
        FocusScope.of(context).unfocus();

        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const VerticalBox(height: 40),
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: InkWell(
                //       onTap: () {
                //         Navigator.pop(context);
                //       },
                //       child: const Icon(Icons.arrow_back_outlined)),
                // ),
                const VerticalBox(height: 28),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Setup your profile",
                    style: authScreenheadingStyle(),
                  ),
                ),
                const VerticalBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Please provide your name and an optional\nprofile picture",
                    style: authScreensubTitleStyle(),
                  ),
                ),
                const VerticalBox(height: 24),
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
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
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(
                          Icons.add_a_photo_outlined,
                          color: Color.fromRGBO(214, 214, 214, 1),
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                // const VerticalBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Enter your name",
                    style: textFieldHeadingStyle(),
                  ),
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
                        contentPadding:
                            const EdgeInsets.fromLTRB(10, 12, 0, 0)),
                    cursorWidth: 1.2,
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        isButtonEnable = false;
                        setState(() {
                          errorText = 'Field is Required';
                        });
                      } else {
                        isButtonEnable = true;
                        setState(() {
                          errorText = '';
                        });
                      }
                    },
                    style: authScreensubTitleStyle().copyWith(fontSize: 15),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    errorText,
                    style:
                        authScreensubTitleStyle().copyWith(color: buttonColor),
                  ),
                ),
                const VerticalBox(height: 100),
                // const Spacer(),
                InkWell(
                  onTap: isButtonEnable ? () => storeUserData() : () {},
                  child: Container(
                    height: 54,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(41),
                        color: isButtonEnable
                            ? const Color.fromRGBO(237, 84, 60, 1)
                            : const Color.fromARGB(139, 120, 6, 2)),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text('Create account',
                              style: GoogleFonts.manrope(
                                textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              )),
                    ),
                  ),
                ),
                const VerticalBox(height: 5)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//https://img.jagranjosh.com/imported/images/E/GK/sachin-records.webp