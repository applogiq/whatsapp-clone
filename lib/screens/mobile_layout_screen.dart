import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/alert_packages/show_dialog_package.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/screens/profile_screen.dart';
import 'package:whatsapp_ui/features/group/screens/select_group_contacts.dart';
import 'package:whatsapp_ui/features/select_contact/screens/select_contacts_screens.dart';
import 'package:whatsapp_ui/widgets/contacts_list.dart';
import 'package:whatsapp_ui/widgets/custom_color_container.dart';

import '../features/interner_connectivity/controller/internet_connection_controller.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    print("ram");
    // ref.watch(authControllerProvider).getUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access providers or use their values here
      ref.watch(authControllerProvider).getUserData();
      ref.read(authControllerProvider).setuserState(true);
    });
//  await FirebaseFirestore.instance
//         .collection("users")
//         .doc(widget.recieverUserId)
//         .update({'isTyping': false});
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  // updateLastSeen() {
  //   final DateTime now = DateTime.now();
  //   String formattedDate = DateFormat.yMMMMd().format(now);
  //   String formattedTime = DateFormat.jm().format(now);
  //   String period = DateFormat('a').format(now);
  //   String result = 'Last seen $formattedDate $formattedTime ';

  //   return result;
  // }

  String updateLastSeen() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    if (today.difference(now).inDays == 0) {
      // Today
      String formattedTime = DateFormat.jm().format(now);
      String period = DateFormat('a').format(now);
      return 'Last seen today $formattedTime';
    } else if (yesterday.difference(now).inDays == 0) {
      // Yesterday
      String formattedTime = DateFormat.jm().format(now);
      String period = DateFormat('a').format(now);
      return 'Last seen yesterday $formattedTime';
    } else {
      // Other days
      String formattedDate = DateFormat.yMMMMd().format(now);
      String formattedTime = DateFormat.jm().format(now);
      String period = DateFormat('a').format(now);
      return 'Last seen $formattedDate $formattedTime';
    }
  }

  showAlertDialog(BuildContext context) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: false,

      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const SizedBox.shrink(),
          content: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Text(
              "Do you want to Exit app?",
              style: authScreenheadingStyle().copyWith(fontSize: 18),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(255, 187, 179, 179),
                          // offset: Offset(
                          //   20,
                          //   20,
                          // ),
                          blurRadius: 25),
                    ],
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromRGBO(255, 255, 255, 1)),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("Cancel"),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                SystemNavigator.pop();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromRGBO(254, 86, 49, 1)),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: getProportionateScreenWidth(5),
            )
          ],
        );
      },

      animationType: DialogTransitionType.size,

      curve: Curves.fastOutSlowIn,

// duration: const Duration(seconds: 1),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("close.............1");

    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setuserState(true);
        print("close.............2");

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setuserState(false);
        ref.read(authControllerProvider).setLastSeenData(updateLastSeen());
        print("close.............");

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final internetConnectionStatus =
        ref.watch(internetConnectionStatusProvider);

    return WillPopScope(
      onWillPop: () async {
        showAlertDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          title: InkWell(
            onTap: () async {
              await ref.watch(authControllerProvider).getUserData();
            },
            child: Image.asset(
              "assets/logo.png",
              width: 80,
            ),
          ),
          actions: [
            SizedBox(
              height: 20,
              width: 20,
              child: InkWell(
                onTap: () {
                  // Navigator.pushNamed(context, CreateGroupScreen.routeName);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SelectGroupContactsScreen()));
                },
                child: Image.asset(
                  'assets/create_group.png',
                ),
              ),
            ),
            const HorizontalBox(width: 15),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()));
                  },
                  child: const ProfilePic()),
            )
          ],
        ),
        body: Stack(
          children: [
            const ContactsList(),
            internetConnectionStatus ==
                    const AsyncValue.data(InternetConnectionStatus.disconnected)
                ? Positioned(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      color: const Color.fromRGBO(5, 31, 50, 0.5),
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, SelectContactsScreen.routeName);
          },
          backgroundColor: const Color.fromRGBO(237, 84, 60, 1),
          child: const Icon(
            Iconsax.message_text5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ProfilePic extends ConsumerWidget {
  const ProfilePic({Key? key}) : super(key: key);

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
            return const SizedBox(); // Return an empty widget or show an error message
          }

          var data = snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 3,
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(data['profilePic']),
              )
            ],
          );
        });
  }
}

class SearchSection extends StatelessWidget {
  const SearchSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchTextWidget(
        textEditingController: null,
        isReadOnly: true,
        onTap: () {},
        hint: "Search chat",
      ),
    );
  }
}

class SearchTextWidget extends StatelessWidget {
  const SearchTextWidget({
    Key? key,
    required this.hint,
    this.isReadOnly = false,
    required this.onTap,
    required this.textEditingController,
    this.onChange,
  }) : super(key: key);
  final String hint;
  final bool isReadOnly;

  final VoidCallback onTap;
  final ValueSetter<String>? onChange;

  final TextEditingController? textEditingController;

  // late TextEditingController _controller;
  @override
  Widget build(BuildContext context) {
    return CustomColorContainer(
      left: 1,
      verticalPadding: 2,
      bgColor: const Color.fromRGBO(242, 242, 242, 1),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints.expand(height: 40, width: double.maxFinite),
        child: TextField(
          autofocus: false,
          controller: textEditingController,
          onTap: onTap,
          readOnly: isReadOnly,
          onChanged: onChange,
          onSubmitted: onChange,
          cursorColor: Colors.white,
          decoration: InputDecoration(
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  "assets/search.png",
                  height: 16,
                  width: 16,
                  color: const Color.fromRGBO(100, 115, 127, 1),
                ),
              ),
              border: InputBorder.none,
              hintStyle: const TextStyle(fontSize: 15),
              hintText: hint),
        ),
      ),
    );
  }
}
