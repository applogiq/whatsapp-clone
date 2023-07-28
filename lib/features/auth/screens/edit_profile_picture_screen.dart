import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/repositories/common_firebase_storage_repositor.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';

class EditprofilePicture extends ConsumerStatefulWidget {
  const EditprofilePicture({
    Key? key,
    required this.editImage,
    required this.isGroupprofile,
    this.groupId = "",
  }) : super(key: key);

  final File editImage;
  final bool isGroupprofile;
  final String groupId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditprofilePictureState();
}

class _EditprofilePictureState extends ConsumerState<EditprofilePicture> {
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile Picture",
          style: authScreenheadingStyle(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: Colors.red,
              child: Image.file(widget.editImage),
            ),
            const VerticalBox(height: 30),
            InkWell(
              onTap: widget.isGroupprofile
                  ? () async {
                      setState(() {
                        isSaving = true; // Set loading state to true
                      });

                      var myimage = await ref
                          .read(commonFirebaseStorageRepositoryProvider)
                          .storeFileToFirebase(
                              'group/${widget.groupId}', widget.editImage);
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(widget.groupId)
                          .update({'groupPic': myimage});
                      Navigator.pop(context);
                    }
                  : () async {
                      setState(() {
                        isSaving = true; // Set loading state to true
                      });

                      var myimage = await ref
                          .read(commonFirebaseStorageRepositoryProvider)
                          .storeFileToFirebase(
                            'profilePic/${FirebaseAuth.instance.currentUser!.uid}',
                            widget.editImage,
                          );
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({'profilePic': myimage});

                      Navigator.pop(context);
                    },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: buttonColor),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          // strokeWidth: 2,
                        ) // Show the circular progress indicator
                      : Text(
                          "Save",
                          style: authScreensubTitleStyle()
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
