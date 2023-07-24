import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/features/call/repository/call_repository.dart';

import 'package:whatsapp_ui/model/call.dart';
import 'package:whatsapp_ui/model/user_model.dart';

final callControllerprovider = Provider((ref) {
  final callrepository = ref.read(callRepositoryprovider);
  return CallController(
      auth: FirebaseAuth.instance,
      callRepository: callrepository,
      providerRef: ref);
});

class CallController {
  final CallRepository callRepository;
  final ProviderRef providerRef;
  final FirebaseAuth auth;
  CallController(
      {required this.callRepository,
      required this.providerRef,
      required this.auth});
  Stream<DocumentSnapshot> get callStream => callRepository.callStream;
  Future<void> makeCall(
      BuildContext context,
      String receiverName,
      String receiverUid,
      String receiverprofilepic,
      bool isGrouopChat,
      bool isAudioCall) async {
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
          print(e.toString());
        }
      }
      return user;
    }

    user = await getCurrentUserData();

    String callId = const Uuid().v1();

    if (user != null) {
      Call senderCallData = Call(
          isInCommingCall: false,
          isAudioCall: isAudioCall,
          callerId: auth.currentUser!.uid,
          callerName: user!.name,
          callerPic: user!.profilePic,
          receiverId: receiverUid,
          receiverName: receiverName,
          receiverPic: receiverprofilepic,
          callId: callId,
          hasDialled: true);
      Call receiverCallData = Call(
          isInCommingCall: true,
          isAudioCall: isAudioCall,
          callerId: auth.currentUser!.uid,
          callerName: user!.name,
          callerPic: user!.profilePic,
          receiverId: receiverUid,
          receiverName: receiverName,
          receiverPic: receiverprofilepic,
          callId: callId,
          hasDialled: false);
      if (isGrouopChat) {
        callRepository.makeGroupCall(senderCallData, context, receiverCallData);
      } else {
        callRepository.makeCall(
            senderCallData, context, receiverCallData, isAudioCall);
      }
    } else {
      print("Error");
    }
  }

  void endCall(String callerid, String receiverId, BuildContext context) {
    callRepository.endCall(callerid, receiverId, context);
  }
}
