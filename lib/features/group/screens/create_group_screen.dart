import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/group/controllers/group_controller.dart';
import 'package:whatsapp_ui/features/group/widgets/select_contacts_group.dart';

final selectedContactGroups = StateProvider<List<Contact>>((ref) => []);

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  File? image;
  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGroup() {
    print(groupNameController.text.trim().isNotEmpty);
    print(image != null);
    print("1");
    try {
      if (groupNameController.text.trim().isNotEmpty && image != null) {
        print("2");

        ref.read(groupControllerprovider).createGroup(
            context,
            groupNameController.text.trim(),
            image!,
            ref.read(selectedContactGroups));
        ref.read(selectedContactGroups.state).update((state) => []);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
    }
    print("3");
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: const Text("Create group"),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  image == null
                      ? const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
                          ),
                          radius: 80,
                        )
                      : CircleAvatar(
                          backgroundImage: FileImage(
                            image!,
                          ),
                          radius: 80,
                        ),
                  Positioned(
                    bottom: -10,
                    left: 90,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: groupNameController,
                  decoration:
                      const InputDecoration(hintText: 'Enter Group Name'),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 16),
                alignment: Alignment.topLeft,
                child: const Text(
                  "Select Contacts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SelectContactsGroups()
            ],
          ),
        ),
        floatingActionButton: InkWell(
          onTap: () {
            createGroup();
          },
          child: Container(
            height: 80,
            width: 80,
            color: Colors.red,
          ),
        ));
  }
}
