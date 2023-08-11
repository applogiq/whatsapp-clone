// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/features/auth/screens/login_screen.dart';
import 'package:whatsapp_ui/features/group/controllers/group_controller.dart';
import 'package:whatsapp_ui/features/interner_connectivity/screen/no_internet_screen.dart';
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
  bool isButtonEnable = false;
  String errorText = '';
  void selectImage() async {
    image = await pickImageFromGallery(context);
    groupNameController.text = '';
    setState(() {});
  }

  Future<File> getAssetFile(String assetPath) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    File assetFile = File('$appDocPath/$fileName');
    ByteData data = await rootBundle.load(assetPath);
    await assetFile.writeAsBytes(data.buffer.asUint8List());

    return assetFile;
  }

  void createGroup() async {
    try {
      if (groupNameController.text.trim().isNotEmpty && image != null) {
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
      } else if (groupNameController.text.trim().isNotEmpty && image == null) {
        ref.read(groupControllerprovider).createGroup(
            context,
            groupNameController.text.trim(),
            await getAssetFile('assets/gb.png'),
            ref.read(selectedContactGroups));
        ref.read(selectedContactGroups.state).update((state) => []);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MobileLayoutScreen()));
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    errorText = '';
    setState(() {});
    if (image == null) {
      isButtonEnable = false;
      setState(() {});
    } else {
      isButtonEnable = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final internetConnectionStatus =
        ref.watch(internetConnectionStatusProvider);
    return internetConnectionStatus ==
            const AsyncValue.data(InternetConnectionStatus.disconnected)
        ? const NoInternetScreen()
        : Scaffold(
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
                                backgroundColor: Colors.grey,
                                backgroundImage: AssetImage(
                                  'assets/gb.png',
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
                      style: authScreensubTitleStyle().copyWith(
                          color: const Color.fromRGBO(5, 31, 50, 0.6)),
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
                      textCapitalization: TextCapitalization.words,
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
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 12, 0, 0)),
                      cursorWidth: 1.2,
                      cursorColor: Colors.black,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          isButtonEnable = false;
                          errorText = 'The value is empty';
                          setState(() {});
                        } else {
                          isButtonEnable = true;
                          errorText = '';

                          setState(() {});
                        }
                      },
                      style: authScreensubTitleStyle().copyWith(fontSize: 15),
                    ),
                  ),
                  Text(
                    errorText,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: isButtonEnable
                        ? () {
                            createGroup();
                          }
                        : () {},
                    child: Container(
                      height: 54,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(41),
                          color: isButtonEnable
                              ? Colors.green
                              : const Color.fromRGBO(237, 84, 60, 1)),
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
                ],
              ),
            ),
          );
  }
}
