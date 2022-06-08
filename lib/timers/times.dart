import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Times with ChangeNotifier {
  Duration _time = const Duration();
  Duration _initTime = const Duration();
  int _stopTime = 0;
  Ticker? _stopwatch;
  Ticker? _timer;

  Ticker? get stopwatch => _stopwatch;
  set stopwatch (Ticker? value) {
    _stopwatch = value;
    notifyListeners();
  }
  Ticker? get timer => _timer;
  set timer (Ticker? value) {
    _timer = value;
    notifyListeners();
  }
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
  int get stopTime => _stopTime;
  set stopTime (int value) {
    _stopTime = value;
    notifyListeners();
  }
}