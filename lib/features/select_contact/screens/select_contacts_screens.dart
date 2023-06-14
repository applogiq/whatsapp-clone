import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/select_contact/controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/select-contact';
  const SelectContactsScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsScreenState();
}

class _SelectContactsScreenState extends ConsumerState<SelectContactsScreen> {
  // final bool _isSearching = false;
  final searchController = TextEditingController();
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];

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
    List<Contact> _contacts =
        await FlutterContacts.getContacts(withProperties: true);
    setState(() {
      contacts = _contacts;
    });
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
      setState(() {
        contactsFiltered = _contacts;
      });
    }
  }

  void selectContact(
      WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Select Contacts"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
          data: (contactsList) {
            if (contacts.isEmpty) {
              return const SizedBox();
            }
            final List<Contact> displayedContacts =
                isSearching ? contactsFiltered : contactsList;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: getProportionateScreenHeight(45),
                    width: size.width,
                    child: TextField(
                      controller: searchController,
                      // autofocus: true,
                      decoration: InputDecoration(
                          fillColor: const Color.fromRGBO(242, 242, 242, 1),
                          filled: true,
                          hintText: 'Search contacts',
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
                      onChanged: (value) {},
                      style: authScreensubTitleStyle().copyWith(fontSize: 15),
                    ),
                  ),
                ),
                displayedContacts.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: size.height * 0.3),
                        child: Text(
                          "No Contacts",
                          style:
                              authScreenheadingStyle().copyWith(fontSize: 15),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: isSearching == true
                                ? contactsFiltered.length
                                : contactsList.length,
                            itemBuilder: (context, intex) {
                              final contact = isSearching == true
                                  ? contactsFiltered[intex]
                                  : contacts[intex];
                              return InkWell(
                                  onTap: () {
                                    print(contact.displayName);

                                    selectContact(ref, contact, context);
                                  },
                                  child: ListTile(
                                    title: Text(
                                      contact.displayName,
                                      style: authScreenheadingStyle()
                                          .copyWith(fontSize: 18),
                                    ),
                                    leading: FutureBuilder<
                                        QuerySnapshot<Map<String, dynamic>>>(
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
                                                    BorderRadius.circular(12),
                                                color: Colors.grey),
                                          );
                                        } else if (snapshot.hasData) {
                                          final messages = snapshot.data!.docs;
                                          var profilePic =
                                              'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png';
                                          final phoneNumber =
                                              contact.phones.isNotEmpty
                                                  ? contact.phones[0].number
                                                      .replaceAll(' ', '')
                                                  : '';

                                          for (final message in messages) {
                                            final messageData = message.data();
                                            if (messageData['phoneNumber'] ==
                                                phoneNumber) {
                                              profilePic =
                                                  messageData['profilePic'];
                                              break;
                                            }
                                          }
                                          return Container(
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
                                          );
                                        } else {
                                          // User not found in Firebase users collection, show default image
                                          return Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: const DecorationImage(
                                                image: NetworkImage(
                                                    'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                          //   CircleAvatar(
                                          //   backgroundImage: NetworkImage(
                                          //       "https://s3.amazonaws.com/37assets/svn/765-default-avatar.png"),
                                          // );
                                        }
                                      },
                                    ),
                                  ));
                            }),
                      ),
              ],
            );
          },
          error: (error, trace) => ErrorSccreen(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}

// class SelectContactsScreen extends ConsumerWidget {
//   static const String routeName = '/select-contact';
//   const SelectContactsScreen({super.key});

//   void selectContact(
//       WidgetRef ref, Contact selectedContact, BuildContext context) {
//     ref
//         .read(selectContactControllerProvider)
//         .selectContact(selectedContact, context);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       // backgroundColor: Colors.black,
//       appBar: AppBar(
//         elevation: 0,
//         // backgroundColor: backgroundColor,
//         title: const Text("Select Contacts"),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(
//               Icons.search,
//             ),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(
//               Icons.more_vert,
//             ),
//           ),
//         ],
//       ),
//       body: ref.watch(getContactsProvider).when(
//           data: (contactsList) {
//             if (contactsList.isEmpty) {
//               return Container(); // or any appropriate widget to handle the empty list case
//             }

//             return ListView.builder(
//                 shrinkWrap: true,
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: contactsList.length,
//                 itemBuilder: (context, intex) {
//                   final contact = contactsList[intex];
//                   return InkWell(
//                       onTap: () {
//                         print(contact.displayName);

//                         selectContact(ref, contact, context);
//                       },
//                       child: ListTile(
//                         title: Text(
//                           contact.displayName,
//                           style:
//                               authScreenheadingStyle().copyWith(fontSize: 18),
//                         ),
//                         leading:
//                             FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                           future: FirebaseFirestore.instance
//                               .collection("users")
//                               .get(),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const CircularProgressIndicator();
//                             } else if (snapshot.hasData) {
//                               final messages = snapshot.data!.docs;
//                               var profilePic =
//                                   'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png';
//                               final phoneNumber = contact.phones.isNotEmpty
//                                   ? contact.phones[0].number.replaceAll(' ', '')
//                                   : '';

//                               for (final message in messages) {
//                                 final messageData = message.data();
//                                 if (messageData['phoneNumber'] == phoneNumber) {
//                                   profilePic = messageData['profilePic'];
//                                   break;
//                                 }
//                               }
//                               return Container(
//                                 height: 50,
//                                 width: 50,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   image: DecorationImage(
//                                     image: NetworkImage(profilePic),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               );
//                             } else {
//                               // User not found in Firebase users collection, show default image
//                               return Container(
//                                 height: 50,
//                                 width: 50,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   image: const DecorationImage(
//                                     image: NetworkImage(
//                                         'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png'),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               );
//                               //   CircleAvatar(
//                               //   backgroundImage: NetworkImage(
//                               //       "https://s3.amazonaws.com/37assets/svn/765-default-avatar.png"),
//                               // );
//                             }
//                           },
//                         ),
//                       ));
//                 });
//           },
//           error: (error, trace) => ErrorSccreen(error: error.toString()),
//           loading: () => const Loader()),
//     );
//   }
// }
