import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_ui/features/interner_connectivity/controller/internet_connection_controller.dart';
import 'package:whatsapp_ui/features/interner_connectivity/screen/no_internet_screen.dart';
import 'package:whatsapp_ui/features/select_contact/controller/select_contact_controller.dart';

class SelectGroupContactsScreen extends ConsumerStatefulWidget {
  const SelectGroupContactsScreen({super.key});

  @override
  ConsumerState<SelectGroupContactsScreen> createState() =>
      _SelectGroupContactsScreenState();
}

class _SelectGroupContactsScreenState
    extends ConsumerState<SelectGroupContactsScreen> {
  final searchController = TextEditingController();

  List<int> selectContacts = [];
  List<Contact> selectedContacts = [];
  void selectContactsTile(int index, Contact contact) {
    setState(() {
      if (selectContacts.contains(index)) {
        selectContacts.remove(index);
        selectedContacts.remove(contact);
        // Deselect the contact
        ref
            .read(selectedContactGroups.notifier)
            .update((state) => state..remove(contact));
      } else {
        selectContacts.add(index);
        selectedContacts.add(contact); // Select the contact
        if (!ref.read(selectedContactGroups).contains(contact)) {
          ref
              .read(selectedContactGroups.notifier)
              .update((state) => state..add(contact));
        }
      }
    });
  }

  Contact contact = Contact();
  @override
  Widget build(BuildContext context) {
    final internetConnectionStatus =
        ref.watch(internetConnectionStatusProvider);
    return internetConnectionStatus ==
            const AsyncValue.data(InternetConnectionStatus.disconnected)
        ? const NoInternetScreen()
        : Scaffold(
            floatingActionButton: selectContacts.isEmpty
                ? const SizedBox.shrink()
                : FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateGroupScreen()));
                    },
                    backgroundColor: const Color.fromRGBO(237, 84, 60, 1),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),

            // backgroundColor: Colors.black,
            appBar: AppBar(
              elevation: 0,
              // backgroundColor: backgroundColor,
              title: const Text("Create Group"),
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
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
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
                                  final phoneNumber = contact.phones[0].number
                                      .replaceAll(' ', '');

                                  final user = users.firstWhere((user) =>
                                      user['phoneNumber'] == phoneNumber);
                                  final profilePic = user['profilePic'] ??
                                      'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png';

                                  return InkWell(
                                    onTap: () {
                                      selectContactsTile(index, contact);
                                    },
                                    child: ListTile(
                                      trailing: selectContacts.contains(index)
                                          ? const Icon(
                                              Icons.done,
                                              color:
                                                  Color.fromRGBO(27, 16, 11, 1),
                                            )
                                          : null,
                                      leading: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: NetworkImage(profilePic),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        contact.displayName,
                                        style: authScreenheadingStyle()
                                            .copyWith(
                                                fontSize: 18,
                                                color: selectContacts
                                                        .contains(index)
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
}
