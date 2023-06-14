import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/features/chat/widgets/attachment_components.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  const BottomChatField({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  bool isShowEmojiContainer = false;
  final TextEditingController _messageController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isContainerVisible = false;

  void isShownContainer() {
    setState(() {
      isContainerVisible = !isContainerVisible;
    });
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyBoard() => focusNode.requestFocus();
  void hideKeyBoard() => focusNode.unfocus();

  void toggleEmojiKeyBoardContainer() {
    if (isShowEmojiContainer) {
      showKeyBoard();
      hideEmojiContainer();
    } else {
      hideKeyBoard();
      showEmojiContainer();
    }
  }

  @override
  void initState() {
    super.initState();

    sentTextMessage();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  setupFirebaseMessaging(String head, String sub) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received message while app is in the foreground: ${message.notification}');
      showNotification(head, sub);
    });
  }

  Future<void> showNotification(String head, String sub) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(0, head, sub, platformChannelSpecifics,
        payload: 'foreground_notification');
  }

  void sentTextMessage() {
    if (mounted) {
      if (isShowSendButton) {
        ref.read(chatControllerProvider).sentTextMessage(
            context,
            _messageController.text.trim(),
            widget.recieverUserId,
            widget.isGroupChat);

        setState(() {
          _messageController.text = '';
          isShowSendButton = false;
        });
      }
    }
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    ref.read(chatControllerProvider).sentFileMessage(
        context, file, widget.recieverUserId, messageEnum, widget.isGroupChat);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
    setState(() {
      isContainerVisible = false;
    });
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
    setState(() {
      isContainerVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          isContainerVisible
              ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(27, 16, 11, 0.08),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 40),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => selectImage(),
                            child: const AttachmentWidgets(
                                icons: Iconsax.gallery5,
                                color: Color.fromRGBO(229, 217, 243, 1),
                                title: 'Image'),
                          ),
                          // HorizontalBox(width: width)
                          InkWell(
                            onTap: selectVideo,
                            child: const AttachmentWidgets(
                                icons: Iconsax.video5,
                                color: Color.fromRGBO(183, 199, 242, 1),
                                title: 'Video'),
                          ),
                          InkWell(
                            onTap: () {
                              // sendPushNotification(
                              //     'dSuRkgdFStK5TCSmwmRdPB:APA91bF59P6A1gyJb-QGU-WAE8IJUtKhNedHzklPEZcSMyc82TjlLNtd6_T5HqmOpkfSNIOpskSQA6s_Ur1DpwVr0p_RBIaK-euQme-qg3IGZcHSi9aV36mP8qv-B2HF4F_nkXXdfwuh',
                              //     'Chat App',
                              //     'ram');
                            },
                            child: const AttachmentWidgets(
                                icons: Iconsax.document_text5,
                                color: Color.fromRGBO(253, 233, 209, 1),
                                title: 'Document'),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 60,
            width: double.maxFinite,
            decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(237, 236, 235, 1),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromRGBO(255, 255, 255, 1)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => isShownContainer(),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
                      child: Icon(
                        isContainerVisible ? Icons.close : Iconsax.add,
                        color: const Color.fromRGBO(118, 112, 109, 1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      onChanged: (val) {
                        if (val.isEmpty) {
                          setState(() {
                            isShowSendButton = false;
                          });
                        } else {
                          setState(() {
                            isShowSendButton = true;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(255, 255, 255, 1),
                        suffixIcon: SizedBox(
                          width: 100,
                          // padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: selectImage,
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: selectVideo,
                                child: const Icon(
                                  Icons.attach_file,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        hintText: 'Type a message',
                        hintStyle: const TextStyle(
                            color: Color.fromRGBO(27, 16, 11, 0.6),
                            fontSize: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: sentTextMessage,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color.fromRGBO(237, 84, 60, 1),
                      child: Image.asset(
                        'assets/send_button.png',
                        height: 18,
                        width: 18,
                        color: isShowSendButton
                            ? Colors.white
                            : const Color.fromARGB(255, 215, 214, 214),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
