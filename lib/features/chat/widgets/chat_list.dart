import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/model/message_model.dart';
import 'package:whatsapp_ui/features/chat/widgets/my_message_card.dart';
import 'package:whatsapp_ui/features/chat/widgets/sender_message_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: widget.isGroupChat
          ? ref
              .read(chatControllerProvider)
              .groupChatStream(widget.receiverUserid)
          : ref.read(chatControllerProvider).chatStream(widget.receiverUserid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
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

            var timeSent = DateFormat.Hm().format(messageStartDate);

            // Render the conversation start label if it's a new day
            if (conversationStartLabel.isNotEmpty) {
              return Column(
                children: [
                  Container(
                    color: Colors.blue,
                    child: Text(
                      conversationStartLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
    if (!messageData.isSeen &&
        messageData.recieverid == FirebaseAuth.instance.currentUser!.uid) {
      ref.read(chatControllerProvider).setChatMessageSeen(
            context,
            widget.receiverUserid,
            messageData.messageId,
          );
    }

    if (messageData.senderId == FirebaseAuth.instance.currentUser!.uid) {
      return MyMessageCard(
        message: messageData.text,
        date: timeSent,
        type: messageData.type,
        isSeen: messageData.isSeen,
      );
    }

    return widget.isGroupChat
        ? SenderMessageCard(
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
            nameWidget: const SizedBox.shrink(),
            message: messageData.text,
            date: timeSent,
            type: messageData.type,
          );
  }
}
