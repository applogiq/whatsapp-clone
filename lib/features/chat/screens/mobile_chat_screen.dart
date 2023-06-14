import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
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
                              )));
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(name),
                  ],
                ))
            : StreamBuilder<UserModel>(
                stream: ref.read(authControllerProvider).userDataById(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(profileImage),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name),
                          Text(
                            snapshot.data!.isOnline
                                ? 'online'
                                : snapshot.data!.lastSeen,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
        centerTitle: false,
        // actions: [
        //   // IconButton(
        //   //   onPressed: () {},
        //   //   icon: const Icon(Icons.video_call),
        //   // ),
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.call),
        //   ),
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.more_vert),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(receiverUserid: uid, isGroupChat: isGroupChat),
          ),
          BottomChatField(recieverUserId: uid, isGroupChat: isGroupChat),
        ],
      ),
    );
  }
}
