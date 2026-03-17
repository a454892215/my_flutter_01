import 'dart:async';
import 'package:flutter/material.dart';

class CountdownWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback finish;
  final WidgetBuild childBuild;

  const CountdownWidget({
    super.key,
    required this.seconds,
    required this.finish,
    required this.childBuild,
  });

  @override
  CountdownWidgetState createState() => CountdownWidgetState();
}

typedef WidgetBuild = Widget Function(String text, String text2);

class CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  int _currentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
        } else {
          _timer.cancel();
          widget.finish();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get timerSecondsText {
    int seconds = _currentSeconds % 60;
    String secondsStr = (seconds < 10) ? '0$seconds' : seconds.toString();
    return secondsStr;
  }

  String get timerText {
    int minutes = (_currentSeconds ~/ 60);
    int seconds = _currentSeconds % 60;
    String minutesStr = (minutes < 10) ? '0$minutes' : minutes.toString();
    String secondsStr = (seconds < 10) ? '0$seconds' : seconds.toString();
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (i) => _currentSeconds - i - 1),
      builder: (context, snapshot) {
        return widget.childBuild(timerSecondsText, timerText);
      },
    );
  }
}
