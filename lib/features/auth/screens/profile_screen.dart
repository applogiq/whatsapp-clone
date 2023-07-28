import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/screens/about_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/edit_profile_picture_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/login_screen.dart';
import 'package:whatsapp_ui/features/interner_connectivity/screen/no_internet_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? image;
  void signOut(BuildContext ctx, WidgetRef ref) {
    ref.read(authControllerProvider).logout(ctx);
  }

  selectImage() async {
    image = await pickImageFromGallery(context);
    if (image != null) {
      return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditprofilePicture(
                    isGroupprofile: false,
                    editImage: image!,
                  )));
    } else {
      // User canceled the image selection
      return null;
    }
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final internetStatus = ref.watch(internetConnectionStatusProvider);
    return internetStatus ==
            const AsyncValue.data(InternetConnectionStatus.disconnected)
        ? const NoInternetScreen()
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(auth.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              // var data = snapshot.data as DocumentSnapshot;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Loader(); // Return an empty widget or show an error message
              }

              var data =
                  snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
              return Scaffold(
                appBar: AppBar(
                  // backgroundColor: appBarColor,
                  title: InkWell(
                      onTap: () {},
                      child: Text(
                        "Profile",
                        style: authScreenheadingStyle(),
                      )),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: Image(
                                  image: CachedNetworkImageProvider(
                                      data['profilePic']),
                                  fit: BoxFit.fill,
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      isLoading = false;
                                      return child;
                                    } else {
                                      isLoading = true;
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                ).image,
                                radius: 80,
                              ),
                              Positioned(
                                child: InkWell(
                                  onTap: selectImage,
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Center(
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Name",
                          style:
                              authScreenheadingStyle().copyWith(fontSize: 18),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(data['name'],
                              style: authScreensubTitleStyle()
                                  .copyWith(fontSize: 20)),
                        ),
                        const VerticalBox(height: 15),
                        Text("Mobile Number",
                            style: authScreenheadingStyle()
                                .copyWith(fontSize: 18)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            data['phoneNumber'],
                            style: authScreensubTitleStyle()
                                .copyWith(fontSize: 18),
                          ),
                        ),
                        const VerticalBox(height: 15),
                        Text("About",
                            style: authScreenheadingStyle()
                                .copyWith(fontSize: 18)),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AboutScreen()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  data['aboutStatus'],
                                  style: authScreensubTitleStyle().copyWith(
                                      fontSize: 18,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              const Icon(Icons.edit)
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 70,
                        ),
                        InkWell(
                          onTap: () {
                            signOut(context, ref);
                          },
                          child: Container(
                            height: 50,
                            width: double.maxFinite,
                            // color: const Color.fromRGBO(255, 255, 255, 0.1),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(41),
                                color: const Color.fromRGBO(237, 84, 60, 1)),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Center(
                                child: Text(
                                  "Log Out",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
  }
}
