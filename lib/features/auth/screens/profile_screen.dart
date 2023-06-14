import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/model/user_model.dart';

import '../../../common/widgets/error.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userdataProvider).when(
        data: (user) {
          return ProfileWidget(
            user: user!,
          );
        },
        error: (error, trace) {
          return ErrorSccreen(error: error.toString());
        },
        loading: () => const Loader());
  }
}

class ProfileWidget extends ConsumerWidget {
  final UserModel user;
  const ProfileWidget({super.key, required this.user});

  void signOut(BuildContext ctx, WidgetRef ref) {
    ref.read(authControllerProvider).logout(ctx);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text("Profile"),
      ),
      body: Padding(
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
                backgroundImage: NetworkImage(user.profilePic),
                radius: 80,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 50,

                width: 150,
                // color: const Color.fromRGBO(255, 255, 255, 0.1),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueGrey),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Center(
                    child: Text(
                      "Edit profile",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Name",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              width: double.maxFinite,
              // color: const Color.fromRGBO(255, 255, 255, 0.1),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(255, 255, 255, 0.1)),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              "Mobile Number",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(255, 255, 255, 0.1)),
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.phoneNumber,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
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
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Center(
                    child: Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
