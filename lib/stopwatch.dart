import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:timer/maintimer.dart';
import 'package:timer/subtimer.dart';
import 'times.dart';

final recordList = <Duration>[];

class StopwatchPage extends SubTimerPage {
  const StopwatchPage({Key? key}): super(key: key);

  @override
  StopwatchPageState createState() => StopwatchPageState();

  static SubTimerPage createInstance() {
    return const StopwatchPage();
  }
}


class StopwatchPageState extends SubTimerPageState {
  bool _timerPlaying = false, _stopped = true;
  Ticker? _timer;

  void _startTimer(BuildContext context) {
    setState((){
      if(!_timerPlaying) _timer?.start();
      if(_stopped) context.read<StopWatchValue>().stopTime = 0;
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
      context.read<StopWatchValue>().stopTime = 0;
      context.read<StopWatchValue>().time = const Duration();
      _timer?.stop();
      _timerPlaying = false;
    });
  }

  void _recordTimer(BuildContext context) {
    setState(() {
      recordList.add(context.read<StopWatchValue>().time);
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
            initialTimerDuration: context.read<StopWatchValue>().time,
            onTimerDurationChanged: (Duration newDuration) {
              setState(() => context.read<StopWatchValue>().time = newDuration);
            },
          ),
        ),
      )
    );
  }

  int getAverageRecord() {
    if(recordList.isEmpty) return 0;

    int total = 0;
    for(Duration duration in recordList) {
      total += duration.inMilliseconds;
    }
    return (total/recordList.length).round();
  }

  @override
  void dispose() {
    _timer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
        create: (_)=>StopWatchValue(),
        builder: (context, _) {
          _timer ??= Ticker((duration) {
            if(!_timerPlaying) return;
            setState((){
              if (_stopped) {
                context.read<StopWatchValue>().stopTime++;
              } else {
                context.read<StopWatchValue>().time = duration;
              }
            });
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
                              color: Colors.green.shade400.withOpacity(0.5*0.5),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  child: Column(children: [
                                    Text.rich(
                                      TextSpan(
                                          text: formatTime(context.watch<StopWatchValue>().time),
                                          children: [
                                            TextSpan(
                                                text: ' . ${formatTime(context.watch<StopWatchValue>().time, onlyMicro: true)}',
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
                                                      text: "정지 기록    ",
                                                      children: [TextSpan(text: formatTime(Duration(milliseconds: context.watch<StopWatchValue>().stopTime*10), all: true)),]
                                                  ),
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                              ),
                                              Text.rich(
                                                  TextSpan(
                                                      text: "구간 평균    ",
                                                      children: [TextSpan(text: formatTime(Duration(milliseconds: getAverageRecord()), all: true)),]
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.35,
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 17),
                              child: Text(
                                '구간',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                                textAlign: TextAlign.left,
                              )
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 17),
                              child: Text(
                                '구간 기록',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                                textAlign: TextAlign.center,
                              )
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 17),
                              child: Text(
                                '전체 시간',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                                textAlign: TextAlign.right,
                              )
                          )
                        ]
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    (recordList.length+1).toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                                    textAlign: TextAlign.left,
                                  )
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    formatTime(Duration(microseconds: context.watch<StopWatchValue>().time.inMicroseconds-(recordList.isNotEmpty ? recordList.last : const Duration()).inMicroseconds), all: true),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    formatTime(context.watch<StopWatchValue>().time, all: true),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                                    textAlign: TextAlign.right,
                                  )
                              )
                            ]
                        )
                    ),
                    const Divider(),
                    Expanded(child: ListView.builder(
                        itemCount: recordList.length,
                        itemBuilder: (BuildContext context, int i) {
                          final index = i;
                          final max = recordList.length-1;
                          return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: RecordItem(
                                  time: recordList[max-index],
                                  sectionTime: Duration(microseconds: recordList[max-index].inMicroseconds-((max-index-1)>=0?recordList[max-index-1].inMicroseconds:0)),
                                  index: recordList.length-i
                              )
                          );
                        }
                    ))
                  ],
                ),
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
    );
  }

  @override
  Column buildButtons() {
    return Column(children: [
      !_stopped ?
      Expanded(child: IconButton(onPressed: _stopTimer, icon: const Icon(Icons.pause_circle), iconSize: 36))
          : Expanded(child: IconButton(onPressed: ()=>_startTimer(context), icon: const Icon(Icons.play_circle), iconSize: 36)),
      Expanded(child: IconButton(onPressed: ()=>_recordTimer(context), icon: const Icon(Icons.add_circle), iconSize: 36)),
      Expanded(child: IconButton(onPressed: ()=>_resetTimer(context), icon: const Icon(Icons.cancel_rounded), iconSize: 36)),
    ]);
  }
}

class RecordItem extends StatelessWidget {
  final Duration sectionTime, time;
  final int index;

  const RecordItem({Key? key, required this.time, required this.sectionTime, required this.index}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                index.toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                textAlign: TextAlign.left,
              )
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                formatTime(sectionTime, all: true),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                textAlign: TextAlign.center,
              )
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                formatTime(time, all: true),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              )
          )
        ]
    );
  }
}


class StopWatchValue extends Times {
  int _stopTime = 0;

  int get stopTime => _stopTime;
  set stopTime (int value) {
    _stopTime = value;
    notifyListeners();
  }
}