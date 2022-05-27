import 'package:flutter/material.dart';

class Times with ChangeNotifier {
  Duration _time = const Duration();

  Duration get time => _time;
  set time (Duration value) {
    _time = value;
    notifyListeners();
  }
}