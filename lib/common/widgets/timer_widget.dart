import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with TickerProviderStateMixin {
  int _counter = 0;
  AnimationController? _controller;
  bool _timerStopped = false;
  int? levelClock;

  // ignore: unused_element
  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_controller!.isAnimating) {
        _controller!.stop();
        _timerStopped = true;
      } else {
        _controller!.forward(from: 0);
        _timerStopped = false;
      }
    });
  }

  // ignore: unused_element
  void _endTimer() {
    setState(() {
      if (_controller!.isAnimating) {
        _controller!.stop();
        _timerStopped = true;
        levelClock = _counter;
      }
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 999999),
    );

    _controller!.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Countdown(
      animation: StepTween(
        begin: 0,
        end: 999999,
      ).animate(_controller!),
      timerStopped: _timerStopped,
      levelClock: levelClock,
    );
  }
}

// ignore: must_be_immutable
class Countdown extends AnimatedWidget {
  Countdown({
    Key? key,
    required this.animation,
    required this.timerStopped,
    required this.levelClock,
  }) : super(key: key, listenable: animation);

  Animation<int> animation;
  bool timerStopped;
  int? levelClock;

  @override
  build(BuildContext context) {
    Duration clockTimer;
    if (timerStopped) {
      clockTimer = Duration(seconds: levelClock!);
    } else {
      clockTimer = Duration(seconds: animation.value);
    }

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      timerText,
      style: const TextStyle(
        fontSize: 40,
        color: Color.fromRGBO(118, 112, 109, 1),
      ),
    );
  }
}
