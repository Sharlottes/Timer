import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timer/calender.dart';
import 'package:timer/setting.dart';
import 'package:timer/timers/maintimer.dart';

void main() {
  initializeDateFormatting()
      .then((_) => dates.initData().then((_) => runApp(MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2;
  final pages = <Widget>[
    MainTimerPage(),
    MainTimerPage(),
    CalenderPage(),
    SettingPage()
  ];
  final colors = <Color>[
    Colors.blue,
    Colors.green,
    Colors.amber,
    Colors.blueGrey
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors[_selectedIndex],
        title: const Text('Flutter Timer Demo'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_selectedIndex],
        transitionBuilder: (widget, animation) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.ease));
          return SlideTransition(
            position: animation.drive(tween),
            child: widget,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timelapse_rounded),
            label: 'Timers',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home (WIP)',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calender (WIP)',
            backgroundColor: Colors.amber,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings (WIP)',
            backgroundColor: Colors.blueGrey,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: HSVColor.fromColor(colors[_selectedIndex])
            .withValue(HSVColor.fromColor(colors[_selectedIndex]).value * 0.4)
            .toColor(),
        onTap: _onItemTapped,
      ),
    );
  }
}
