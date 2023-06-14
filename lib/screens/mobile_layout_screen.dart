import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/screens/profile_screen.dart';
import 'package:whatsapp_ui/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_ui/features/select_contact/screens/select_contacts_screens.dart';
import 'package:whatsapp_ui/screens/state_chageNotifier.dart';
import 'package:whatsapp_ui/widgets/contacts_list.dart';

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

    // print(" rsm$now");

    // final String lastSeen = formatDate(now);
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          centerTitle: false,
          title: const Text(
            'Applogiq',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(todos ? Icons.search : Icons.abc, color: Colors.grey),
              onPressed: () {
                ref.read(totoProvider).isShowButton();
              },
            ),
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text("Create Group"),
                        onTap: () => Future(
                          () => Navigator.pushNamed(
                              context, CreateGroupScreen.routeName),
                        ),
                      )
                    ]),
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
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            indicatorWeight: 4,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [
          ContactsList(),
          Center(
            child: Text("Status"),
          ),
          Center(
            child: Text("calls"),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, SelectContactsScreen.routeName);
          },
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.comment,
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
    return ref.watch(userdataProvider).when(
        data: (user) {
          if (user == null) {
            return const CircleAvatar(
              backgroundImage: AssetImage('assets/bg.png'),
            );
          } else {
            return CircleAvatar(backgroundImage: NetworkImage(user.profilePic));
          }
        },
        error: (error, trace) {
          return ErrorSccreen(error: error.toString());
        },
        loading: () => const Loader());
  }
}
