import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
            : ref
                .read(chatControllerProvider)
                .chatStream(widget.receiverUserid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          SchedulerBinding.instance.addPostFrameCallback((_) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          });
          final messages = snapshot.data;

          if (messages == null || messages.isEmpty) {
            return const Center(
              child: Text('No messages yet.'),
            );
          }
          final conversationStartDate = messages.first.timeSent;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterDay = today.subtract(const Duration(days: 1));
          String conversationStartLabel;
          final isToday = conversationStartDate.year == today.year &&
              conversationStartDate.month == today.month &&
              conversationStartDate.day == today.day;
          final isYesterday = conversationStartDate.year == yesterDay.year &&
              conversationStartDate.month == yesterDay.month &&
              conversationStartDate.day == yesterDay.day;

          if (isToday) {
            conversationStartLabel = 'Today';
          } else if (isYesterday) {
            conversationStartLabel = 'Yesterday';
          } else {
            conversationStartLabel =
                DateFormat('MMMM dd, yyyy').format(conversationStartDate);
          }
          final isTodayOrYesterday = isToday || isYesterday;

          return Column(
            children: [
              // if (isTodayOrYesterday)
              Container(
                // padding: const EdgeInsets.all(8.0),
                color: Colors.blue,
                child: Text(
                  conversationStartLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: messageController,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final messageData = snapshot.data![index];
                    var timeSent = DateFormat.Hm().format(messageData.timeSent);
                    if (!messageData.isSeen &&
                        messageData.recieverid ==
                            FirebaseAuth.instance.currentUser!.uid) {
                      ref.read(chatControllerProvider).setChatMessageSeen(
                          context,
                          widget.receiverUserid,
                          messageData.messageId);
                    }
                    if (messageData.senderId ==
                        FirebaseAuth.instance.currentUser!.uid) {
                      return MyMessageCard(
                          message: messageData.text,
                          date: timeSent,
                          type: messageData.type,
                          isSeen: messageData.isSeen);
                    }
                    return SenderMessageCard(
                      message: messageData.text,
                      date: timeSent,
                      type: messageData.type,
                    );
                  },
                ),
              ),
            ],
          );
        });
  }
}

// class ChatList extends ConsumerWidget {
 

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
   
//   }
// }
