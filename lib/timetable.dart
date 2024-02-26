import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class TableStudent {
  String name;
  String fullName;
  String searchString;

  TableStudent(this.name, this.fullName, this.searchString);
}

main() {
  var student = TableStudent("test", "test", "richter");
  TimeTable(student);
  print("done");
}

class TimeTable {
  TableStudent student;

  TimeTable(this.student) {}

  var tables = [];

  Future<void> fetch() async {
    var loginPageURL =
        "https://selbstlernportal.de/html/planinfo/planinfo_start.php";
    var homePageURL = "https://www.landrat-lucas.org/";

    var loginParams = {
      "jsIsActive": "0",
      "group": "lev-llg",
      "login": "LLG",
      "pw": "llg",
      "checkLogin": ""
    };

    var searchParams = {
      "quickSearch": student.searchString,
      "chooseType": "???",
      "chooseWeek": "X",
      "chooseDesign": "w"
    };

    // get cookies and cFlag from login page
    var request = await HttpClient().getUrl(Uri.parse(loginPageURL));
    request.headers.add("Referer", homePageURL);
    request.headers.add("User-Agent", "Mozilla/5.0");
    var loginPageResponse = await request.close();

    var loginPageCookies = loginPageResponse.cookies;
    var loginPage = await loginPageResponse.transform(utf8.decoder).join();
    var document = parse(loginPage);
    var cFlagElement = document.querySelector('input[name=cFlag]');
    var cFlagValue = cFlagElement?.attributes['value'];
    searchParams["cFlag"] = cFlagValue!;

    // print("${searchParams}\n\n\n\n\n${loginParams}\n\n\n\n\n${loginPageCookies}\n\n\n\n\n${cFlagValue}\n\n\n\n\n${loginPage}\n\n\n\n\n");

    final loginResponse = await http.post(
      Uri.parse(loginPageURL),
      headers: {
        "Referer": loginPageURL,
        "User-Agent": "Mozilla/5.0",
        HttpHeaders.setCookieHeader: loginPageCookies.toString(),
        "Follow-Redirects": "true",
      },
      body: loginParams,
    );

    var loginPage2 = loginResponse.body;

    var loginPageCookies2 = loginResponse.headers[HttpHeaders.setCookieHeader];
    var cookie = loginPageCookies2!.split(";")[0];
    print(cookie);
    // print(loginPage2);
    print(loginPageCookies);

    print(searchParams);

    // get search results
    final resultRequest = await http.post(
      Uri.parse("https://selbstlernportal.de/html/planinfo/planinfo_start.php"),
      headers: {
        "Referer": loginPageURL,
        "User-Agent": "Mozilla/5.0",
        HttpHeaders.cookieHeader: "$cookie",
        "Follow-Redirects": "true",
      },
      body: searchParams,
    );

    final result = resultRequest.body;
    final resultDocument = parse(result);

    var planTables = resultDocument.querySelectorAll('table.tt');
    for (var table in planTables) {
      List<Day> days = [
        Day("Montag", []),
        Day("Dienstag", []),
        Day("Mittwoch", []),
        Day("Donnerstag", []),
        Day("Freitag", [])
      ];
      var currentDay = 0;
      var tableRows = table.querySelectorAll('tr');
      for (var row in tableRows) {
        var tableCells = row.querySelectorAll('td');
        for (var cell in tableCells) {
          days[currentDay].lessons.add(Lesson(cell.text));
          currentDay++;
          currentDay = currentDay % 5;
        }
      }

      days.forEach((day) {
        day.cut();
      });
      tables.add(days);
    }

    print(tables);
  }

  build() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 98,
              child: tables[0][0].build(),
            ),
            SizedBox(
              width: 98,
              child: tables[0][1].build(),
            ),
            SizedBox(
              width: 98,
              child: tables[0][2].build(),
            ),
            SizedBox(
              width: 98,
              child: tables[0][3].build(),
            ),
            SizedBox(
              width: 98,
              child: tables[0][4].build(),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: 98,
              child: tables[1][0].build(),
            ),
            SizedBox(
              width: 98,
              child: tables[1][1].build(),
            ),
            SizedBox(
              width: 98,
              child: tables[1][2].build(),
            ),
            SizedBox(
              width: 98,
              child: tables[1][3].build(),
            ),
            SizedBox(
              width: 98,
              child: tables[1][4].build(),
            ),
          ],
        ),
      ],
    );
  }
}

class Day {
  String name;
  List<Lesson> lessons;

  Day(this.name, this.lessons);

  @override
  String toString() {
    return 'Day{name: $name, lessons: $lessons}';
  }

  void cut() {
    for (var i = lessons.length - 1; i >= 0; i--) {
      if (lessons[i].data == "") {
        lessons.removeAt(i);
      } else {
        break;
      }
    }
  }

  Widget build() {
    // TODO: get current day and highlight it
    return Card(
      color: null,
      child: SizedBox(
        child: ListTile(
          title: Text(
            name,
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
          subtitle: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              return Text(
                lessons[index]
                    .data
                    .replaceFirst(RegExp(r'(?<=\s\S+\s)'), '\n')
                    .replaceFirst(RegExp(r'^\S*\s'), '')
                    .replaceFirst(RegExp(r'^(\S+\S+\S+)\s'), '')
                    .replaceAll("\n", " "),
                style: TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
        height: 160,
      ),
    );
  }

  String getDay() {
    return name;
  }
}

class Lesson {
  String data;

  Lesson(this.data);

  static Lesson fromString(String str) {
    return Lesson(str);
  }

  @override
  String toString() {
    return 'Lesson{data: $data}';
  }
}
