import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_ui/model/chat_contact.dart';
import 'package:whatsapp_ui/model/group.dart' as model;
import 'package:whatsapp_ui/model/message_model.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

class ContactsList extends ConsumerStatefulWidget {
  const ContactsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactsListState();
}

class _ContactsListState extends ConsumerState<ContactsList> {
  FirebaseFirestore? firestore;
  Message? _message;
  String? time;
  String? changeTime;
  void timeFunction(DateTime streamingtime) {
    DateTime timeSent = streamingtime;
    DateTime currentDate = DateTime.now();
    DateTime yesterdayDate = currentDate.subtract(const Duration(days: 1));

    if (timeSent.year == currentDate.year &&
        timeSent.month == currentDate.month &&
        timeSent.day == currentDate.day) {
      time = DateFormat('h:mm a').format(timeSent);
      print("123$time");
    } else if (timeSent.year == yesterdayDate.year &&
        timeSent.month == yesterdayDate.month &&
        timeSent.day == yesterdayDate.day) {
      time = 'Yesterday';
      print('Yesterday');
    } else {
      time = DateFormat('MMM d, h:mm a').format(timeSent);
      print("321$time");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SearchSection(),
        Expanded(
          child: ListView(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<List<model.Group>>(
                      stream: ref.watch(chatControllerProvider).chatGroups(),
                      builder: (context, groupSnapshot) {
                        if (groupSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Loader();
                        }
                        final List<model.Group> groups =
                            groupSnapshot.data ?? [];

                        return StreamBuilder<List<ChatContact>>(
                          stream:
                              ref.watch(chatControllerProvider).chatContact(),
                          builder: (context, contactSnapshot) {
                            if (contactSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Loader();
                            }
                            final List<ChatContact> contacts =
                                contactSnapshot.data ?? [];

                            final List<dynamic> combinedData = [
                              ...groups,
                              ...contacts
                            ];

                            combinedData.sort((a, b) {
                              final DateTime aTime =
                                  a is model.Group ? a.timeSent : a.timeSent;
                              final DateTime bTime =
                                  b is model.Group ? b.timeSent : b.timeSent;
                              return bTime.compareTo(aTime);
                            });

                            return ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: combinedData.length,
                              itemBuilder: (context, index) {
                                final dynamic data = combinedData[index];
                                timeFunction(data.timeSent);
                                if (data is model.Group) {
                                  // Display group data
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MobileChatScreen(
                                                memberIdList: data.membersUid,
                                                memberId: index,
                                                members: data.membersUid.length
                                                    .toString(),
                                                isGroupChat: true,
                                                name: data.name,
                                                uid: data.groupId,
                                                profileImage: data.groupPic,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: ListTile(
                                            title: Text(
                                              data.name,
                                              style: authScreenheadingStyle()
                                                  .copyWith(fontSize: 15),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 6.0),
                                              child: Text(
                                                data.lastMessage,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            leading: Container(
                                              height: 44,
                                              width: 44,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      data.groupPic),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            trailing: Text(
                                              time!,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                      ),
                                    ],
                                  );
                                } else if (data is ChatContact) {
                                  // Display chat contact data
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MobileChatScreen(
                                                isGroupChat: false,
                                                name: data.name,
                                                uid: data.contactId,
                                                profileImage: data.profilePic,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: ListTile(
                                            title: Text(
                                              data.name,
                                              style: authScreenheadingStyle()
                                                  .copyWith(fontSize: 15),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 6.0),
                                              child: StreamBuilder<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection("users")
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .collection("chats")
                                                    .doc(data.contactId)
                                                    .collection("messages")
                                                    .orderBy('timeSent',
                                                        descending: true)
                                                    .limit(1)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    var messageData =
                                                        snapshot.data!.docs;

                                                    final List<Message>
                                                        messages = messageData
                                                            .map((e) =>
                                                                Message.fromMap(
                                                                    e.data()))
                                                            .toList();

                                                    if (messages.isNotEmpty) {
                                                      _message = messages[0];
                                                    }

                                                    if (FirebaseAuth.instance
                                                            .currentUser!.uid ==
                                                        _message?.senderId) {
                                                      return Text(
                                                        data.lastMessage,
                                                        style: const TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: 15,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    } else if (_message ==
                                                        null) {
                                                      return const Text(
                                                          "No Message yet....");
                                                    } else if (_message!
                                                        .isSeen) {
                                                      return Text(
                                                        data.lastMessage,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    } else {
                                                      return Text(
                                                        data.lastMessage,
                                                        style: const TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: 15,
                                                          color: Color.fromRGBO(
                                                              237, 84, 60, 1),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    return Text(
                                                      data.lastMessage,
                                                      style: const TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontSize: 15,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            leading: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      data.profilePic),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            trailing: StreamBuilder<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser!.uid)
                                                  .collection("chats")
                                                  .doc(data.contactId)
                                                  .collection("messages")
                                                  .orderBy('timeSent',
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  var messageData =
                                                      snapshot.data!.docs;

                                                  final List<Message> messages =
                                                      messageData
                                                          .map((e) =>
                                                              Message.fromMap(
                                                                  e.data()))
                                                          .toList();

                                                  DateTime timeSent =
                                                      messages[0].timeSent;
                                                  DateTime currentDate =
                                                      DateTime.now();
                                                  DateTime yesterdayDate =
                                                      currentDate.subtract(
                                                          const Duration(
                                                              days: 1));

                                                  if (timeSent.year ==
                                                          currentDate.year &&
                                                      timeSent.month ==
                                                          currentDate.month &&
                                                      timeSent.day ==
                                                          currentDate.day) {
                                                    changeTime =
                                                        DateFormat('h:mm a')
                                                            .format(timeSent);
                                                    // print("123$time");
                                                  } else if (timeSent.year ==
                                                          yesterdayDate.year &&
                                                      timeSent.month ==
                                                          yesterdayDate.month &&
                                                      timeSent.day ==
                                                          yesterdayDate.day) {
                                                    changeTime = 'Yesterday';
                                                    // print('Yesterday');
                                                  } else {
                                                    changeTime = DateFormat(
                                                            'MMM d, h:mm a')
                                                        .format(timeSent);
                                                    // print("321$time");
                                                  }

                                                  if (messages.isNotEmpty) {
                                                    _message = messages[0];
                                                  }

                                                  if (FirebaseAuth.instance
                                                          .currentUser!.uid ==
                                                      _message?.senderId) {
                                                    return Text(
                                                      changeTime!,
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                    );
                                                  } else if (_message == null) {
                                                    return const SizedBox
                                                        .shrink();
                                                  } else if (_message!.isSeen) {
                                                    return Text(
                                                      changeTime!,
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                    );
                                                  } else {
                                                    return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Text(
                                                          changeTime!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        StreamBuilder<
                                                                QuerySnapshot<
                                                                    Map<String,
                                                                        dynamic>>>(
                                                            stream: FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "users")
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                                .collection(
                                                                    "chats")
                                                                .doc(data
                                                                    .contactId)
                                                                .collection(
                                                                    "messages")
                                                                .snapshots(),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                int trueMessagesCount =
                                                                    0;
                                                                final messages =
                                                                    snapshot
                                                                        .data!
                                                                        .docs;
                                                                // Count the number of messages with isSeen = true
                                                                for (final message
                                                                    in messages) {
                                                                  final isSeen =
                                                                      message.data()[
                                                                          'isSeen'];
                                                                  if (isSeen ==
                                                                      false) {
                                                                    trueMessagesCount++;
                                                                  }
                                                                }
                                                                return CircleAvatar(
                                                                  radius: 10,
                                                                  backgroundColor:
                                                                      const Color
                                                                              .fromRGBO(
                                                                          237,
                                                                          84,
                                                                          60,
                                                                          1),
                                                                  child: Text(
                                                                    trueMessagesCount
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                );
                                                              } else {
                                                                return const CircularProgressIndicator();
                                                              }
                                                            }),
                                                      ],
                                                    );
                                                  }
                                                } else {
                                                  return Text(
                                                    changeTime!,
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Divider(
                                          color: Color.fromRGBO(0, 0, 0, 0.1),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// class ContactsList extends ConsumerWidget {
//   const ContactsList({Key? key}) : super(key: key);


// }
