import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/call/controller/call_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/custome_switch.dart';

class IndividualChatProfileScreen extends ConsumerWidget {
  const IndividualChatProfileScreen({super.key, required this.userId});
  final String userId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 240, 240),
      appBar: AppBar(
        actions: const [Icon(Icons.more_vert)],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Loader(); // Return an empty widget or show an error message
            }

            var data = snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(data['profilePic']),
                      ),
                      const VerticalBox(height: 8),
                      Text(
                        data['name'].toString(),
                        style: authScreenheadingStyle().copyWith(fontSize: 18),
                      ),
                      const VerticalBox(height: 8),
                      Text(
                        data['phoneNumber'],
                        style: authScreensubTitleStyle().copyWith(
                            color: const Color.fromRGBO(5, 31, 50, 0.8)),
                      ),
                      const VerticalBox(height: 8),
                      Text(
                        data['isOnline'] == true ? 'Online' : data['lastSeen'],
                        style: const TextStyle(
                            color: Color.fromRGBO(138, 138, 138, 1)),
                      ),
                      const VerticalBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              ref.read(callControllerprovider).makeCall(
                                  context,
                                  data['name'].toString(),
                                  data['uid'].toString(),
                                  data['profilePic'].toString(),
                                  false,
                                  true);
                            },
                            child: const Icon(
                              Icons.phone,
                              color: Color.fromRGBO(237, 84, 60, 1),
                              size: 30,
                            ),
                          ),
                          const HorizontalBox(width: 30),
                          InkWell(
                            onTap: () {
                              ref.read(callControllerprovider).makeCall(
                                  context,
                                  data['name'].toString(),
                                  data['uid'].toString(),
                                  data['profilePic'].toString(),
                                  false,
                                  false);
                            },
                            child: const Icon(
                              Icons.video_call,
                              color: Color.fromRGBO(237, 84, 60, 1),
                              size: 30,
                            ),
                          ),
                          const HorizontalBox(width: 30),
                          const Icon(
                            Iconsax.gallery5,
                            color: Color.fromRGBO(237, 84, 60, 1),
                            size: 30,
                          ),
                        ],
                      ),
                      const VerticalBox(height: 16)
                    ],
                  ),
                ),
                const VerticalBox(height: 16),
                Container(
                  width: double.maxFinite,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const VerticalBox(height: 16),
                        Text(
                          "Status",
                          style: authScreensubTitleStyle().copyWith(
                              color: const Color.fromRGBO(237, 84, 60, 1)),
                        ),
                        const VerticalBox(height: 12),
                        Text(
                          data['aboutStatus'],
                          style: authScreensubTitleStyle(),
                        ),
                        const VerticalBox(height: 16)
                      ],
                    ),
                  ),
                ),
                const VerticalBox(height: 16),
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
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    width: double.maxFinite,
                    height: 46,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 127, vertical: 12),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1.5, color: Color(0xFFF12518)),
                        borderRadius: BorderRadius.circular(41),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.dislike5,
                          color: Color(0xFFF12518),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Block',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF12518),
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalBox(height: 10)
              ],
            );
          }),
    );
  }
}
