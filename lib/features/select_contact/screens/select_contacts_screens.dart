import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/select_contact/controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const String routeName = '/select-contact';
  const SelectContactsScreen({super.key});

  void selectContact(
      WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: const Text("Select Contacts"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
          data: (contactsList) => ListView.builder(
              itemCount: contactsList.length,
              itemBuilder: (context, intex) {
                final contact = contactsList[intex];
                return InkWell(
                  onTap: () {
                    print(contact.displayName);

                    selectContact(ref, contact, context);
                  },
                  child: ListTile(
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(fontSize: 18),
                    ),
                    leading: contact.photo == null
                        ? null
                        : CircleAvatar(
                            backgroundImage: MemoryImage(contact.photo!),
                            radius: 30,
                          ),
                  ),
                );
              }),
          error: (error, trace) => ErrorSccreen(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
