import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../util.dart';
import 'times.dart';

final recordList = <Duration>[];
StopwatchTimes times = StopwatchTimes();

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({Key? key}): super(key: key);

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  void _startTimer(BuildContext context) {
    StopwatchTimes times = context.read<StopwatchTimes>();
    print("start button listener called, stopwatch ticking: ${times.ticker.isTicking}");
    if(times.ticker.isTicking) return;
    times.stopTime = const Duration();
    times.paused = false;
    times.ticker.start();
  }

  void _stopTimer() {
    context.read<StopwatchTimes>().paused = true;
  }

  void _resetTimer(BuildContext context) {
    recordList.clear();
    StopwatchTimes times = context.read<StopwatchTimes>();
    print("reset button listener called, stopwatch ticking: ${times.ticker.isTicking}");
    times.stopTime = const Duration();
    times.time = const Duration();
    times.paused = false;
    times.ticker.stop();
  }

  void _recordTimer(BuildContext context) {
    recordList.add(context.read<StopwatchTimes>().time);
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
  Widget build(BuildContext cont) {
    return ListenableProvider(
      create: (_)=>times,
      builder: (context, _) {
        return Align(
            alignment: Alignment.center,
            child: Column(children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width,
                    child: InkWell(
                        onTap: ()=>_startTimer(context),
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
                                            text: formatTime(context.watch<StopwatchTimes>().time),
                                            children: [
                                              TextSpan(
                                                  text: ' . ${formatTime(context.watch<StopwatchTimes>().time, onlyMicro: true)}',
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
                                                        children: [TextSpan(text: formatTime(context.watch<StopwatchTimes>().stopTime, all: true)),]
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
                                      formatTime(Duration(microseconds: context.watch<StopwatchTimes>().time.inMicroseconds-(recordList.isNotEmpty ? recordList.last : const Duration()).inMicroseconds), all: true),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                                      textAlign: TextAlign.center,
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      formatTime(context.watch<StopwatchTimes>().time, all: true),
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
                                  child: !context.read<StopwatchTimes>().paused&&context.read<StopwatchTimes>().ticker.isTicking ?
                                  TextButton(
                                      onPressed: _stopTimer,
                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent)),
                                      child: const Text('중지', style: TextStyle(color: Colors.black))
                                  ) :
                                  TextButton(
                                      onPressed: () => _startTimer(context),
                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent)),
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
    });
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