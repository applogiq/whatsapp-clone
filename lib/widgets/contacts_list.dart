import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_ui/model/chat_contact.dart';
import 'package:whatsapp_ui/model/group.dart' as model;

class ContactsList extends ConsumerWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseFirestore firestore;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<model.Group>>(
                stream: ref.watch(chatControllerProvider).chatGroups(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var groupData = snapshot.data![index];

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MobileChatScreen(
                                            memberIdList: groupData.membersUid,
                                            memberId: index,
                                            members: groupData.membersUid.length
                                                .toString(),
                                            isGroupChat: true,
                                            name: groupData.name,
                                            uid: groupData.groupId,
                                            profileImage: groupData.groupPic,
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  groupData.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    groupData.lastMessage,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    groupData.groupPic,
                                  ),
                                  radius: 30,
                                ),
                                trailing: Text(
                                  DateFormat.Hm().format(groupData.timeSent),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(color: dividerColor, indent: 85),
                        ],
                      );
                    },
                  );
                }),
            StreamBuilder<List<ChatContact>>(
                stream: ref.watch(chatControllerProvider).chatContact(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatContactData = snapshot.data![index];

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MobileChatScreen(
                                            isGroupChat: false,
                                            name: chatContactData.name,
                                            uid: chatContactData.contactId,
                                            profileImage:
                                                chatContactData.profilePic,
                                          )));
                              // Navigator.pushNamed(
                              //   context,
                              //   MobileChatScreen.routeName,
                              //   arguments: {
                              //     'name': chatContactData.name,
                              //     'uid': chatContactData.contactId,
                              //     'isGroupChat': true,
                              //     // 'profilePic': chatContactData.profilePic,
                              //   },
                              // );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  chatContactData.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    chatContactData.lastMessage,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    chatContactData.profilePic,
                                  ),
                                  radius: 30,
                                ),
                                trailing: Text(
                                  DateFormat.Hm()
                                      .format(chatContactData.timeSent),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),

                                // StreamBuilder(
                                //     stream: ref
                                //         .read(chatControllerProvider)
                                //         .chatStream(
                                //             chatContactData.contactId),
                                //     builder: (context, snapshot) {
                                //       final message = snapshot.data;
                                //       final messages = snapshot.data![index];
                                //       return const CircleAvatar(
                                //         radius: 10,
                                //         backgroundColor: Colors.blue,
                                //       );
                                //     })

                                // StreamBuilder(
                                // stream: FirebaseFirestore.instance
                                //     .collection("users")
                                //     .doc(FirebaseAuth
                                //         .instance.currentUser!.uid)
                                //     .collection("chats")
                                //     .doc(chatContactData.contactId)
                                //     .collection("messages")
                                //     .snapshots(),
                                // builder: (context, snapshot) {
                                //   final data =
                                //       snapshot.data as DocumentSnapshot;
                                //   print(
                                //       "12345 ${FirebaseAuth.instance.currentUser!.uid}");
                                //   print(
                                //       "123${chatContactData.contactId}");

                                //   // final message = data![index];
                                //   if (snapshot.connectionState ==
                                //       ConnectionState.waiting) {
                                //     return const Loader();
                                //   }
                                //   return const Text("xdxxx");
                                // }),

                                //   ],
                                // ),
                              ),
                            ),
                          ),
                          const Divider(color: dividerColor, indent: 85),
                        ],
                      );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
