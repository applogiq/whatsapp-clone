import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/model/group.dart' as model;

class GroupContactsScreens extends ConsumerWidget {
  const GroupContactsScreens({
    Key? key,
    required this.memberList,
    required this.members,
    required this.profilePic,
    required this.name,
    required this.membersId,
  }) : super(key: key);
  final String profilePic;
  final String name;
  final String members;
  final int membersId;
  final List memberList;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios_new)),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(profilePic),
                    radius: 80,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text("$members Members")),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  height: 5,
                  thickness: 3,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            StreamBuilder<List<model.Group>>(
              stream: ref.watch(chatControllerProvider).chatGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error occurred"),
                  );
                } else {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        itemCount: snapshot.data![0].membersUid.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var groupData = snapshot.data![0];
                          if (index >= groupData.membersUid.length) {
                            return const SizedBox(); // Skip rendering if index is out of range
                          }
                          var memberUid = groupData.membersUid[index];

                          return StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            stream: fireStore
                                .collection('users')
                                .doc(memberUid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Loader();
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                var name = snapshot.data!.data()!['name'];
                                var profilePicture =
                                    snapshot.data!.data()!['profilePic'];

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(profilePicture),
                                  ),
                                  title: Text(name),
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
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
