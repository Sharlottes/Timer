import 'package:flutter/cupertino.dart';

abstract class SubTimerPage extends StatefulWidget {
  const SubTimerPage({Key? key}): super(key: key);

  static of(BuildContext context, {bool root = false}) => root
      ? context.findRootAncestorStateOfType<SubTimerPageState>()
      : context.findAncestorStateOfType<SubTimerPageState>();

  static SubTimerPage createInstance() {
    // TODO: implement createInstance
    throw UnimplementedError();
  }
}

abstract class SubTimerPageState extends State<SubTimerPage> {
  Column buildButtons();
}