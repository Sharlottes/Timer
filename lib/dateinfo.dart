import 'dart:convert';

import 'package:http/http.dart' as http;

class DateInfo {
  List<List<List>> data = [];

  Future<void> initData() async {
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

    //[year][month]datas
    List<List<List>> datas = [];
    List<Future> futures = [];
    for (int y = 0; y < 3; y++) {
      datas.add([]);
      for (int m = 0; m < 12; m++) {
        datas[y].add([]);
        futures.add((() async {
          for (String service in services) {
            http.Response response = await http.get(
                Uri.parse(
                    "https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/$service?ServiceKey=$serviceKey&solYear=${(DateTime.now().year - 1 + y).toString().padLeft(2, "0")}&solMonth${(m + 1).toString().padLeft(2, "0")}&numOfRows=$numOfRows"),
                headers: {"Accept": "application/json"});
            dynamic body =
                jsonDecode(utf8.decode(response.bodyBytes))["response"]["body"];
            if (body["totalCount"] <= 0) return;
            dynamic data = body["items"]["item"];
            for (dynamic d in data is Iterable ? data : [data]) {
              List dates = datas[y][int.parse(d["locdate"]
                      .toString()
                      .substring(4, 6)
                      .replaceAll("0", "")) -
                  1];
              if (!dates.any((element) => element["locdate"] == d["locdate"])) {
                dates.add(d);
              }
            }
          }
        })());
      }
    }
    //await Future.wait(futures);
    print(datas);
    data = datas;
  }

  List? getInfoInMonth(int year, int month) {
    return data[year - DateTime.now().year + 1][month - 1];
  }

  dynamic getInfo(int year, int month, int day) {
    List? list = getInfoInMonth(year, month);

    return list?.singleWhere((element) {
      return day.toString().padLeft(2, "0") ==
          element["locdate"].toString().substring(6);
    }, orElse: () => null);
  }
}
