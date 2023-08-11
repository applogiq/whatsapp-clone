// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/repositories/common_firebase_storage_repositor.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/chat/model/chat_model.dart';
import 'package:whatsapp_ui/model/chat_contact.dart';
import 'package:whatsapp_ui/model/message_model.dart';
import 'package:whatsapp_ui/model/user_model.dart';
import 'package:whatsapp_ui/model/group.dart' as model;

final chatRepositoryProvider = Provider((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getContacts() {
    return firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("chats")
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection("users")
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);
        contacts.add(ChatContact(
            isTyping: false,
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage));
      }

      return contacts;
    });
  }

  Stream<List<model.Group>> getChatGroups() {
    return firestore.collection("groups").snapshots().map((event) {
      List<model.Group> groups = [];
      for (var document in event.docs) {
        var group = model.Group.fromMap(document.data());
        if (group.membersUid.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("chats")
        .doc(receiverUserId)
        .collection("messages")
        .orderBy("timeSent")
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  Stream<List<Message>> getgroupStream(String groupId) {
    return firestore
        .collection("groups")
        .doc(groupId)
        .collection("chats")
        .doc(auth.currentUser!.uid)
        .collection("users")
        .orderBy("timeSent")
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactSubCollection(
      UserModel senderuserData,
      UserModel? receiverUserData,
      String text,
      DateTime timeSent,
      String receiveruserId,
      bool isGroupChat) async {
    if (isGroupChat) {
      await firestore.collection('groups').doc(receiveruserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch
      });
    } else {
      var receiverChatContact = ChatContact(
          isTyping: false,
          name: senderuserData.name,
          profilePic: senderuserData.profilePic,
          contactId: senderuserData.uid,
          timeSent: timeSent,
          lastMessage: text);
      await firestore
          .collection("users")
          .doc(receiveruserId)
          .collection("chats")
          .doc(auth.currentUser!.uid)
          .set(receiverChatContact.toMap());

      var senderChatContact = ChatContact(
          isTyping: false,
          name: receiverUserData!.name,
          profilePic: receiverUserData.profilePic,
          contactId: receiverUserData.uid,
          timeSent: timeSent,
          lastMessage: text);
      await firestore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("chats")
          .doc(receiveruserId)
          .set(senderChatContact.toMap());
    }
  }

  void _groupsaveMessagetoMessageSubCollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String? receiverUserName,
    required MessageEnum messagetype,
    required List memberList,
    required bool isGroupChat,
  }) async {
    for (String member in memberList) {
      final Map<String, dynamic> memberListMap = {member: false};
      final message = isGroupChat
          ? Message(
              senderId: auth.currentUser!.uid,
              recieverid: receiverUserId,
              text: text,
              type: messagetype,
              timeSent: timeSent,
              messageId: messageId,
              isSeen: false,
            )
          : Message(
              senderId: auth.currentUser!.uid,
              recieverid: receiverUserId,
              text: text,
              type: messagetype,
              timeSent: timeSent,
              messageId: messageId,
              isSeen: false,
            );

      if (isGroupChat) {
        await firestore
            .collection('groups')
            .doc(receiverUserId)
            .collection('chats')
            .doc(member)
            .collection('users')
            .doc(messageId)
            .set(message.toMap());
      } else {
        await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .collection("chats")
            .doc(receiverUserId)
            .collection("messages")
            .doc(messageId)
            .set(message.toMap());

        await firestore
            .collection("users")
            .doc(receiverUserId)
            .collection("chats")
            .doc(auth.currentUser!.uid)
            .collection("messages")
            .doc(messageId)
            .set(message.toMap());
      }
    }
  }

  void _saveMessagetoMessageSubCollection(
      {required String receiverUserId,
      required String text,
      required DateTime timeSent,
      required String messageId,
      required String username,
      required String? receiverUserName,
      required MessageEnum messagetype,
      required List memberList,
      required bool isGroupChat}) async {
    final Map<String, dynamic> memberListMap = {};
    for (String member in memberList) {
      memberListMap[member] = false;
    }
    final message = isGroupChat
        ? Message(
            senderId: auth.currentUser!.uid,
            recieverid: receiverUserId,
            text: text,
            type: messagetype,
            timeSent: timeSent,
            messageId: messageId,
            isSeen: false,
            additionalData: memberListMap)
        : Message(
            senderId: auth.currentUser!.uid,
            recieverid: receiverUserId,
            text: text,
            type: messagetype,
            timeSent: timeSent,
            messageId: messageId,
            isSeen: false,
          );
    if (isGroupChat) {
      await firestore
          .collection('groups')
          .doc(receiverUserId)
          .collection('chats')
          .doc(messageId)
          .set(message.toMap());
    } else {
      await firestore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("chats")
          .doc(receiverUserId)
          .collection("messages")
          .doc(messageId)
          .set(message.toMap());

      await firestore
          .collection("users")
          .doc(receiverUserId)
          .collection("chats")
          .doc(auth.currentUser!.uid)
          .collection("messages")
          .doc(messageId)
          .set(message.toMap());
    }
  }

  Future sentTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel sendUser,
    required bool isGroupChat,
    required List groupMemberId,
  }) async {
    try {
      var timesent = DateTime.now();
      UserModel? receiverdata;
      model.Group? receivedGroupData;
      if (!isGroupChat) {
        var userdatamap =
            await firestore.collection("users").doc(receiverUserId).get();
        receiverdata = UserModel.fromMap(userdatamap.data()!);
      }

      var messageId = const Uuid().v4();
      _saveDataToContactSubCollection(
          sendUser, receiverdata, text, timesent, receiverUserId, isGroupChat);
      isGroupChat
          ? _groupsaveMessagetoMessageSubCollection(
              memberList: groupMemberId,
              isGroupChat: isGroupChat,
              receiverUserId: receiverUserId,
              text: text,
              timeSent: timesent,
              messagetype: MessageEnum.text,
              messageId: messageId,
              receiverUserName: receiverdata?.name,
              username: sendUser.name)
          : _saveMessagetoMessageSubCollection(
              memberList: groupMemberId,
              isGroupChat: isGroupChat,
              receiverUserId: receiverUserId,
              text: text,
              timeSent: timesent,
              messagetype: MessageEnum.text,
              messageId: messageId,
              receiverUserName: receiverdata?.name,
              username: sendUser.name);

      !isGroupChat
          ? PushNotification().sendPushNotification(
              receiverdata!.deviceToken, 'Chat App', "New Message", context)
          : "";
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required String receiverUserId,
      required UserModel senderUserData,
      required ProviderRef ref,
      required MessageEnum messageEnum,
      required bool isGroupChat,
      required List groupMemberId}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
            file,
          );

      UserModel? receiverUserData;
      if (!isGroupChat) {
        var userdatamap =
            await firestore.collection("users").doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userdatamap.data()!);
      }
      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 photo';
          break;
        case MessageEnum.video:
          contactMsg = '🎥 video';
          break;
        case MessageEnum.audio:
          contactMsg = '🔉 Audio';
          break;

        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }
      _saveDataToContactSubCollection(senderUserData, receiverUserData,
          contactMsg, timeSent, receiverUserId, isGroupChat);
      isGroupChat
          ? _groupsaveMessagetoMessageSubCollection(
              memberList: groupMemberId,
              isGroupChat: isGroupChat,
              receiverUserId: receiverUserId,
              text: imageUrl,
              timeSent: timeSent,
              messagetype: messageEnum,
              messageId: messageId,
              receiverUserName: receiverUserData?.name,
              username: senderUserData.name)
          : _saveMessagetoMessageSubCollection(
              memberList: [],
              receiverUserId: receiverUserId,
              text: imageUrl,
              timeSent: timeSent,
              messageId: messageId,
              username: senderUserData.name,
              receiverUserName: receiverUserData?.name,
              isGroupChat: isGroupChat,
              messagetype: messageEnum);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setMessageSeen(
      BuildContext context, String receiverUserId, String messageId) async {
    try {
      await firestore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("chats")
          .doc(receiverUserId)
          .collection("messages")
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection("users")
          .doc(receiverUserId)
          .collection("chats")
          .doc(auth.currentUser!.uid)
          .collection("messages")
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void groupSetMessageSeen(
      BuildContext context, String receiverUserId, String messageId) async {
    try {
      await firestore
          .collection("groups")
          .doc(receiverUserId)
          .collection("chats")
          .doc(auth.currentUser!.uid)
          .collection("users")
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<List<Message>> getlastMessage(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent', descending: true)
        .limit(1)
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }
}
