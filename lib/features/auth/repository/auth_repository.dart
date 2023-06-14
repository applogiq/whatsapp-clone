import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/repositories/common_firebase_storage_repositor.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/auth/screens/login_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/user_informayion_screen.dart';
import 'package:whatsapp_ui/model/user_model.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

final authRepositoryprovider = Provider((ref) => AuthRepository(
    auth: FirebaseAuth.instance, fireStore: FirebaseFirestore.instance));

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore fireStore;

  AuthRepository({required this.auth, required this.fireStore});
  Future<UserModel?> getCurrentUserData() async {
    print("😂😂😂😂no");

    var userdata =
        await fireStore.collection("users").doc(auth.currentUser?.uid).get();
    UserModel? user;
    if (userdata.data() != null) {
      user = UserModel.fromMap(userdata.data()!);
    } else {
      print("😂😂😂😂no");
    }
    return user;
  }

  void signInWithPhone(
    BuildContext ctx,
    String phoneNumber,
  ) async {
    // isLoad = true;
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            throw Exception(e.message);
          },
          codeSent: ((String verificatioId, int? resendToken) async {
            Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (ctx) => OTPScreen(
                          phoneNumber: phoneNumber,
                          verificationId: verificatioId,
                        )));
          }),
          codeAutoRetrievalTimeout: (String verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: ctx, content: e.message!);
    }
    // isLoad = false;
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
        context,
        UserInformationScreen.routeName,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
    required String lastSeen,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePic/$uid',
              profilePic,
            );
      }

      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

      String? token = await _firebaseMessaging.getToken();

      var user = UserModel(
        name: name,
        uid: uid,
        profilePic: photoUrl,
        isOnline: true,
        phoneNumber: auth.currentUser!.phoneNumber!,
        groupId: [],
        lastSeen: lastSeen,
        deviceToken: token!,
      );

      await fireStore.collection('users').doc(uid).set(user.toMap());
      var data = await fireStore.collection('users').doc(uid).set(user.toMap());
      // print(data).;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userData(String userId) {
    return fireStore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }

  void setuserState(bool isOnline) async {
    await fireStore.collection("users").doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }

  void setLastSeenStatus(String time) async {
    await fireStore.collection("users").doc(auth.currentUser!.uid).update({
      'lastSeen': time,
    });
  }

  getUser() {
    return fireStore.collection("users").doc(auth.currentUser!.uid).get();
  }

  Future<void> logOut(BuildContext context) async {
    try {
      var firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        FirebaseAuth.instance.signOut().then((value) => {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false)
            });
      }
    } catch (e) {
      showSnackBar(
          context: context,
          content: e.toString()); // TODO: show dialog with error
    }
  }
}
