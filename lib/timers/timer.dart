import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../util.dart';
import 'times.dart';

final recordList = <Duration>[];

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}): super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool _timerPlaying = false, _stopped = true;
  Ticker? _timer;

  void _startTimer(BuildContext context) {
    setState((){
      if(!_timerPlaying) _timer?.start();
      _timerPlaying = true;
      _stopped = false;
    });
  }

  void _stopTimer() {
    setState((){
      _stopped = true;
    });
  }

  void _resetTimer(BuildContext context) {
    recordList.clear();
    setState(() {
      context.read<Times>().time = const Duration();
      _timer?.stop();
      _timerPlaying = false;
    });
  }

  void _configTimer(BuildContext context) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (_) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
                top: false,
                child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hms,
                    initialTimerDuration: context.read<Times>().time,
                    onTimerDurationChanged: (Duration newDuration) => setState(() => context.read<Times>().time = newDuration)
                ),
            ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
      _timer ??= Ticker((duration) {
          if(!_timerPlaying) return;
          Times times = context.read<Times>();
          if(mounted) {
             setState((){
                times.time = times.initTime-duration;
            });
          } else {
            times.time = times.initTime-duration;
          }
      });

      return Align(
          alignment: Alignment.center,
          child: Column(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                      onTap: ()=>_startTimer(context),
                      onLongPress: ()=>_configTimer(context),
                      child: ClipRRect( //Timer
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              color: Colors.purple.shade400.withOpacity(0.5*0.5),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  child: Column(children: [
                                    Text.rich(
                                      TextSpan(
                                          text: formatTime(context.watch<Times>().time),
                                          children: [
                                            TextSpan(
                                                text: ' . ${formatTime(context.watch<Times>().time, onlyMicro: true)}',
                                                style: const TextStyle(fontSize: 26)
                                            )
                                          ]
                                      ),
                                      style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.center,
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text.rich(
                                                  TextSpan(
                                                      text: "시작 시간    ",
                                                      children: [TextSpan(text: formatTime(context.watch<Times>().initTime, all: true)),]
                                                  ),
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                              )
                                            ])
                                    )
                                  ])
                              )
                          )
                      )
                  )
              ),
              Expanded(
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 75),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: !_stopped&&_timerPlaying ?
                                TextButton(
                                    onPressed: _stopTimer,
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent)),
                                    child: const Text('중지', style: TextStyle(color: Colors.black))
                                )
                                    : TextButton(
                                    onPressed: () => _startTimer(context),
                                    child: const Text('시작', style: TextStyle(color: Colors.black))
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextButton(onPressed: () => _resetTimer(context), child: const Text('초기화', style: TextStyle(color: Colors.black)))
                            )
                          ],
                        ),
                      )
                  )
              )
          ])
      );
  }

  @override
  Column buildButtons() {
    return Column(children: [
      !_stopped ?
      Expanded(child: IconButton(onPressed: _stopTimer, icon: const Icon(Icons.pause_circle), iconSize: 36))
          : Expanded(child: IconButton(onPressed: ()=>_startTimer(context), icon: const Icon(Icons.play_circle), iconSize: 36)),
      Expanded(child: IconButton(onPressed: ()=>_configTimer(context), icon: const Icon(Icons.settings_rounded), iconSize: 36)),
      Expanded(child: IconButton(onPressed: ()=>_resetTimer(context), icon: const Icon(Icons.cancel_rounded), iconSize: 36)),
    ]);
  }
}