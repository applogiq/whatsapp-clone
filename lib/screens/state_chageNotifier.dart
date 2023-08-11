// ignore_for_file: file_names, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screen_recording/flutter_screen_recording.dart';

class TodosNotifier extends ChangeNotifier {
  bool isShow = false;
  String isScreenRecording = '';
  FirebaseFirestore? fireStore;

  isShowButton() {
    isShow = !isShow;
    notifyListeners();
  }

  getgroupContacts() async {
    var groupId = fireStore!.collection('groups').snapshots();
  }
}

final totoProvider = ChangeNotifierProvider<TodosNotifier>((ref) {
  return TodosNotifier();
});
