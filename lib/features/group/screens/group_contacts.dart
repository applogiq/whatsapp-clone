import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/screens/edit_profile_picture_screen.dart';
import 'package:whatsapp_ui/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_ui/features/chat/widgets/custome_switch.dart';
import 'package:whatsapp_ui/features/group/screens/add_contacts.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

class GroupContactsScreens extends ConsumerStatefulWidget {
  const GroupContactsScreens({
    Key? key,
    required this.memberList,
    required this.members,
    required this.profilePic,
    required this.name,
    required this.membersId,
    required this.groupId,
  }) : super(key: key);
  final String profilePic;
  final String name;
  final String members;
  final int membersId;
  final List memberList;
  final String groupId;

  @override
  ConsumerState<GroupContactsScreens> createState() =>
      _GroupContactsScreensState();
}

class _GroupContactsScreensState extends ConsumerState<GroupContactsScreens> {
  File? image;

  selectImage() async {
    image = await pickImageFromGallery(context);
    if (image != null) {
      return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditprofilePicture(
                    groupId: widget.groupId,
                    isGroupprofile: true,
                    editImage: image!,
                  )));
    } else {
      // User canceled the image selection
      return null;
    }
  }

  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  deleteStringList(String documentId, String newValue) async {
    final collectionRef = FirebaseFirestore.instance.collection('groups');
    final documentRef = collectionRef.doc(documentId);

    final snapshot = await documentRef.get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final list = List<String>.from(data['membersUid']);

      list.remove(newValue);

      await documentRef.update({'membersUid': list});
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MobileLayoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // leading:Icon(Icons.arrow_back) ,
          actions: [InkWell(onTap: () {}, child: const Icon(Icons.more_vert))],
        ),
        backgroundColor: const Color.fromARGB(255, 241, 240, 240),
        body: SafeArea(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            color: whiteColor,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(widget.profilePic),
                            radius: 60,
                          ),
                          InkWell(
                            onTap: selectImage,
                            child: const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Center(
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Iconsax.logout5,
                            color: buttonColor,
                          ),
                          const HorizontalBox(width: 8),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("Alert"),
                                        content: const Text(
                                            "Are you sure you want to leave this group"),
                                        actions: [
                                          Container(
                                              color: buttonColor,
                                              padding: const EdgeInsets.all(10),
                                              child: InkWell(
                                                onTap: () {
                                                  print(FirebaseAuth.instance
                                                      .currentUser!.uid);
                                                  deleteStringList(
                                                      widget.groupId,
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid);
                                                  print(
                                                      "FirebaseAuth.instance .currentUser!.uid");
                                                },
                                                child: const Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ))
                                        ],
                                      ));
                            },
                            child: Text(
                              "Exit group",
                              style: authScreensubTitleStyle()
                                  .copyWith(color: buttonColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  widget.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const VerticalBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "${widget.members}  Participants",
                    style: authScreensubTitleStyle(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddGroupContacts(
                                  groupId: widget.groupId,
                                )));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: buttonColor,
                    child: Text(
                      "Add Participants",
                      style: authScreensubTitleStyle()
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            width: double.maxFinite,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const VerticalBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.notification5,
                        color: Color.fromRGBO(164, 159, 157, 1),
                      ),
                      const HorizontalBox(width: 13),
                      Text(
                        "Mute notifications",
                        style: authScreensubTitleStyle().copyWith(
                            color: const Color.fromRGBO(27, 16, 11, 1)),
                      ),
                      const Spacer(),
                      CustomSwitch(
                          // notificationTitles: "notificationTitles",
                          buttonValues: false,
                          onChanged: (value) {})
                    ],
                  ),
                  const VerticalBox(height: 12),
                  Row(
                    children: [
                      const HorizontalBox(width: 13),
                      const Icon(
                        Iconsax.volume_high5,
                        color: Color.fromRGBO(164, 159, 157, 1),
                      ),
                      Text(
                        "Custom notifications",
                        style: authScreensubTitleStyle().copyWith(
                            color: const Color.fromRGBO(27, 16, 11, 1)),
                      ),
                    ],
                  ),
                  const VerticalBox(height: 20),
                ],
              ),
            ),
          ),
          const VerticalBox(height: 12),
          Expanded(
            child: Container(
              color: whiteColor,
              child: ListView.builder(
                itemCount: widget.memberList.length,
                itemBuilder: (context, index) {
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: fireStore
                        .collection('users')
                        .doc(widget.memberList[index])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      } else if (snapshot.hasData && snapshot.data != null) {
                        var name = snapshot.data!.data()!['name'];
                        var profilePicture =
                            snapshot.data!.data()!['profilePic'];
                        var uids = snapshot.data!.data()!['uid'];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MobileChatScreen(
                                        isGroupChat: false,
                                        name: name,
                                        uid: uids,
                                        profileImage: profilePicture)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(profilePicture),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: authScreenheadingStyle().copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text("Error occurred");
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ])));
  }
}





