import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/screens/about_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = FirebaseAuth.instance;

    return StreamBuilder(
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

          var data = snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
          return ProfileWidget(user: data);
        });
  }
}

class ProfileWidget extends ConsumerWidget {
  final DocumentSnapshot<Object?> user;
  const ProfileWidget({super.key, required this.user});

  void signOut(BuildContext ctx, WidgetRef ref) {
    ref.read(authControllerProvider).logout(ctx);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: appBarColor,
        title: InkWell(
            onTap: () {
              print(FirebaseAuth.instance.currentUser!.uid);
            },
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
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user['profilePic']),
                  radius: 80,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: Container(
              //     height: 50,

              //     width: 150,
              //     // color: const Color.fromRGBO(255, 255, 255, 0.1),
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(41),
              //         color: const Color.fromRGBO(237, 84, 60, 1)),
              //     child: const Padding(
              //       padding: EdgeInsets.only(left: 10),
              //       child: Center(
              //         child: Text(
              //           "Edit profile",
              //           style: TextStyle(fontSize: 22, color: Colors.white),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              const SizedBox(
                height: 20,
              ),
              Text(
                "Name",
                style: authScreenheadingStyle().copyWith(fontSize: 18),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(user['name'],
                    style: authScreensubTitleStyle().copyWith(fontSize: 20)),
              ),
              const VerticalBox(height: 15),
              Text("Mobile Number",
                  style: authScreenheadingStyle().copyWith(fontSize: 18)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user['phoneNumber'],
                  style: authScreensubTitleStyle().copyWith(fontSize: 18),
                ),
              ),
              const VerticalBox(height: 15),

              Text("About",
                  style: authScreenheadingStyle().copyWith(fontSize: 18)),
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
                        user['aboutStatus'],
                        style: authScreensubTitleStyle().copyWith(
                            fontSize: 18, overflow: TextOverflow.ellipsis),
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
                        style: TextStyle(fontSize: 22, color: Colors.white),
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
  }
}


// d3zwXHhttDaUEg1dwUXigKHXZuv1