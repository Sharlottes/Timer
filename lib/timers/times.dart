import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Times with ChangeNotifier {
  StopwatchTimes stopwatch = StopwatchTimes();
  TimerTimes timer = TimerTimes();
}

class TimerTimes with ChangeNotifier {
  Duration _time = const Duration();
  Duration _initTime = const Duration();
  late Ticker _ticker;
  bool _paused = false;

  TimerTimes() {
    _ticker = Ticker(incTime);
    _ticker.stop();
  }

  void incTime(Duration duration) {
    if(paused) return;
    time = duration;
  }

  Ticker get ticker => _ticker;
  Duration get time => _time;
  set time (Duration value) {
    _time = value;
    notifyListeners();
  }
  Duration get initTime => _initTime;
  set initTime (Duration value) {
    _initTime = value;
    notifyListeners();
  }
  bool get paused => _paused;
  set paused (bool value) {
    _paused = value;
    notifyListeners();
  }
}

class StopwatchTimes with ChangeNotifier {
  Duration _time = const Duration();
  Duration _stopTime = const Duration();
  late Ticker _ticker;
  bool _paused = false;

  StopwatchTimes() {
    _ticker = Ticker(incTime);
    _ticker.stop();
  }

  void incTime(Duration duration) {
    if(paused) {
      stopTime = duration;
    } else {
      time = duration;
    }
  }

  Ticker get ticker => _ticker;
  Duration get time => _time;
  set time (Duration value) {
    _time = value;
    notifyListeners();
  }
  Duration get stopTime => _stopTime;
  set stopTime (Duration value) {
    _stopTime = value;
    notifyListeners();
  }
  bool get paused => _paused;
  set paused (bool value) {
    _paused = value;
    notifyListeners();
  }
}