// class GroupContactsScreens extends ConsumerWidget {
//   const GroupContactsScreens({
//     Key? key,
//     required this.memberList,
//     required this.members,
//     required this.profilePic,
//     required this.name,
//     required this.membersId,
//     required this.groupId,
//   }) : super(key: key);
//   final String profilePic;
//   final String name;
//   final String members;
//   final int membersId;
//   final List memberList;
//   final String groupId;
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
   
//   }

//   // StreamBuilder<List<model.Group>>(
//   //   stream: ref.watch(chatControllerProvider).chatGroups(),
//   //   builder: (context, snapshot) {
//   //     if (snapshot.connectionState == ConnectionState.waiting) {
//   //       return const Loader();
//   //     } else if (snapshot.hasError) {
//   //       return const Center(
//   //         child: Text("Error occurred"),
//   //       );
//   //     } else {
//   //       print(
//   //         snapshot.data![0].membersUid.length,
//   //       );
//   //       if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//   //         return Expanded(
//   //           child: ListView.builder(
//   //             scrollDirection: Axis.vertical,
//   //             physics: const BouncingScrollPhysics(),
//   //             itemCount: int.parse(members),
//   //             shrinkWrap: true,
//   //             itemBuilder: (context, index) {
//   //               print(int.parse(members).toString());
//   //               print(membersId);
//   //               var groupData = snapshot.data![index];
//   //               if (index >= groupData.membersUid.length) {
//   //                 return const SizedBox(); // Skip rendering if index is out of range
//   //               }
//   //               var memberUid = groupData.membersUid[index];

//   //               return StreamBuilder<
//   //                   DocumentSnapshot<Map<String, dynamic>>>(
//   //                 stream: fireStore
//   //                     .collection('users')
//   //                     .doc(memberUid)
//   //                     .snapshots(),
//   //                 builder: (context, snapshot) {
//   //                   if (snapshot.connectionState ==
//   //                       ConnectionState.waiting) {
//   //                     return const Loader();
//   //                   } else if (snapshot.hasData &&
//   //                       snapshot.data != null) {
//   //                     var name = snapshot.data!.data()!['name'];
//   //                     var profilePicture =
//   //                         snapshot.data!.data()!['profilePic'];

//   //                     return InkWell(
//   //                       onTap: () {
//   //                         Navigator.push(
//   //                             context,
//   //                             MaterialPageRoute(
//   //                                 builder: (context) =>
//   //                                     MobileChatScreen(
//   //                                         isGroupChat: false,
//   //                                         name: name,
//   //                                         uid: memberUid,
//   //                                         profileImage: profilePic)));
//   //                       },
//   //                       child: Padding(
//   //                         padding: const EdgeInsets.symmetric(
//   //                             vertical: 12),
//   //                         child: ListTile(
//   //                           leading: Container(
//   //                             height: 50,
//   //                             width: 50,
//   //                             decoration: BoxDecoration(
//   //                               borderRadius:
//   //                                   BorderRadius.circular(12),
//   //                               image: DecorationImage(
//   //                                 image: NetworkImage(profilePicture),
//   //                                 fit: BoxFit.cover,
//   //                               ),
//   //                             ),
//   //                           ),
//   //                           title: Text(
//   //                             name,
//   //                             style: authScreenheadingStyle()
//   //                                 .copyWith(
//   //                                     fontWeight: FontWeight.w600,
//   //                                     fontSize: 14),
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     );
//   //                   } else if (snapshot.hasError) {
//   //                     return const Text("Error occurred");
//   //                   } else {
//   //                     return const CircularProgressIndicator();
//   //                   }
//   //                 },
//   //               );
//   //             },
//   //           ),
//   //         );
//   //       } else {
//   //         return const Center(
//   //           child: CircularProgressIndicator(),
//   //         );
//   //       }
//   //     }
//   //   },
//   // ),
// }
