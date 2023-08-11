// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerPage extends StatefulWidget {
  final String videoUrl;
  const PlayerPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Align(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller),
                      VideoPlayerControls(_controller),
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class VideoPlayerControls extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerControls(this.controller, {Key? key}) : super(key: key);

  @override
  _VideoPlayerControlsState createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
  }

  @override
  void dispose() {
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        StatefulBuilder(
          builder: (context, setState) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 200),
              child: _isPlaying
                  ? GestureDetector(
                      onTap: () {
                        widget.controller.pause();
                        setState(() {
                          _isPlaying = false;
                        });
                      },
                      child: Container(
                        color: Colors.black26,
                        child: const Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        widget.controller.play();
                        setState(() {
                          _isPlaying = true;
                        });
                      },
                      child: Container(
                        color: Colors.black26,
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
            );
          },
        ),
        GestureDetector(
          onTap: () {
            if (widget.controller.value.isPlaying) {
              widget.controller.pause();
              setState(() {
                _isPlaying = false;
              });
            } else {
              widget.controller.play();
              setState(() {
                _isPlaying = true;
              });
            }
          },
        ),
      ],
    );
  }
}
