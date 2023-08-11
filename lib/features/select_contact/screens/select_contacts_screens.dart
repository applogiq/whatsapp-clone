import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/select_contact/controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/select-contact';
  const SelectContactsScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsScreenState();
}

class _SelectContactsScreenState extends ConsumerState<SelectContactsScreen> {
  final searchController = TextEditingController();
  List<Contact> contacts = [];
  List<Contact> registeredContacts = [];
  List<Contact> unregisteredContacts = [];
  Set<String> registeredNumbers = {}; // Define it here

  @override
  void initState() {
    super.initState();
    getAllContacts();
    searchController.addListener(() {
      filteredContacts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  getAllContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> _contacts =
            await FlutterContacts.getContacts(withProperties: true);

        final registeredContactsData =
            await FirebaseFirestore.instance.collection("users").get();

        for (final message in registeredContactsData.docs) {
          final messageData = message.data();
          final phoneNumber = messageData['phoneNumber'];
          registeredNumbers.add(phoneNumber);
        }

        setState(() {
          contacts = _contacts;
          registeredContacts = _contacts
              .where((contact) =>
                  contact.phones.isNotEmpty &&
                  registeredNumbers
                      .contains(contact.phones[0].number.replaceAll(' ', '')))
              .toList();
          unregisteredContacts = _contacts
              .where((contact) =>
                  contact.phones.isNotEmpty &&
                  !registeredNumbers
                      .contains(contact.phones[0].number.replaceAll(' ', '')))
              .toList();
        });
      } else {}
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  filteredContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((element) {
        String searchItem = searchController.text.toLowerCase();
        String contactName = element.displayName.toLowerCase();
        return contactName.contains(searchItem);
      });
    }
    setState(() {
      registeredContacts = _contacts
          .where((contact) =>
              contact.phones.isNotEmpty &&
              registeredNumbers
                  .contains(contact.phones[0].number.replaceAll(' ', '')))
          .toList();
      unregisteredContacts = _contacts
          .where((contact) =>
              contact.phones.isNotEmpty &&
              !registeredNumbers
                  .contains(contact.phones[0].number.replaceAll(' ', '')))
          .toList();
    });
  }

  void selectContact(WidgetRef ref, Contact selectedContact,
      BuildContext context, String contactNum) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context, contactNum);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isSearching = searchController.text.isNotEmpty;
    final List<Contact> displayedRegisteredContacts = isSearching
        ? registeredContacts
            .where((contact) => contact.displayName
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList()
        : registeredContacts;
    final List<Contact> displayedUnregisteredContacts = isSearching
        ? unregisteredContacts
            .where((contact) => contact.displayName
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList()
        : unregisteredContacts;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Contacts"),
            Text(
              "${contacts.length} contacts",
              style: authScreensubTitleStyle(),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: contacts.isEmpty
          ? const SizedBox()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 45,
                    width: size.width,
                    child: TextField(
                      controller: searchController,
                      // autofocus: true,
                      decoration: InputDecoration(
                          fillColor: const Color.fromRGBO(242, 242, 242, 1),
                          filled: true,
                          hintText: 'Search Contacts',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 12, 0, 0)),
                      cursorWidth: 1.2,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.name,
                      inputFormatters: const [],
                      onChanged: (value) {
                        filteredContacts();
                      },
                      // style: authScreensubTitleStyle().copyWith(fontSize: 15),
                    ),
                  ),
                ),
                if (displayedRegisteredContacts.isEmpty &&
                    displayedUnregisteredContacts.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.3),
                    child: const Text(
                      "No Contacts",
                      // style: authScreenheadingStyle().copyWith(fontSize: 15),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (displayedRegisteredContacts.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Text(
                                    "Registered Contacts",
                                    style: authScreenheadingStyle()
                                        .copyWith(fontSize: 18),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: displayedRegisteredContacts.length,
                                  itemBuilder: (context, index) {
                                    final contact =
                                        displayedRegisteredContacts[index];
                                    return InkWell(
                                        onTap: () {
                                          selectContact(ref, contact, context,
                                              contact.phones[0].number);
                                        },
                                        child: ListTile(
                                          title: Text(
                                            contact.displayName,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                          trailing: Icon(
                                            registeredNumbers.contains(contact
                                                    .phones[0].number
                                                    .replaceAll(' ', ''))
                                                ? Icons.check_circle
                                                : Icons.help_outline,
                                            color: registeredNumbers.contains(
                                                    contact.phones[0].number
                                                        .replaceAll(' ', ''))
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                          leading: FutureBuilder<
                                              QuerySnapshot<
                                                  Map<String, dynamic>>>(
                                            future: FirebaseFirestore.instance
                                                .collection("users")
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              } else if (snapshot.hasData) {
                                                final messages =
                                                    snapshot.data!.docs;
                                                var profilePic =
                                                    'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png';
                                                final phoneNumber = contact
                                                        .phones.isNotEmpty
                                                    ? contact.phones[0].number
                                                        .replaceAll(' ', '')
                                                    : '';

                                                for (final message
                                                    in messages) {
                                                  final messageData =
                                                      message.data();
                                                  if (messageData[
                                                          'phoneNumber'] ==
                                                      phoneNumber) {
                                                    profilePic = messageData[
                                                        'profilePic'];
                                                    break;
                                                  }
                                                }
                                                return Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          profilePic),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                // User not found in Firebase users collection, show default image
                                                return Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    image:
                                                        const DecorationImage(
                                                      image: NetworkImage(
                                                          'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ));
                                  },
                                ),
                              ],
                            ),
                          if (displayedUnregisteredContacts.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    "Invite your friends",
                                    style: authScreenheadingStyle()
                                        .copyWith(fontSize: 18),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      displayedUnregisteredContacts.length,
                                  itemBuilder: (context, index) {
                                    final contact =
                                        displayedUnregisteredContacts[index];
                                    return InkWell(
                                        onTap: () {
                                          selectContact(ref, contact, context,
                                              contact.phones[0].number);
                                        },
                                        child: ListTile(
                                          title: Text(
                                            contact.displayName,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                          trailing: Text("Invite",
                                              style: authScreensubTitleStyle()
                                                  .copyWith(
                                                      color: buttonColor,
                                                      fontWeight:
                                                          FontWeight.w900)),
                                          leading: FutureBuilder<
                                              QuerySnapshot<
                                                  Map<String, dynamic>>>(
                                            future: FirebaseFirestore.instance
                                                .collection("users")
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              } else if (snapshot.hasData) {
                                                final messages =
                                                    snapshot.data!.docs;
                                                var profilePic =
                                                    'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png';
                                                final phoneNumber = contact
                                                        .phones.isNotEmpty
                                                    ? contact.phones[0].number
                                                        .replaceAll(' ', '')
                                                    : '';

                                                for (final message
                                                    in messages) {
                                                  final messageData =
                                                      message.data();
                                                  if (messageData[
                                                          'phoneNumber'] ==
                                                      phoneNumber) {
                                                    profilePic = messageData[
                                                        'profilePic'];
                                                    break;
                                                  }
                                                }
                                                return Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          profilePic),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    image:
                                                        const DecorationImage(
                                                      image: NetworkImage(
                                                          'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ));
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
