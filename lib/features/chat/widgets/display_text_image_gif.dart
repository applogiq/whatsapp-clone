import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/features/chat/widgets/image_view_screen.dart';
import 'package:whatsapp_ui/features/chat/widgets/video_player_item.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageEnum type;
  final Color textColor;
  const DisplayTextImageGIF(
      {super.key,
      required this.message,
      required this.type,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return type == MessageEnum.text
        ? Text(
            message,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
          )
        : type == MessageEnum.video
            ? VideoPlayerItem(
                videoUrl: message,
              )
            : InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImageViewScreen(
                                image: message,
                              )));
                },
                child: SizedBox(
                  height: 280,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: message,
                      placeholder: (context, url) => const Center(
                          child:
                              CircularProgressIndicator()), // Display loader while image is being loaded
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ));
  }
}
