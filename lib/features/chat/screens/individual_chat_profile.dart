import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/horizontal_box.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';

class IndividualChatProfileScreen extends StatelessWidget {
  const IndividualChatProfileScreen({super.key, required this.userId});
  final String userId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(left: 16, bottom: 100),
                //   child: Align(
                //     alignment: Alignment.topLeft,
                //     child: InkWell(
                //         onTap: () {
                //           Navigator.pop(context);
                //         },
                //         child: const Icon(Icons.arrow_back_ios_rounded)),
                //   ),
                // ),
                CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(data['profilePic']),
                ),
                const VerticalBox(height: 40),
                Text(
                  data['name'].toString(),
                  style: authScreenheadingStyle(),
                ),
                const VerticalBox(height: 16),
                Text(
                  data['phoneNumber'],
                  style: authScreensubTitleStyle(),
                ),
                const VerticalBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          data['isOnline'] == true ? Colors.green : Colors.red,
                      radius: 7,
                    ),
                    const HorizontalBox(width: 10),
                    Text(data['isOnline'] == true ? 'Online' : 'Offline'),
                  ],
                ),
                const VerticalBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 50,
                    ),
                    HorizontalBox(width: 20),
                    Icon(
                      Icons.video_call,
                      size: 50,
                    )
                  ],
                )
              ],
            );
          }),
    );
  }
}
