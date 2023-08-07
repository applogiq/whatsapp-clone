import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/shimmer/shimmer.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/call/call_pickup_screen.dart';
import 'package:whatsapp_ui/features/call/controller/call_controller.dart';
import 'package:whatsapp_ui/features/chat/model/chat_model.dart';
import 'package:whatsapp_ui/features/chat/screens/individual_chat_profile.dart';
import 'package:whatsapp_ui/features/chat/widgets/bottom_chat_field.dart';
import 'package:whatsapp_ui/features/group/screens/group_contacts.dart';
import 'package:whatsapp_ui/model/user_model.dart';
import 'package:whatsapp_ui/features/chat/widgets/chat_list.dart';

class MobileChatScreen extends ConsumerStatefulWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profileImage;
  final String members;
  final int? memberId;
  final List? memberIdList;
  const MobileChatScreen({
    Key? key,
    this.memberIdList,
    this.members = "",
    this.memberId,
    required this.isGroupChat,
    required this.name,
    required this.uid,
    required this.profileImage,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MobileChatScreenState();
}

class _MobileChatScreenState extends ConsumerState<MobileChatScreen> {
  void makeCall(
    WidgetRef ref,
    BuildContext context,
    bool isAudioCall,
  ) {
    ref.read(callControllerprovider).makeCall(context, widget.name, widget.uid,
        widget.profileImage, widget.isGroupChat, isAudioCall);
  }

  var datastream;
  @override
  void initState() {
    datastream = ref.read(authControllerProvider).userDataById(widget.uid);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CallPickUpScreen(
      callerId: widget.uid,
      receiverId: FirebaseAuth.instance.currentUser!.uid,
      scaffold: Scaffold(
        backgroundColor: const Color(0xffFAFAFA),
        appBar: AppBar(
          shadowColor: const Color.fromRGBO(5, 31, 50, 0.06),

          automaticallyImplyLeading: false,

          titleSpacing: 0,
          title: widget.isGroupChat
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupContactsScreens(
                            members: widget.members,
                            profilePic: widget.profileImage,
                            name: widget.name,
                            membersId: widget.memberId!,
                            memberList: widget.memberIdList!,
                            groupId: widget.uid),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const HorizontalBox(width: 10),
                      InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back)),
                      const HorizontalBox(width: 10),
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.profileImage),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              widget.name,
                              style: authScreenheadingStyle()
                                  .copyWith(fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(25),
                              child: StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  final userList = snapshot.data?.docs ?? [];

                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: widget.memberIdList!.length,
                                    itemBuilder: (context, index) {
                                      final memberId =
                                          widget.memberIdList![index];
                                      final user = userList.firstWhere(
                                          (userDoc) => userDoc.id == memberId);
                                      if (user != null) {
                                        if (user.data().containsKey('name')) {
                                          return Text(
                                            "${user['name']} ,",
                                            style: authScreensubTitleStyle(),
                                          );
                                        } else {
                                          return Text(
                                            'error',
                                            style: authScreensubTitleStyle(),
                                          );
                                        }
                                      } else {
                                        return Text(
                                          'error',
                                          style: authScreensubTitleStyle(),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      const Icon(Icons.more_vert)
                    ],
                  ),
                )
              : StreamBuilder<UserModel>(
                  stream: datastream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return appbarShimmer(context);
                    }

                    return Row(
                      children: [
                        const HorizontalBox(width: 10),
                        InkWell(
                            onTap: () async {
                              // await FirebaseFirestore.instance
                              //     .collection("users")
                              //     .doc(uid)
                              //     .update({'isTyping': false});
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back)),
                        const HorizontalBox(width: 10),
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.profileImage),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 120,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            IndividualChatProfileScreen(
                                              userId: widget.uid,
                                            )));
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name,
                                    style: authScreenheadingStyle().copyWith(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  // const VerticalBox(height: 4),
                                  const HorizontalBox(width: 5),
                                  Text(
                                      snapshot.data!.isOnline
                                          ? 'Online'
                                          : snapshot.data!.lastSeen,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.normal,
                                        color: Color.fromRGBO(118, 112, 109, 1),
                                      )),
                                  // StreamBuilder<Object>(
                                  //   stream: FirebaseFirestore.instance
                                  //       .collection('users')
                                  //       .doc(widget.uid)
                                  //       .collection('chats')
                                  //       .doc(FirebaseAuth.instance.currentUser!
                                  //           .uid) // Replace chatRoomId with the appropriate identifier for the current chat room
                                  //       .snapshots(),
                                  //   builder: (context, snapshots) {
                                  //     if (snapshots.connectionState ==
                                  //         ConnectionState.waiting) {
                                  //       return const Text("");
                                  //     }
                                  //     if (!snapshots.hasData ||
                                  //         snapshots.data == null) {
                                  //       return const Text(
                                  //           ""); // Return an empty widget or show an error message
                                  //     }

                                  //     var data = snapshots.data!
                                  //         as DocumentSnapshot<
                                  //             Map<String, dynamic>>;

                                  //     if (data.exists) {
                                  //       return data['isTyping'] == true
                                  //           ? Text(
                                  //               "Typing....",
                                  //               style:
                                  //                   authScreensubTitleStyle(),
                                  //             )
                                  //           : Text(
                                  //               snapshot.data!.isOnline
                                  //                   ? 'Online'
                                  //                   : snapshot.data!.lastSeen,
                                  //               style: const TextStyle(
                                  //                 fontSize: 10,
                                  //                 overflow:
                                  //                     TextOverflow.ellipsis,
                                  //                 fontWeight: FontWeight.normal,
                                  //                 color: Color.fromRGBO(
                                  //                     118, 112, 109, 1),
                                  //               ),
                                  //             );
                                  //     } else {
                                  //       // Handle the case when the document doesn't exist
                                  //       return Text(
                                  //           snapshot.data!.isOnline
                                  //               ? 'Online'
                                  //               : snapshot.data!.lastSeen,
                                  //           style: const TextStyle(
                                  //             fontSize: 10,
                                  //             overflow: TextOverflow.ellipsis,
                                  //             fontWeight: FontWeight.normal,
                                  //             color: Color.fromRGBO(
                                  //                 118, 112, 109, 1),
                                  //           ));
                                  //     }
                                  //   },
                                  // ),

                                  const VerticalBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: () async {
                              UserModel? user;

                              Future<UserModel?> getCurrentUserData() async {
                                var userdata = await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(widget.uid)
                                    .get();

                                if (userdata.data() != null) {
                                  try {
                                    user = UserModel.fromMap(userdata.data()!);
                                  } catch (e) {
                                    print(e.toString());
                                  }
                                }
                                return user;
                              }

                              user = await getCurrentUserData();
                              PushNotification().sendPushNotification(
                                  snapshot.data!.deviceToken,
                                  "${user!.name} is Calling you",
                                  "New Message",
                                  context);
                              makeCall(ref, context, true);
                            },
                            child: const Icon(Iconsax.call5)),
                        const HorizontalBox(width: 15),
                        InkWell(
                            onTap: () => makeCall(ref, context, false),
                            child: const Icon(Iconsax.video5)),
                        const HorizontalBox(width: 15),
                        const Icon(Icons.more_vert),
                        const HorizontalBox(width: 5),
                      ],
                    );
                  }),
          centerTitle: false,
          // actions: [
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                  receiverUserid: widget.uid, isGroupChat: widget.isGroupChat),
            ),
            // StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            //     stream: FirebaseFirestore.instance
            //         .collection('users')
            //         .doc(FirebaseAuth.instance.currentUser!.uid)
            //         .snapshots(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const SizedBox.shrink();
            //       }
            //       if (!snapshot.hasData || snapshot.data == null) {
            //         return const SizedBox
            //             .shrink(); // Return an empty widget or show an error message
            //       }
            //       var data = snapshot.data!;
            //       return data['isTyping'] == true
            //           ? const TypingIndicator(showIndicator: true)
            //           : const SizedBox.shrink();
            //     }),
            BottomChatField(
              memberId: widget.isGroupChat ? widget.memberIdList! : [],
              recieverUserId: widget.uid,
              isGroupChat: widget.isGroupChat,
            ),
          ],
        ),
      ),
    );
  }
}

Shimmer appbarShimmer(BuildContext context) {
  SizeConfig().init(context);
  return Shimmer.fromColors(
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
          const CircleAvatar(),
          const HorizontalBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: getProportionateScreenWidth(100),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                height: getProportionateScreenHeight(10),
                // width: getProportionateScreenWidth(120),
              ),
              const VerticalBox(height: 15),
              Container(
                width: getProportionateScreenWidth(200),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                height: getProportionateScreenHeight(10),
                //  width: getProportionateScreenWidth(120),
              ),
            ],
          ),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!);
}
