import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalenderPageState();
  }
}

abstract class APIData {
  abstract String dateKind;
  abstract String dateName;
  abstract String isHoliday;
  abstract String locdate;
  abstract String seq;
}

class _CalenderPageState extends State<CalenderPage> {
  DateTime _focusedDay = DateTime.now();
  List? _data;

  Future<List> getData(String year, String month) async {
    List<String> services = [
      "getHoliDeInfo",
      "getRestDeInfo",
      "getAnniversaryInfo",
      "get24DivisionsInfo",
      "getSundryDayInfo"
    ];

    String serviceKey =
        "ASMoQ8g1dkNUgxBDipwQ%2BGIgoGgC4K2f1ZW2WL%2FUMZTQOSm90EfydhFRUAee8P%2Fqzo1z0I9rYoSHDsnRkGKucQ%3D%3D";
    String numOfRows = "100";
    List datas = [];
    for (String service in services) {
      http.Response response = await http.get(
          Uri.parse(
              "https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/$service?ServiceKey=$serviceKey&solYear=${year.padLeft(2, "0")}&solMonth=${month.padLeft(2, "0")}&numOfRows=$numOfRows"),
          headers: {"Accept": "application/json"});
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes))["response"]
          ["body"]["items"]["item"];
      print(data);
      if (data is List) {
        datas.addAll(data);
      } else {
        datas.add(data);
      }
    }
    return datas;
  }

  @override
  void initState() {
    DateTime now = DateTime.now();
    getData('${now.year}', '${now.month}').then((data) {
      setState(() {
        _data = data;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return TableCalendar(
      locale: "ko_kr",
      firstDay: now.subtract(const Duration(days: 365 * 2)),
      lastDay: now.add(const Duration(days: 365 * 2)),
      focusedDay: _focusedDay,
      onPageChanged: (focusedDay) {
        getData('${focusedDay.year}', '${focusedDay.month}').then((data) {
          setState(() {
            _data = data;
          });
        });
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: (context, from, to) {
          Color color = Colors.black;
          String? subtitle;

          if (_data != null) {
            for (var element in _data!) {
              if (!(element["locdate"].toString().substring(4, 6) ==
                      '${from.month}'.padLeft(2, '0') &&
                  element["locdate"].toString().substring(6, 8) ==
                      '${from.day}'.padLeft(2, '0'))) continue;
              if (element["isHoliday"] == "Y") {
                color = Colors.red;
              }
              subtitle = element["dateName"];
            }
          }
          if (from.month != _focusedDay.month) {
            color = Colors.grey;
          } else if (from.weekday == DateTime.sunday) {
            color = Colors.red;
          } else if (from.weekday == DateTime.saturday) {
            color = Colors.blue;
          }

          return Center(child: Column(children: (() {
            List<Widget> children = [
              Text('${from.day}', style: TextStyle(color: color))
            ];
            if (subtitle != null && subtitle != "") {
              children.add(Flexible(
                  child: Text(subtitle,
                      style: TextStyle(color: color, fontSize: 12))));
            }
            return children;
          })()));
        },
        dowBuilder: (context, day) {
          final text = DateFormat.E().format(day);
          Color color = Colors.black;
          if (day.weekday == DateTime.sunday) {
            color = Colors.red;
          } else if (day.weekday == DateTime.saturday) {
            color = Colors.blue;
          }
          return Center(
            child: Text(
              text,
              style: TextStyle(color: color),
            ),
          );
        },
      ),
    );
  }
}
