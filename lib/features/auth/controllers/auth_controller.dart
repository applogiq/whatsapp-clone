import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_ui/model/user_model.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryprovider);
  return AuthController(authRepository: authRepository, ref: ref);
});
final userdataProvider = FutureProvider((ref) async {
  print("😂😂😂😂no1");

  final authController = ref.watch(authControllerProvider);

  return authController.getUserData();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;

  AuthController({
    required this.authRepository,
    required this.ref,
  });
  Future<UserModel?> getUserData() async {
    print("😂😂😂😂no2");

    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  void signInWithPhone(
    BuildContext ctx,
    String phoneNumber,
  ) {
    authRepository.signInWithPhone(ctx, phoneNumber);
  }

  void verifyOTP(BuildContext context, String verificationId, String userOTP) {
    authRepository.verifyOTP(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
    );
  }

  void saveUserDataToFirebase(
      BuildContext context, String name, File? profilePic) {
    authRepository.saveUserDataToFirebase(
      lastSeen: DateTime.now().toString(),
      name: name,
      profilePic: profilePic,
      ref: ref,
      context: context,
    );
  }

  Stream<UserModel> userDataById(String userId) {
    return authRepository.userData(userId);
  }

  void setuserState(bool isOnline) {
    authRepository.setuserState(isOnline);
  }

  void setLastSeenData(String time) {
    authRepository.setLastSeenStatus(time);
  }

  getUser() {
    return authRepository.getUser();
  }

  logout(
    BuildContext context,
  ) {
    return authRepository.logOut(
      context,
    );
  }
}
