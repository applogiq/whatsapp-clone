// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/select_contact/controller/select_contact_controller.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

class AddGroupContacts extends ConsumerStatefulWidget {
  final String groupId;

  const AddGroupContacts({super.key, required this.groupId});
  @override
  ConsumerState<AddGroupContacts> createState() => _AddGroupContactsState();
}

class _AddGroupContactsState extends ConsumerState<AddGroupContacts> {
  List<int> selectContacts = [];
  List<Contact> selectedContacts = [];

  void selectContactsTile(
    int index,
    Contact contact,
    String groupId,
    String val,
    BuildContext context,
  ) {
    setState(() {
      if (selectContacts.contains(index)) {
        deleteStringList(groupId, val);
        selectContacts.remove(index);
        selectedContacts.remove(contact);
      } else {
        // Check if the contact is not already selected
        if (!selectedContacts.contains(contact)) {
          selectContacts.add(index);
          selectedContacts.add(contact);
          updateStringInList(groupId, val, index);
        } else {
          // Show error snackbar if the contact is already selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${contact.displayName} is already added to the group.'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> updateStringInList(
      String documentId, String newValue, int index) async {
    final collectionRef = FirebaseFirestore.instance.collection('groups');
    final documentRef = collectionRef.doc(documentId);

    final snapshot = await documentRef.get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final list = List<String>.from(data['membersUid']);

      if (!list.contains(newValue)) {
        list.add(newValue);
        await documentRef.update({'membersUid': list});
      } else {
        // deleteStringList(documentId, newValue);
        selectContacts.remove(index);
        selectedContacts.remove(contact);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact is already a member of the group.'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {});
      }
    }
  }

  deleteStringList(String documentId, String newValue) async {
    final collectionRef = FirebaseFirestore.instance.collection('groups');
    final documentRef = collectionRef.doc(documentId);

    final snapshot = await documentRef.get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final list = List<String>.from(data['membersUid']);

      list.remove(newValue);

      await documentRef.update({'membersUid': list});
    }
  }

  Contact contact = Contact();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: selectContacts.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MobileLayoutScreen()));
                },
                backgroundColor: const Color.fromRGBO(237, 84, 60, 1),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: const Text("Add Contacts"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                "Select group members",
                style: authScreensubTitleStyle().copyWith(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ref.watch(getContactsProvider).when(
                  data: (contactsList) =>
                      FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future:
                        FirebaseFirestore.instance.collection("users").get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        final users = snapshot.data!.docs;

                        final registeredContacts =
                            contactsList.where((contact) {
                          if (contact.phones.isEmpty) {
                            return false;
                          }
                          final phoneNumber =
                              contact.phones[0].number.replaceAll(' ', '');
                          return users.any(
                              (user) => user['phoneNumber'] == phoneNumber);
                        }).toList();

                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: registeredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = registeredContacts[index];
                              final phoneNumber =
                                  contact.phones[0].number.replaceAll(' ', '');

                              final user = users.firstWhere(
                                  (user) => user['phoneNumber'] == phoneNumber);
                              final profilePic = user['profilePic'] ??
                                  'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png';
                              return InkWell(
                                onTap: () async {
                                  selectContactsTile(index, contact,
                                      widget.groupId, user['uid'], context);
                                },
                                child: ListTile(
                                  trailing: selectContacts.contains(index)
                                      ? const Icon(
                                          Icons.done,
                                          color: Color.fromRGBO(27, 16, 11, 1),
                                        )
                                      : null,
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: NetworkImage(profilePic),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    contact.displayName,
                                    style: authScreenheadingStyle().copyWith(
                                        fontSize: 18,
                                        color: selectContacts.contains(index)
                                            ? Colors.grey
                                            : const Color.fromRGBO(
                                                27, 16, 11, 1)),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        // Show a message when no users data is available
                        return const Text('No users found');
                      }
                    },
                  ),
                  error: (error, trace) =>
                      ErrorSccreen(error: error.toString()),
                  loading: () => const Loader(),
                ),
          ],
        ));
  }

  Future<void> updateSelectedContactsInFirebase(
      List<Contact> selectedContacts, String uid) async {
    final collectionRef = FirebaseFirestore.instance.collection('group');
    final groupDocRef = collectionRef.doc(widget.groupId);
    final groupData = await groupDocRef.get();

    await groupDocRef.update({'membersUid': uid});
  }
}
