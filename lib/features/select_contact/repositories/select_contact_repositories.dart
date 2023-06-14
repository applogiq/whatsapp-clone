import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/model/user_model.dart';
import 'package:whatsapp_ui/features/chat/screens/mobile_chat_screen.dart';

final selectcontactsRepositoryProvider = Provider(
    (ref) => SelectContactRepository(firestore: FirebaseFirestore.instance));

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({required this.firestore});
  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint("cvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv");

      debugPrint(e.toString());
      debugPrint("cvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv");
    }
    return contacts;
  }

  void selectcontacts(Contact selectedContacts, BuildContext context) async {
    try {
      var userCollection = await firestore.collection("users").get();
      bool isfound = false;
      for (var document in userCollection.docs) {
        var userdata = UserModel.fromMap(document.data());
        String selectedPhoneNum = selectedContacts.phones[0].number.replaceAll(
          ' ',
          '',
        );
        // print(userdata.name);
        // print(userdata.uid);
        if (selectedPhoneNum == userdata.phoneNumber) {
          print("123456");
          isfound = true;
          // Navigator.pushNamed(
          //   context,
          //   MobileChatScreen.routeName,
          //   arguments: {
          //     'name': userdata.name,
          //     'uid': userdata.uid,
          //     'isGroupChat': false,
          //   },
          // );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MobileChatScreen(
                      isGroupChat: false,
                      name: userdata.name,
                      uid: userdata.uid,
                      profileImage:
                          'https://firebasestorage.googleapis.com/v0/b/chat-app-firebase-4d363.appspot.com/o/group%2Fd1a87890-fabf-11ed-abd2-5ba78cc0f964?alt=media&token=0abe0ff3-c2bb-4497-972d-eae1132c0ffd')));
        }
      }
      if (!isfound) {
        showSnackBar(
          context: context,
          content: 'This number does not exist on this app.',
        );
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
