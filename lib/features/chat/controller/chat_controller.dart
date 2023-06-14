import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/chat/repositories/chat_repository.dart';
import 'package:whatsapp_ui/model/chat_contact.dart';
import 'package:whatsapp_ui/model/message_model.dart';
import 'package:whatsapp_ui/model/group.dart' as model;

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

  void sentTextMessage(BuildContext context, String text, String receiverUserId,
      bool isGroupChat) {
    ref.read(userdataProvider).whenData((value) =>
        chatRepository.sentTextMessage(
            isGroupChat: isGroupChat,
            context: context,
            text: text,
            receiverUserId: receiverUserId,
            sendUser: value!));
  }

  void sentFileMessage(BuildContext context, File file, String receiverUserId,
      MessageEnum messageEnum, bool isGroupChat) {
    ref.read(userdataProvider).whenData((value) =>
        chatRepository.sendFileMessage(
            isGroupChat: isGroupChat,
            context: context,
            file: file,
            receiverUserId: receiverUserId,
            senderUserData: value!,
            messageEnum: messageEnum,
            ref: ref));
  }

  void setChatMessageSeen(
      BuildContext context, String receiverUserid, String messageId) {
    chatRepository.setMessageSeen(context, receiverUserid, messageId);
  }
}
