import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/features/call/controller/call_controller.dart';
import 'package:whatsapp_ui/features/call/screeens/call_screen.dart';
import 'package:whatsapp_ui/model/call.dart';

class CallPickUpScreen extends ConsumerWidget {
  final Widget scaffold;
  final String callerId;
  final String receiverId;
  const CallPickUpScreen(
      {super.key,
      required this.scaffold,
      required this.callerId,
      required this.receiverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    late RtcEngine engine;

    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerprovider).callStream,
      builder: (context, snapshots) {
        if (snapshots.hasData && snapshots.data!.data() != null) {
          Call call =
              Call.fromMap(snapshots.data!.data() as Map<String, dynamic>);
          if (!call.hasDialled) {
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Incomming Call"),
                    const VerticalBox(height: 50),
                    CircleAvatar(
                      backgroundImage: NetworkImage(call.callerPic),
                      radius: 60,
                    ),
                    const VerticalBox(height: 50),
                    Text(
                      call.callerName,
                      style: authScreenheadingStyle(),
                    ),
                    const VerticalBox(height: 75),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            ref
                                .read(callControllerprovider)
                                .endCall(callerId, receiverId, context);
                          },
                          child: const CircleAvatar(
                            radius: 40,
                            child: Icon(Icons.call_end),
                            backgroundColor: buttonColor,
                          ),
                        ),
                        // HorizontalBox(width: 50),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CallScreen(
                                        callerName: call.callerName,
                                        callerImage: call.callerPic,
                                        isAudioCall: call.isAudioCall,
                                        call: call,
                                        isGroupChat: false,
                                        channelId: call.callId)));
                          },
                          child: const CircleAvatar(
                            radius: 40,
                            child: Icon(Icons.call),
                            backgroundColor: Colors.green,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        }
        // ca43886a41a04f25a646c5ba4e52aab6
        return scaffold;
      },
    );
  }
}
