import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/chat/repositories/chat_repository.dart';
import 'package:whatsapp_ui/model/chat_contact.dart';
import 'package:whatsapp_ui/model/message_model.dart';
import 'package:whatsapp_ui/model/group.dart' as model;
import 'package:whatsapp_ui/model/user_model.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({required this.chatRepository, required this.ref});
  Stream<List<ChatContact>> chatContact() {
    return chatRepository.getContacts();
  }

  Stream<List<model.Group>> chatGroups() {
    return chatRepository.getChatGroups();
  }

  Stream<List<Message>> chatStream(String receiverUserId) {
    return chatRepository.getChatStream(receiverUserId);
  }

  Stream<List<Message>> groupChatStream(String groupId) {
    return chatRepository.getgroupStream(groupId);
  }

  Future<void> sentTextMessage(
    List memberid,
    BuildContext context,
    String text,
    String receiverUserId,
    bool isGroupChat,
  ) async {
    UserModel? user;

    Future<UserModel?> getCurrentUserData() async {
      var userdata = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (userdata.data() != null) {
        try {
          user = UserModel.fromMap(userdata.data()!);
        } catch (e) {
          showSnackBar(context: context, content: e.toString());
        }
      }
      return user;
    }

    user = await getCurrentUserData();

    if (user != null) {
      try {
        await chatRepository.sentTextMessage(
          groupMemberId: memberid,
          isGroupChat: isGroupChat,
          context: context,
          text: text,
          receiverUserId: receiverUserId,
          sendUser: user!,
        );
      } catch (e) {
        showSnackBar(context: context, content: e.toString());
      }
    } else {}
  }

  Future<void> sentFileMessage(BuildContext context, File file, List memberid,
      String receiverUserId, MessageEnum messageEnum, bool isGroupChat) async {
    UserModel? user;

    Future<UserModel?> getCurrentUserData() async {
      var userdata = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (userdata.data() != null) {
        try {
          user = UserModel.fromMap(userdata.data()!);
        } catch (e) {
          showSnackBar(context: context, content: e.toString());
        }
      }
      return user;
    }

    user = await getCurrentUserData();

    if (user != null) {
      try {
        chatRepository.sendFileMessage(
            groupMemberId: memberid,
            isGroupChat: isGroupChat,
            context: context,
            file: file,
            receiverUserId: receiverUserId,
            senderUserData: user!,
            messageEnum: messageEnum,
            ref: ref);
      } catch (e) {
        showSnackBar(context: context, content: e.toString());
      }
    } else {}
  }

  void setChatMessageSeen(
      BuildContext context, String receiverUserid, String messageId) {
    chatRepository.setMessageSeen(context, receiverUserid, messageId);
  }

  void groupsetChatMessageSeen(
      BuildContext context, String receiverUserid, String messageId) {
    chatRepository.groupSetMessageSeen(context, receiverUserid, messageId);
  }

  Stream<List<Message>> getLastMessage(String receiverUserid) {
    return chatRepository.getlastMessage(receiverUserid);
  }
}
