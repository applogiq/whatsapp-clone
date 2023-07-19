import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/call/screeens/call_screen.dart';
import 'package:whatsapp_ui/model/call.dart';
import 'package:whatsapp_ui/model/group.dart' as model;

final callRepositoryprovider = Provider((ref) => CallRepository(
      fireStore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ));

class CallRepository {
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;

  CallRepository({
    required this.fireStore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream =>
      fireStore.collection('call').doc(auth.currentUser!.uid).snapshots();
  void makeCall(Call senderCallData, BuildContext context,
      Call receiversCallData, bool isAudioCall) async {
    try {
      await fireStore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await fireStore
          .collection('call')
          .doc(senderCallData.receiverId)
          .set(receiversCallData.toMap());

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CallScreen(
                  callerName: receiversCallData.receiverName,
                  callerImage: receiversCallData.receiverPic,
                  isAudioCall: isAudioCall,
                  call: senderCallData,
                  isGroupChat: false,
                  channelId: senderCallData.callId)));
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void makeGroupCall(
      Call senderCallData, BuildContext context, Call receiversCallData) async {
    try {
      await fireStore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      var groupSnapShot = await fireStore
          .collection('groups')
          .doc(senderCallData.receiverId)
          .get();
      model.Group group = model.Group.fromMap(groupSnapShot.data()!);
      for (var id in group.membersUid) {
        await fireStore
            .collection('call')
            .doc(id)
            .set(receiversCallData.toMap());
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CallScreen(
                  callerName: receiversCallData.receiverName,
                  callerImage: receiversCallData.receiverPic,
                  isAudioCall: false,
                  call: senderCallData,
                  isGroupChat: true,
                  channelId: senderCallData.callId)));
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await fireStore.collection('call').doc(callerId).delete();
      // var groupSnapShot =
      //     await fireStore.collection('groups').doc(receiverId).get();
      // model.Group group = model.Group.fromMap(groupSnapShot.data()!);
      await fireStore.collection('call').doc(receiverId).delete();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endGroupCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await fireStore.collection('call').doc(callerId).delete();
      var groupSnapShot =
          await fireStore.collection('groups').doc(receiverId).get();
      model.Group group = model.Group.fromMap(groupSnapShot.data()!);
      for (var id in group.membersUid) {
        await fireStore.collection('call').doc(id).delete();
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  getgroupContactUser() async {
    try {
      var groupId = const Uuid().v1();

      fireStore.collection('groups').doc(groupId).snapshots();
    } catch (e) {
      print(e.toString());
    }
  }
}
