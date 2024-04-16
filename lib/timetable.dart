import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:llgplan/category/substitutionplan.dart';

import 'main.dart';

class TableStudent {
  String name;
  String fullName;
  String searchString;

  TableStudent(this.name, this.fullName, this.searchString);
}

main() {
  var student = TableStudent("test", "test", "schnabel");
  TimeTable(student);
  print("done");
}

class TimeTable {
  static TimeTable? instance;
  TableStudent student;

  TimeTable(this.student) {
    instance = this;
  }

  Day get currentDay => tables[1][4];

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
          //TODO: add identification on what lesson it is e.g. 4,5  7
          days[currentDay].lessons.add(Lesson(cell.text, []));
          currentDay++;
          currentDay = currentDay % 5;
        }
      }

      days.forEach((day) {
        day.cut();
      });
      tables.add(days);
    }
  }

  build() {
    return ListView.builder(
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 400,
          child: Row(
            children: [
              Center(
                child: SizedBox(
                  width: 150,
                  child: tables[index][0].build(),
                ),
              ),
              SizedBox(
                width: 150,
                child: tables[index][1].build(),
              ),
              SizedBox(
                width: 150,
                child: tables[index][2].build(),
              ),
              SizedBox(
                width: 150,
                child: tables[index][3].build(),
              ),
              SizedBox(
                width: 150,
                child: tables[index][4].build(),
              ),
            ],
          ),
        );
      },
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
    return Column(
      children: [
        Text(name),
        Column(
          children: lessons.map((e) => e.build()).toList(),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }

  String getDay() {
    return name;
  }
}

class Lesson {
  String data;
  String exam = "";
  String courseId = "";
  String course = "";
  String teacher = "";
  String room = "";

  Lesson(this.data, List<int> lessons_) {
    //TODO: optimize
    var split = data.split(" ");
    if (data == "") {
      return;
    }

    if (split.length < 4) {
      course = split[0];
      teacher = split[1];
      room = split[2];
    } else {
      exam = split[0];
      courseId = split[1];
      course = courseId.split("-")[0];
      teacher = split[2];
      room = split[3];
    }
  }

  static Lesson fromString(String str) {
    return Lesson(str, []);
  }

  @override
  String toString() {
    return 'Lesson{exam: $exam, courseId: $courseId, teacher: $teacher, room: $room}';
  }

  bool showNote = false;

  Widget build({note = ""}) {
    // TODO: rework
    var currentDay = SubstitutionPlan.instance!.days[0];

    var isReplaced = false;
    var isCanceled = false;

    currentDay.substitutions.forEach((element) {
      if (element.oldSubject == courseId && element.class_ == "Q1") {
        isReplaced = true;
        if (element.type == "entfälllt") {
          isCanceled = true;
        }
        teacher = element.newTeacher;
        room = element.room;
      }
    });

    var style = TextStyle(
      fontSize: 12,
    );

    var row = Row(
      children: [
        SizedBox(
          child: Text(course, style: style),
          width: 20,
        ),
        Text(room, style: style),
        Text(teacher, style: style),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );

    var color = isCanceled
        ? Colors.red
        : isReplaced
            ? Colors.orange
            : null;

    return Card(
        color: color,
        child: SizedBox(
          width: 150,
          height: 25,
          child: note != ""
              ? FilledButton(
                  child: showNote
                      ? Text(note)
                      : Row(
                          children: [
                            ...row.children,
                            Icon(note != "" ? Icons.textsms_outlined : null),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                  onPressed: () {
                    if (note != "") {
                      LLGHomePageState.instance!.setState(() {
                        showNote = !showNote;
                      });
                    }
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                    textStyle:
                        MaterialStateProperty.all(TextStyle(fontSize: 10)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                )
              : row,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ));
  }
}
