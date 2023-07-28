import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/shimmer/shimmer.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/model/message_model.dart';
import 'package:whatsapp_ui/features/chat/widgets/my_message_card.dart';
import 'package:whatsapp_ui/features/chat/widgets/sender_message_card.dart';

import '../../interner_connectivity/controller/internet_connection_controller.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserid;
  final bool isGroupChat;

  const ChatList({
    Key? key,
    required this.receiverUserid,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  var datastream;
  @override
  void initState() {
    datastream = widget.isGroupChat
        ? ref
            .read(chatControllerProvider)
            .groupChatStream(widget.receiverUserid)
        : ref.read(chatControllerProvider).chatStream(widget.receiverUserid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final internetConnectionStatus =
        ref.watch(internetConnectionStatusProvider);
    return StreamBuilder<List<Message>>(
      stream: datastream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return tripInfoShimmer(context);
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageController.jumpTo(messageController.position.maxScrollExtent);
        });
        final messages = snapshot.data;

        if (messages == null || messages.isEmpty) {
          return const Center(
            child: Text('No messages yet.'),
          );
        }

        return ListView.builder(
          controller: messageController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index];
            // messageData.
            final messageStartDate = messageData.timeSent;
            final previousMessageIndex = index - 1;

            String conversationStartLabel = '';

            // Check if it's the first message or if the start date is different from the previous message
            if (index == 0 ||
                (previousMessageIndex >= 0 &&
                    messages[previousMessageIndex].timeSent.day !=
                        messageStartDate.day)) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final yesterDay = today.subtract(const Duration(days: 1));

              if (messageStartDate.year == today.year &&
                  messageStartDate.month == today.month &&
                  messageStartDate.day == today.day) {
                conversationStartLabel = 'Today';
              } else if (messageStartDate.year == yesterDay.year &&
                  messageStartDate.month == yesterDay.month &&
                  messageStartDate.day == yesterDay.day) {
                conversationStartLabel = 'Yesterday';
              } else {
                conversationStartLabel =
                    DateFormat('MMMM dd, yyyy').format(messageStartDate);
              }
            }

            var timeSent = DateFormat('h:mm a').format(messageStartDate);

            // Render the conversation start label if it's a new day
            if (conversationStartLabel.isNotEmpty) {
              return Column(
                children: [
                  const VerticalBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Divider(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          height: 3,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 251, 249, 249),
                            borderRadius: BorderRadius.circular(12),
                            // // boxShadow: [
                            // //   BoxShadow(
                            // //     color: Colors.grey.withOpacity(0.5),
                            // //     spreadRadius: 2,
                            // //     blurRadius: 5,
                            // //     offset: const Offset(0, 3),
                            // //   ),
                            // // ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              conversationStartLabel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 0, 0, 0.3)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const VerticalBox(height: 10),

                  // Render the message card
                  _buildMessageCard(messageData, timeSent),
                ],
              );
            } else {
              // Render the message card without the conversation start label
              return _buildMessageCard(messageData, timeSent);
            }
          },
        );
      },
    );
  }

  Widget _buildMessageCard(Message messageData, String timeSent) {
    print(">>>>>>>>>>>>>>>>>>>11");

    if (widget.isGroupChat) {
      print("❤️${widget.receiverUserid}");
      print("❤️❤️${messageData.messageId}");
      print("❤️❤️${FirebaseAuth.instance.currentUser!.uid}");
      ref.read(chatControllerProvider).groupsetChatMessageSeen(
            context,
            widget.receiverUserid,
            messageData.messageId,
          );
    } else {
      if (!messageData.isSeen &&
          messageData.recieverid == FirebaseAuth.instance.currentUser!.uid) {
        print(">>>>>>>>>>>>>>>>>>>22");

        ref.read(chatControllerProvider).setChatMessageSeen(
              context,
              widget.receiverUserid,
              messageData.messageId,
            );
      }
    }
    if (messageData.senderId == FirebaseAuth.instance.currentUser!.uid) {
      return MyMessageCard(
        isGroupChat: widget.isGroupChat,
        message: messageData.text,
        date: timeSent,
        type: messageData.type,
        isSeen: messageData.isSeen, receiverId: widget.receiverUserid,
        messageId: messageData.messageId,

        // print(messageData.messageId);
      );
    }

    return widget.isGroupChat
        ? SenderMessageCard(
            messageId: messageData.messageId,
            receiverId: widget.receiverUserid,
            isGroupChat: true,
            nameWidget: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(messageData.senderId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('');
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text(
                      ''); // or display a message indicating no contacts
                }
                var data = snapshot.data!.data();
                if (data == null) {
                  return const Text(''); // or handle the case when data is null
                }
                return Text(
                  data['name'].toString(),
                  style: authScreensubTitleStyle().copyWith(
                    color: const Color.fromRGBO(236, 61, 23, 1),
                  ),
                );
              },
            ),
            message: messageData.text,
            date: timeSent,
            type: messageData.type,
          )
        : SenderMessageCard(
            messageId: messageData.messageId,
            receiverId: widget.receiverUserid,
            isGroupChat: false,
            nameWidget: const SizedBox.shrink(),
            message: messageData.text,
            date: timeSent,
            type: messageData.type,
          );
  }
}

deleteMessageList(String receiverUserId, String messageId) async {
  await FirebaseFirestore.instance
      .collection('chats')
      .doc(receiverUserId)
      .collection('messages')
      .doc(messageId)
      .delete();
}

Shimmer tripInfoShimmer(BuildContext context) {
  SizeConfig().init(context);
  return Shimmer.fromColors(
      child: ListView.builder(
        itemCount: 10,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    height: getProportionateScreenHeight(60),
                    width: getProportionateScreenWidth(120),
                  ),
                ),
                const VerticalBox(height: 16),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    height: getProportionateScreenHeight(60),
                    width: getProportionateScreenWidth(120),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!);
}
