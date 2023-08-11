import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/features/chat/widgets/video_player_page.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late CachedVideoPlayerController videoPlayerController;
  bool isPlay = false;
  @override
  void initState() {
    super.initState();
    videoPlayerController = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CachedVideoPlayer(videoPlayerController),
          Align(
              alignment: Alignment.center,
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PlayerPage(videoUrl: widget.videoUrl)));
                    if (isPlay) {
                      videoPlayerController.pause();
                    } else {}
                  },
                  icon: Icon(
                    isPlay ? Icons.pause : Icons.play_circle,
                    color: Colors.white,
                    size: 50,
                  )))
        ],
      ),
    );
  }
}
