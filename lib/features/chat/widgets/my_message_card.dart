import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/features/chat/widgets/display_text_image_gif.dart';

class MyMessageCard extends StatefulWidget {
  final String message;
  final String date;
  final String receiverId;
  final String messageId;
  final MessageEnum type;
  final bool isSeen;
  final bool isGroupChat;

  const MyMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.isSeen,
    required this.receiverId,
    required this.messageId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  State<MyMessageCard> createState() => _MyMessageCardState();
}

class _MyMessageCardState extends State<MyMessageCard> {
  bool isSelected = false;
  deleteMessageList(String receiverUserId, String messageId) async {
    widget.isGroupChat
        ? await FirebaseFirestore.instance
            .collection("groups")
            .doc(receiverUserId)
            .collection('chats')
            .doc(messageId)
            .delete()
        : await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('chats')
            .doc(receiverUserId)
            .collection('messages')
            .doc(messageId)
            .delete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print("Dei");
        print(widget.receiverId);
        print(widget.messageId);
        setState(() {
          isSelected = true;
        });
      },
      onTap: () {
        if (isSelected) {
          setState(() {
            isSelected = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 5),
        color: isSelected ? Colors.grey : Colors.transparent,
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        color: Color.fromRGBO(237, 84, 60, 1)),

                    // margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Padding(
                        padding: isSelected
                            ? const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10,
                              )
                            : widget.type == MessageEnum.text
                                ? const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 12,
                                    bottom: 12,
                                  )
                                : const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 12,
                                    bottom: 12,
                                  ),
                        child: isSelected
                            ? InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: const Text("Alert"),
                                            content: const Text(
                                                "Are you sure you want to delete this message"),
                                            actions: [
                                              Container(
                                                  color: buttonColor,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "No",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )),
                                              Container(
                                                  color: buttonColor,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: InkWell(
                                                    onTap: () {
                                                      deleteMessageList(
                                                          widget.receiverId,
                                                          widget.messageId);
                                                      Navigator.pop(context);
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
                                child: const Icon(Icons.delete))
                            : DisplayTextImageGIF(
                                message: widget.message,
                                type: widget.type,
                                textColor:
                                    const Color.fromRGBO(255, 255, 255, 1),
                              )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      widget.isGroupChat
                          ? const SizedBox.shrink()
                          : Icon(widget.isSeen ? Icons.done_all : Icons.done,
                              size: 16,
                              color: widget.isSeen
                                  ? const Color.fromRGBO(237, 84, 60, 1)
                                  : Colors.grey),
                      Text(
                        widget.date,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(164, 159, 157, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
