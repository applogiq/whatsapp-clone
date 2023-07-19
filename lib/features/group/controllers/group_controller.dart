import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/group/repositories/group_repository.dart';

final groupControllerprovider = Provider((ref) {
  final groupRepository = ref.read(groupRepositoryprovider);
  return GroupController(groupRepository: groupRepository, providerRef: ref);
});

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef providerRef;

  GroupController({required this.groupRepository, required this.providerRef});
  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) {
    groupRepository.createGroup(context, name, profilePic, selectedContact);
  }
}
