import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timer/timers/stopwatch.dart';
import 'package:timer/timers/timer.dart';
import 'package:timer/timers/times.dart';

class MainTimerPage extends StatefulWidget {
  const MainTimerPage({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() => _MainTimerPageState();
}

class _MainTimerPageState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(
          labelColor: Colors.blue,
          tabs: [
            Tab(text: 'Stopwatch'),
            Tab(text: 'Timer'),
            //Tab(text: 'Alarm'),
            //Tab(text: 'TimeZone')
          ],
        ),
      body: ListenableProvider(
          create: (_)=>Times(),
          builder: (context, _) {
            return const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                StopwatchPage(),
                TimerPage(),
                //AlarmPage(),
                //TimeZonePage(),
              ],
            );
          }
        )
      )
    );
  }
}