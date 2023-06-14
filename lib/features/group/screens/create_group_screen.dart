import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/features/group/controllers/group_controller.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MobileLayoutScreen()));
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
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: appBarColor,
        title: const Text("Create group"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: Stack(
                alignment: AlignmentDirectional.center,
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
                  IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            const VerticalBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Upload group picture",
                style: authScreensubTitleStyle()
                    .copyWith(color: const Color.fromRGBO(5, 31, 50, 0.6)),
              ),
            ),
            const VerticalBox(height: 24),

            Text(
              "Enter group name",
              style: authScreensubTitleStyle()
                  .copyWith(color: const Color.fromRGBO(27, 16, 11, 0.6)),
            ),
            const VerticalBox(height: 5),

            SizedBox(
              width: size.width,
              child: TextField(
                autofocus: true,
                controller: groupNameController,
                decoration: InputDecoration(
                    fillColor: const Color.fromRGBO(242, 242, 242, 1),
                    filled: true,
                    hintText: 'Type here',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    contentPadding: const EdgeInsets.fromLTRB(10, 12, 0, 0)),
                cursorWidth: 1.2,
                cursorColor: Colors.black,
                onChanged: (value) {},
                style: authScreensubTitleStyle().copyWith(fontSize: 15),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                createGroup();
              },
              child: Container(
                height: 54,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(41),
                    color: const Color.fromRGBO(237, 84, 60, 1)),
                child: Center(
                  child: Text('Create group',
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      )),
                ),
              ),
            ),
            const Spacer(),

            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: TextField(
            //     controller: groupNameController,
            //     decoration:
            //         const InputDecoration(hintText: 'Enter Group Name'),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.only(left: 16),
            //   alignment: Alignment.topLeft,
            //   child: const Text(
            //     "Select Contacts",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            //   ),
            // ),
            // const SelectContactsGroups()
          ],
        ),
      ),
    );
  }
}
