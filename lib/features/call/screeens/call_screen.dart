import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/timer_widget.dart';
import 'package:whatsapp_ui/config/agora_config.dart';
import 'package:whatsapp_ui/features/call/controller/call_controller.dart';
import 'package:whatsapp_ui/model/call.dart';
// ignore: library_prefixes
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalview;
// ignore: library_prefixes
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;
  final bool isAudioCall;
  final String callerImage;
  final String callerName;

  const CallScreen({
    super.key,
    required this.call,
    required this.isGroupChat,
    required this.channelId,
    required this.isAudioCall,
    required this.callerImage,
    required this.callerName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  // AgoraClient? client;0
  late RtcEngine engine;
  bool loading = false;
  List remoteUIDs = [];
  double xPosition = 0;
  double yPosition = 0;
  bool muted = false;
  bool callEnded = false;
  String baseUrl = 'http://192.168.29.94:8080';
  @override
  void initState() {
    super.initState();

    initAgora();
  }

  Future<void> initAgora() async {
    setState(() {
      loading = true;
    });
    engine =
        await RtcEngine.createWithContext(RtcEngineContext(AgoraConfig.appId));
    await [Permission.microphone, Permission.camera].request();
    widget.isAudioCall
        ? await engine.enableAudio()
        : await engine.enableVideo();
    await engine.setChannelProfile(ChannelProfile.Communication);
    engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {},
      userJoined: (uid, elapsed) {
        setState(() {
          remoteUIDs.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          remoteUIDs.remove(uid);
          Navigator.pop(context);
        });
      },
    ));
    await engine.joinChannel(null, widget.channelId, null, 0).then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    engine.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (loading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Stack(
              children: [
                Center(
                  child: renderRemoteView(context),
                ),
                Container(
                  margin: const EdgeInsets.all(15),
                  child: Stack(
                    children: [
                      Positioned(
                          top: yPosition,
                          left: xPosition,
                          child: GestureDetector(
                            onPanUpdate: (tapinfo) {
                              setState(() {
                                xPosition += tapinfo.delta.dx;
                                yPosition += tapinfo.delta.dy;
                              });
                            },
                            child: SizedBox(
                                height: 200,
                                width: 130,
                                child: widget.isAudioCall
                                    ? const SizedBox.shrink()
                                    : const RtcLocalview.SurfaceView()),
                          )),
                      _toolBar(),
                    ],
                  ),
                )
              ],
            )),
    );
  }

  Widget renderRemoteView(context) {
    if (remoteUIDs.isNotEmpty) {
      if (remoteUIDs.length == 1) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            widget.isAudioCall
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(widget.callerImage),
                      ),
                      const VerticalBox(height: 30),
                      Text(
                        widget.callerName,
                        style: authScreenheadingStyle(),
                      ),
                      const VerticalBox(height: 30),
                      const TimerWidget(),
                    ],
                  )
                : const SizedBox.shrink(),
            RtcRemoteView.SurfaceView(
                uid: remoteUIDs[0], channelId: widget.channelId),
          ],
        );
      } else if (remoteUIDs.length == 2) {
        return Column(
          children: [
            RtcRemoteView.SurfaceView(
                uid: remoteUIDs[1], channelId: widget.channelId),
            RtcRemoteView.SurfaceView(
                uid: remoteUIDs[2], channelId: widget.channelId)
          ],
        );
      } else {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 11 / 20,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10),
              itemCount: remoteUIDs.length,
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10)),
                  child: RtcRemoteView.SurfaceView(
                      uid: remoteUIDs[index], channelId: widget.channelId),
                );
              }),
        );
      }
    } else {
      return const Text("Waiting for other users");
    }
  }

  Widget _toolBar() {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RawMaterialButton(
            onPressed: () {
              onTogglrMuted();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            elevation: 2,
            fillColor: (muted) ? Colors.blue : Colors.white,
            child: Icon(
              (muted) ? Icons.mic_off : Icons.mic,
              color: (muted) ? Colors.white : Colors.blue,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              oncallEnd();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            elevation: 2,
            fillColor: Colors.redAccent,
            child: const Icon(Icons.call_end, color: Colors.white),
          ),
          RawMaterialButton(
            onPressed: () {
              onSwitchCamera();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            elevation: 2,
            fillColor: Colors.white,
            child: const Icon(Icons.switch_camera, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void onTogglrMuted() {
    setState(() {
      muted = !muted;
    });
    engine.muteLocalAudioStream(muted);
  }

  void oncallEnd() {
    engine.leaveChannel().then((value) {
      ref
          .read(callControllerprovider)
          .endCall(widget.call.callerId, widget.call.receiverId, context);

      Navigator.pop(context);
    });
  }

  void onSwitchCamera() {
    engine.switchCamera();
  }
}
