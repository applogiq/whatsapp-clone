import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/chat/screens/individual_chat_profile.dart';
import 'package:whatsapp_ui/features/chat/widgets/bottom_chat_field.dart';
import 'package:whatsapp_ui/features/group/screens/group_contacts.dart';
import 'package:whatsapp_ui/model/user_model.dart';
import 'package:whatsapp_ui/features/chat/widgets/chat_list.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profileImage;
  final String members;
  final int? memberId;
  final List? memberIdList;
  const MobileChatScreen({
    Key? key,
    this.memberIdList,
    this.members = "",
    this.memberId,
    required this.isGroupChat,
    required this.name,
    required this.uid,
    required this.profileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      appBar: AppBar(
        // elevation: 10,
        shadowColor: const Color.fromRGBO(5, 31, 50, 0.06),
        // backgroundColor: appBarColor,
        title: isGroupChat
            ? InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupContactsScreens(
                        members: members,
                        profilePic: profileImage,
                        name: name,
                        membersId: memberId!,
                        memberList: memberIdList!,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(profileImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style:
                                authScreenheadingStyle().copyWith(fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // StreamBuilder<List<model.Group>>(
                          //   stream:
                          //       ref.watch(chatControllerProvider).chatGroups(),
                          //   builder: (context, snapshot) {
                          //     if (snapshot.connectionState ==
                          //         ConnectionState.waiting) {
                          //       return const Loader();

                          //     } else if (!snapshot.hasData ||
                          //         snapshot.data == null) {
                          //       return const Loader(); // Return an empty widget or show an error message
                          //     } else if (snapshot.hasData) {
                          //       var groupData = snapshot.data![memberId!];
                          //       var membersUid = groupData.membersUid;

                          //       List<Future<String>> memberNames = membersUid
                          //           .map((memberUid) => fireStore
                          //               .collection('users')
                          //               .doc(memberUid)
                          //               .get()
                          //               .then((snapshot) =>
                          //                   snapshot.data()!['name'] as String))
                          //           .toList();

                          //       return FutureBuilder<List<String>>(
                          //         future: Future.wait<String>(memberNames),
                          //         builder: (context, snapshot) {
                          //           if (snapshot.connectionState ==
                          //               ConnectionState.waiting) {
                          //             return const Loader();
                          //           } else if (snapshot.hasData) {
                          //             var names = snapshot.data!;

                          //             if (names.isNotEmpty) {
                          //               if (names.length == 1) {
                          //                 return Text(
                          //                   names[0],
                          //                   overflow: TextOverflow.ellipsis,
                          //                 );
                          //               } else if (names.length > 1) {
                          //                 return Text(
                          //                   "You, ${names.sublist(1).join(", ")}${names.length > 1 ? ",..." : ""}",
                          //                   overflow: TextOverflow.ellipsis,
                          //                   style: authScreensubTitleStyle(),
                          //                 );
                          //               } else {
                          //                 return const SizedBox();
                          //               }
                          //             } else {
                          //               return const SizedBox();
                          //             }
                          //           } else if (snapshot.hasError) {
                          //             return const Text("Error occurred");
                          //           } else {
                          //             return const CircularProgressIndicator();
                          //           }
                          //         },
                          //       );
                          //     } else if (snapshot.hasError) {
                          //       return const Center(
                          //         child: Text("Error occurred"),
                          //       );
                          //     } else {
                          //       return const Center(
                          //         child: CircularProgressIndicator(),
                          //       );
                          //     }
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : StreamBuilder<UserModel>(
                stream: ref.read(authControllerProvider).userDataById(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IndividualChatProfileScreen(
                                    userId: uid,
                                  )));
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(profileImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: authScreenheadingStyle()
                                  .copyWith(fontSize: 20),
                            ),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor: snapshot.data!.isOnline
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const HorizontalBox(width: 5),
                                Text(
                                  snapshot.data!.isOnline
                                      ? 'online'
                                      : snapshot.data!.lastSeen,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromRGBO(118, 112, 109, 1)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(receiverUserid: uid, isGroupChat: isGroupChat),
          ),
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: BottomChatField(
                  recieverUserId: uid, isGroupChat: isGroupChat)),
        ],
      ),
    );
  }
}
