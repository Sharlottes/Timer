import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timer/subtimer.dart';

class MainTimerPage extends StatefulWidget {
  const MainTimerPage({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() => _MainTimerPageState();
}

class _MainTimerPageState extends State<StatefulWidget> {
  double _panelTop = 0;
  final SubTimerPage _currentPage = SubTimerPage.createInstance();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        _currentPage,
        Positioned(
          top: min(MediaQuery.of(context).size.height-125, max(130, _panelTop)),
          child: GestureDetector(
            onVerticalDragUpdate: (details) => setState(() {
              _panelTop = min(MediaQuery.of(context).size.height-125-MediaQuery.of(context).size.height/3.5, max(130, _panelTop + details.delta.dy));
            }),
            child: SizedBox(
              height: MediaQuery.of(context).size.height/3.5,
              child: ClipRRect( //Timer
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: (SubTimerPage.of(context) as SubTimerPageState).buildButtons(),
                )
              )
            )
          )
        )
      ]
    );
  }
}

String formatTime(Duration duration, {onlyMicro = false, all = false}) {
  var microseconds = duration.inMicroseconds;

  int hours = microseconds ~/ Duration.microsecondsPerHour;
  microseconds = microseconds.remainder(Duration.microsecondsPerHour);

  if (microseconds < 0) microseconds = -microseconds;

  int minutes = microseconds ~/ Duration.microsecondsPerMinute;
  microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

  var minutesPadding = minutes < 10 ? "0" : "";

  int seconds = microseconds ~/ Duration.microsecondsPerSecond;
  microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

  var secondsPadding = seconds < 10 ? "0" : "";
  var paddedMicroseconds = microseconds.toString().substring(0,max(0, microseconds.toString().length-4)).padLeft(2, "0");

  if(all) {
    return "${hours>0?"$hours:":""}$minutesPadding$minutes:$secondsPadding$seconds.$paddedMicroseconds";
  }
  if(onlyMicro) return paddedMicroseconds;
  return "${hours>0?"$hours : ":""}$minutesPadding$minutes : "
      "$secondsPadding$seconds";
}