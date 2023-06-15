import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/screens/profile_screen.dart';
import 'package:whatsapp_ui/features/group/screens/select_group_contacts.dart';
import 'package:whatsapp_ui/features/select_contact/screens/select_contacts_screens.dart';
import 'package:whatsapp_ui/screens/state_chageNotifier.dart';
import 'package:whatsapp_ui/widgets/contacts_list.dart';
import 'package:whatsapp_ui/widgets/custom_color_container.dart';

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
    ref.read(authControllerProvider).setuserState(true);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  updateLastSeen() {
    final DateTime now = DateTime.now();
    String formattedDate = DateFormat.yMMMMd().format(now);
    String formattedTime = DateFormat.jm().format(now);
    String period = DateFormat('a').format(now);
    String result = 'Last seen $formattedDate $formattedTime ';

    return result;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setuserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setuserState(false);
        ref.read(authControllerProvider).setLastSeenData(updateLastSeen());

        // updateLastSeen();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var todos = ref.watch(totoProvider).isShow;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        title: Text('Applogiq', style: authScreenheadingStyle()),
        actions: [
          SizedBox(
            height: 25,
            width: 25,
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
      body: const ContactsList(),
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
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(data['profilePic']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
