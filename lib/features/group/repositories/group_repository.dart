import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/repositories/common_firebase_storage_repositor.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/model/group.dart' as model;

final groupRepositoryprovider = Provider((ref) => GroupRepository(
    fireStore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class GroupRepository {
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupRepository(
      {required this.fireStore, required this.auth, required this.ref});
  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedConntact) async {
    try {
      List<String> uids = [];
      List<String> deviceTokens = [];
      for (int i = 0; i < selectedConntact.length; i++) {
        var userCollection = await fireStore
            .collection('users')
            .where(
              'phoneNumber',
              isEqualTo: selectedConntact[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();
        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid']);
          deviceTokens.add(userCollection.docs[0].data()['deviceToken']);
        }
      }
      var groupId = const Uuid().v1();
      // ignore: unused_local_variable
      var deviceToken =
          "e-8TOoX7Tz-1DOw7HUmBH5:APA91bG16a9mQkD7H-tb5FnDPhwCupiPTNHZvC_t5EmcWk0za9a-8B9Q_F5I4Wzw8ugrIFo6_jaTolqKn4OAa3FxtG6Ql5dN4_TiPUtjUvyNVu3rX1D94eUxktrJ9v65nmljlNOpzl2D";
      String profileUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase('group/$groupId', profilePic);
      model.Group group = model.Group(
          senderId: auth.currentUser!.uid,
          name: name,
          groupId: groupId,
          lastMessage: '',
          groupPic: profileUrl,
          membersUid: [auth.currentUser!.uid, ...uids],
          membersDeviceToken: [...deviceTokens],
          timeSent: DateTime.now());
      await fireStore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  getgroupContactUser(BuildContext ctx) async {
    try {
      var groupId = const Uuid().v1();

      fireStore.collection('groups').doc(groupId).snapshots();
    } catch (e) {
      showSnackBar(context: ctx, content: e.toString());
    }
  }
}
