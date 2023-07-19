import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/select_contact/repositories/select_contact_repositories.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactRepository = ref.watch(selectcontactsRepositoryProvider);
  return selectContactRepository.getContacts();
});

final selectContactControllerProvider = Provider((ref) {
  final selectContactRepository = ref.watch(selectcontactsRepositoryProvider);
  return SelectContactController(
    ref: ref,
    selectContactRepository: selectContactRepository,
  );
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepository selectContactRepository;
  SelectContactController({
    required this.ref,
    required this.selectContactRepository,
  });

  void selectContact(
      Contact selectedContact, BuildContext context, String contatcNum) {
    selectContactRepository.selectcontacts(
        selectedContact, context, contatcNum);
  }

  void addContact(
      List<Contact> selectedContact, BuildContext context, String groupId) {
    selectContactRepository.addContact(selectedContact, context, groupId);
  }
}
