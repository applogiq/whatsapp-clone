import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_ui/features/select_contact/controller/select_contact_controller.dart';

class SelectContactsGroups extends ConsumerStatefulWidget {
  const SelectContactsGroups({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsGroupsState();
}

class _SelectContactsGroupsState extends ConsumerState<SelectContactsGroups> {
  List<int> selectContacts = [];
  void selectContact(int index, Contact contact) {
    setState(() {
      if (selectContacts.contains(index)) {
        selectContacts.removeAt(index);
      } else {
        selectContacts.add(index);
      }
    });

    ref
        .read(selectedContactGroups.notifier)
        .update((state) => [...state, contact]);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactsProvider).when(
        data: (contactList) => Expanded(
            child: ListView.builder(
                itemCount: contactList.length,
                itemBuilder: (context, index) {
                  final contact = contactList[index];
                  return InkWell(
                    onTap: () => selectContact(index, contact),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                          title: Text(
                            contact.displayName,
                            style: const TextStyle(fontSize: 18),
                          ),
                          leading: selectContacts.contains(index)
                              ? IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.done))
                              : null),
                    ),
                  );
                })),
        error: (error, trace) => ErrorSccreen(error: error.toString()),
        loading: () => const Loader());
  }
}
