import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
  }

  void sentTextMessage() {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sentTextMessage(
          context,
          _messageController.text.trim(),
          widget.recieverUserId,
          widget.isGroupChat);
      print("123456${_messageController.text.toString()}");
      setState(() {
        _messageController.text = '';
        isShowSendButton = false;
      });
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
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
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
                  fillColor: mobileChatBoxColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: toggleEmojiKeyBoardContainer,
                            child: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.gif,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
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
            Padding(
              padding: const EdgeInsets.only(right: 5, left: 5),
              child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue,
                  child: GestureDetector(
                    onTap: sentTextMessage,
                    child: Icon(
                      isShowSendButton ? Icons.send : Icons.mic,
                      color: Colors.white,
                    ),
                  )),
            ),
          ],
        ),
        isShowEmojiContainer
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                    });
                    if (!isShowSendButton) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    }
                  },
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
